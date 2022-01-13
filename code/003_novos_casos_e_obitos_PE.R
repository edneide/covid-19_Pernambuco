# 0. Packages -----------------
library(dplyr)
library(tidyr)
library(tidyverse)
library(lubridate)
library(readr)
library(janitor)

rm(list=ls())
data_considerada <- format(ymd(today()-1), "%Y-%m-%d")

# 1. Data -----------------

## Steps -----------
# 1. Baixar total de casos e de óbitos
url_cases <- "https://raw.githubusercontent.com/edneide/covid-19_Pernambuco/master/total_cases_PE.csv"
url_deaths <- "https://raw.githubusercontent.com/edneide/covid-19_Pernambuco/master/total_deaths_PE.csv"

df_pe_total_cases <- read_csv(url_cases) 
df_pe_total_deaths <- read_csv(url_deaths)


# 2. Calcular diferença nos últimos dois dias para casos e óbitos

### Casos
casos_recentes <- df_pe_total_cases %>% tail(2)

lista_novos_casos <- list()
lista_novos_casos[[1]] <- data_considerada

for (i in 2:dim(df_pe_total_cases)[2]) {
  new_cases <- ifelse(
    diff(casos_recentes[,i] %>% pull()) > 0,
    diff(casos_recentes[,i] %>% pull()), 0
  )
  lista_novos_casos[[i]] <- new_cases
}

novos_casos_att_df <- as.data.frame(do.call(cbind, lista_novos_casos))
names(novos_casos_att_df) <- names(df_pe_total_cases)


### Óbitos
obitos_recentes <- df_pe_total_deaths %>% tail(2)

lista_novos_obitos <- list()
lista_novos_obitos[[1]] <- data_considerada

for (i in 2:dim(df_pe_total_deaths)[2]) {
  new_deaths <- ifelse(
    diff(obitos_recentes[,i] %>% pull()) > 0,
    diff(obitos_recentes[,i] %>% pull()), 0
  )
  lista_novos_obitos[[i]] <- new_deaths
}

novos_obitos_att_df <- as.data.frame(do.call(cbind, lista_novos_obitos))
names(novos_obitos_att_df) <- names(df_pe_total_deaths)

# 3. Baixar novos casos e óbitos
novos_casos <- read_csv("https://raw.githubusercontent.com/edneide/covid-19_Pernambuco/master/novos_casos_PE.csv")
novos_obitos <- read_csv("https://raw.githubusercontent.com/edneide/covid-19_Pernambuco/master/novos_obitos_pe.csv")

# 4. Juntar essa diferença na base de novos casos com data atualizada
novos_casos <- rbind(novos_casos, novos_casos_att_df)
novos_obitos <- rbind(novos_obitos, novos_obitos_att_df)

# 5. Salvar no Github
path <- "/Users/edneideramalho/Documents/GitHub/covid-19_Pernambuco/"
write.csv(novos_casos, paste0(path, "novos_casos_PE.csv"), row.names = FALSE)
write.csv(novos_obitos, paste0(path, "novos_obitos_pe.csv"), row.names = FALSE)
