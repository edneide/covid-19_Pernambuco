library(dplyr)
library(ggplot2)
library(readr)
library(lubridate)
library(readr) 
library(ggpubr)
library(pracma)
library(plotly)
library(tidyr)

#setwd("~/Google Drive/Coronavirus/IRRD/codigos em R/geracao_de_graficos_para_informe")
Sys.setlocale("LC_TIME", "pt_PT.UTF-8")
hoje <- format(as.Date(today()-1), "%d-%m-%Y")
hoje2 <- today()-1

# hoje <- format(today()-1, "%d-%m-%Y") 
# mes <- "marco2021"
# geres_df <- read.csv2(paste0("/Users/edneideramalho/Google Drive/Coronavirus/IRRD/planilhas de pe/",
#                              mes, "/", hoje, 
#                              "/base/Quadro_Resumo_GERES.csv"))
# 
# geres_df <- clean_names(geres_df) 
# 
# geres_df <- geres_df %>% 
#   dplyr::select(geres, municipio)
# 
# geres_df$municipio <- toupper(geres_df$municipio) 
# 
# geres_df <- geres_df %>% 
#   dplyr::filter(municipio != "TOTAL GERES",
#                 geres != "Total")
# 
# # Salvando em csv: geres ----
# write.csv(geres_df, "geres_pernambuco.csv", row.names = FALSE)

# carregando base de dados das geres ----
library(readr)
geres_pernambuco <- read_csv("geres_macro_pernambuco.csv")
# geres_macros_pe <- geres_pernambuco %>% 
#   dplyr::mutate(macro = ifelse(geres %in% c("I", "II", "III", "XII"),
#                                1, ifelse(geres %in% c("IV", "V"), 2,
#                                          ifelse(geres %in% c("VI", "X", "XI"), 3, 4))))
# 
# geres_macros_pe <- geres_macros_pe %>% 
#   dplyr::mutate(macro_nome = ifelse(macro == 1, "Metropolitana",
#                                     ifelse(macro == 2, "Agreste",
#                                            ifelse(macro == 3, "Sertão", "Vale do São Francisco e Araripe")))
#                 )
# 
# write.csv(geres_macros_pe, "geres_macro_pernambuco.csv", row.names = FALSE)


# CARREGANDO A BASE DE NOVOS CASOS ----
base_pe <- "https://raw.githubusercontent.com/edneide/covid-19_Pernambuco/master/novos_casos_PE.csv"

df <- read_csv(base_pe)

# Os dados estão atualizados?????
df$Data %>% tail(1) == hoje2


# TRANSFORMANDO PARA A FORMA COMPRIDA ----
df2 <- tidyr::gather(df, 
              key = "municipio",
              value = "casos",
              -Data)

# BASE COM AS GERES ----
df_with_geres <- dplyr::left_join(df2, geres_pernambuco)

# EXTRAINDO SOMENTE AS GERES ----
cases_geres <- df_with_geres %>% 
  dplyr::select(Data, casos, geres) %>% 
  dplyr::group_by(Data, geres) %>% 
  dplyr::summarise(total_cases = sum(casos))

# CALCULANDO AS MÉDIAS MÓVEIS POR GERES ----
nomes_geres <- unique(cases_geres$geres)
lista_geres <- list()
for (i in 1:length(nomes_geres)) {
  lista_geres[[i]] <- cases_geres %>% 
    dplyr::filter(geres %in% nomes_geres[i])
}
names(lista_geres) <- nomes_geres

for (i in 1:length(nomes_geres)) {
lista_geres[[i]]$media_movel = movavg(lista_geres[[i]]$total_cases, 7, "s")
}

# JUNTANDE NOVAMENTE EM UMA BASE DE DADOS ----
geres_media_movel <- do.call(rbind.data.frame, lista_geres)

# SALVANDO EM CSV NO GITHUB ----
path <- "/Users/edneideramalho/Documents/GitHub/covid-19_Pernambuco/"
write.csv(geres_media_movel,
          paste0(path, "geres_media_movel.csv"),
          row.names = FALSE)

# TRANSFORMANDO PARA A FORMA LARGA ----
cases_geres2 <- tidyr::spread(cases_geres, geres, total_cases)

# GERANDO A PLANILHA DE MÉDIAS MÓVEIS ----
variacao_function <- function(x){
  media_movel <-  movavg(x, 7, "s" )
  atual <- media_movel[length(media_movel)]
  duas_semanas <- media_movel[length(media_movel) - 14]
  variacao <- round(100 * (atual - duas_semanas) / duas_semanas, 2) 
  return(variacao)
}

variacoes <- vector()
for(i in 2:dim(cases_geres2)[2]){
  variacoes[i-1] <- variacao_function(pull(cases_geres2[,i]))
}

variacoes2 <- ifelse(is.infinite(variacoes) |
                       is.nan(variacoes), 0, variacoes) 

variacoes_casos_geres_df <- data.frame(geres = names(cases_geres2)[-1],
                                 variacao_percentual = variacoes2)

variacoes_casos_geres_df <- variacoes_casos_geres_df %>% 
  mutate(status = ifelse(variacao_percentual > 15, "Aumento",
                         ifelse(variacao_percentual < - 15, "Diminuição",
                                "Estabilidade")
  )
  )


# SALVANDO EM CSV NO GITHUB ----
path <- "/Users/edneideramalho/Documents/GitHub/covid-19_Pernambuco/"
write.csv(variacoes_casos_geres_df,
          paste0(path, "variacoes_casos_geres.csv"),
          row.names = FALSE)

# POR MACROS ----

# EXTRAINDO SOMENTE AS MACROS ----
cases_macros <- df_with_geres %>% 
  dplyr::select(Data, casos, macro) %>% 
  dplyr::group_by(Data, macro) %>% 
  dplyr::summarise(total_cases = sum(casos))


# CALCULANDO AS MÉDIAS MÓVEIS POR MACRO ----
nomes_macros <- unique(cases_macros$macro)
lista_macros <- list()
for (i in 1:length(nomes_macros)) {
  lista_macros[[i]] <- cases_macros %>% 
    dplyr::filter(macro %in% nomes_macros[i])
}
names(lista_macros) <- nomes_macros

for (i in 1:length(nomes_macros)) {
  lista_macros[[i]]$media_movel = movavg(lista_macros[[i]]$total_cases, 7, "s")
}

# JUNTANDE NOVAMENTE EM UMA BASE DE DADOS ----
macros_media_movel <- do.call(rbind.data.frame, lista_macros)

# SALVANDO EM CSV NO GITHUB ----
path <- "/Users/edneideramalho/Documents/GitHub/covid-19_Pernambuco/"
write.csv(macros_media_movel,
          paste0(path, "macros_media_movel.csv"),
          row.names = FALSE)


# TRANSFORMANDO PARA A FORMA LARGA ----
cases_macros2 <- tidyr::spread(cases_macros, macro, total_cases)

# GERANDO A PLANILHA DE MÉDIAS MÓVEIS ----
variacao_function <- function(x){
  media_movel <-  movavg(x, 7, "s" )
  atual <- media_movel[length(media_movel)]
  duas_semanas <- media_movel[length(media_movel) - 14]
  variacao <- round(100 * (atual - duas_semanas) / duas_semanas, 2) 
  return(variacao)
}

variacoes_macro <- vector()
for(i in 2:dim(cases_macros2)[2]){
  variacoes_macro[i-1] <- variacao_function(pull(cases_macros2[,i]))
}

variacoes_macro <- ifelse(is.infinite(variacoes_macro) |
                       is.nan(variacoes_macro), 0, variacoes_macro) 

variacoes_macro_df <- data.frame(macro = names(cases_macros2)[-1],
                                       variacao_percentual = variacoes_macro)

variacoes_macros_df <- variacoes_macro_df %>% 
  mutate(status = ifelse(variacao_percentual > 15, "Aumento",
                         ifelse(variacao_percentual < - 15, "Diminuição",
                                "Estabilidade")
  )
  )


# SALVANDO EM CSV NO GITHUB ----
path <- "/Users/edneideramalho/Documents/GitHub/covid-19_Pernambuco/"
write.csv(variacoes_macros_df,
          paste0(path, "variacoes_casos_macros.csv"),
          row.names = FALSE)

