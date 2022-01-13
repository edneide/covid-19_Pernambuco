##--------------------------------------##
# Script criado em 05/03/2021
# Última Atualização: 05/03/2021
# by Edneide Ramalho
##--------------------------------------##
  
# BIBLIOTECAS ------------------------
library(dplyr)
library(readr)
library(lubridate)
library(pracma)
  
##--------------------------------------##
# BASE DE DADOS ------------------------
##--------------------------------------##
# hoje <- format(today(), "%d-%m-%Y") 
# mes <- "janeiro2022"
# # geres_df <- read.csv2(paste0("/Users/edneideramalho/Google Drive/Coronavirus/IRRD/planilhas de pe/",
# #                              mes, "/", hoje, 
# #                              "/base/Quadro_Resumo_GERES.csv"))
#   
library(readr)
geres_df <- read_csv("geres_macro_pernambuco.csv")
  
##--------------------------------------##
## CASOS ------------------------
##--------------------------------------##
novosCasos_df <-  read.csv("https://raw.githubusercontent.com/edneide/covid-19_Pernambuco/master/novos_casos_PE.csv")
  
variacao_function <- function(x){
  media_movel <-  movavg(x, 7, "s" )
  atual <- media_movel[length(media_movel)]
  duas_semanas <- media_movel[length(media_movel) - 14]
  variacao <- round(100 * (atual - duas_semanas) / duas_semanas, 2) 
  return(variacao)
}
  
variacoes <- vector()
for(i in 2:dim(novosCasos_df)[2]){
    variacoes[i-1] <- variacao_function(novosCasos_df[,i])
}
  
variacoes2 <- ifelse(is.infinite(variacoes) |
                         is.nan(variacoes), 0, variacoes) 
  
municipios <- gsub(pattern = ".", replacement = " ", 
                     names(novosCasos_df)[-1], 
                     fixed = TRUE)
  
variacoes_casos_df <- data.frame(municipio = municipios,
                                   variacao_percentual = variacoes2)
  
variacoes_casos_df <- variacoes_casos_df %>% 
    mutate(status = ifelse(variacao_percentual > 15, "Aumento",
                           ifelse(variacao_percentual < - 15, "Diminuição",
                                  "Estabilidade")
                           )
           )
  
  
geres_df$MUNICÍPIO <- toupper(geres_df$municipio)
geres_df$GERES2 <- as.character(geres_df$geres)
  
geres <- vector()
for(i in 1:dim(variacoes_casos_df)[1]){
    geres[i] <- as.character(geres_df$GERES2[which(geres_df$MUNICÍPIO == variacoes_casos_df$municipio[i])])
}
  
variacoes_casos_df <- variacoes_casos_df %>% 
    mutate(geres = geres)
  
##--------------------------------------##
# SALVANDO A BASE DE DADOS ------------------------
##--------------------------------------##
path <- "/Users/edneideramalho/Documents/GitHub/covid-19_Pernambuco/"
write.csv(variacoes_casos_df, 
          paste0(path, "variacao_casos_PE.csv"), 
          row.names = FALSE)
  
##--------------------------------------##
# PARA ÓBITOS ------------------------
##--------------------------------------##
  
novos_obitos_df <-  read.csv("https://raw.githubusercontent.com/edneide/covid-19_Pernambuco/master/novos_obitos_pe.csv")
  
  
variacao_function <- function(x){
  media_movel <-  movavg(x, 7, "s" )
  atual <- media_movel[length(media_movel)]
  duas_semanas <- media_movel[length(media_movel) - 14]
  variacao <- round(100 * (atual - duas_semanas) / duas_semanas, 2) 
  return(variacao)
}
  
variacoes_obitos <- vector()
for(i in 2:dim(novos_obitos_df)[2]){
    variacoes_obitos[i-1] <- variacao_function(novos_obitos_df[,i])
  }
  
variacoes_obitos2 <- ifelse(is.infinite(variacoes_obitos) |
                         is.nan(variacoes_obitos), 0, variacoes_obitos) 
  
municipios <- gsub(pattern = ".", replacement = " ", 
                     names(novos_obitos_df)[-1], 
                     fixed = TRUE)
  
variacoes_obitos_df <- data.frame(municipio = municipios,
                                   variacao_percentual = variacoes_obitos2)
  
variacoes_obitos_df <- variacoes_obitos_df %>% 
  mutate(status = ifelse(variacao_percentual > 15, "Aumento",
                          ifelse(variacao_percentual < - 15, "Diminuição", "Estabilidade")
))
  
  
geres_df$MUNICÍPIO <- toupper(geres_df$municipio)
geres_df$GERES2 <- as.character(geres_df$geres)
  
geres <- vector()
  for(i in 1:dim(variacoes_obitos_df)[1]){
  geres[i] <- as.character(geres_df$GERES2[which(geres_df$MUNICÍPIO == variacoes_obitos_df$municipio[i])])
  }
  
variacoes_obitos_df <- variacoes_obitos_df %>% 
    mutate(geres = geres)
  
##--------------------------------------##
# SALVANDO A BASE DE DADOS ------------------------
##--------------------------------------##
path <- "/Users/edneideramalho/Documents/GitHub/covid-19_Pernambuco/"
write.csv(variacoes_obitos_df, 
          paste0(path, "variacao_obitos_PE.csv"), 
          row.names = FALSE)  
  
  