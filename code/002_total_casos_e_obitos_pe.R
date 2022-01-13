##===================================##
## Correção dos novos casos e óbitos ##
## Municípios de PE                  ##
## Criação: 05/01/2022               ##
## By: Edneide Ramalho               ##
##===================================##



# 0. Packages -----------------
library(dplyr)
library(tidyr)
library(tidyverse)
library(lubridate)
library(readr)
library(janitor)


# 1. Data -----------------
rm(list=ls())

# Configuração das datas:
data_considerada <- format(ymd(today()-1), "%d-%m-%Y")
mes_ano <- "janeiro2022"


# Baixando a base de dados do github:
url_cases <- "https://raw.githubusercontent.com/edneide/covid-19_Pernambuco/master/total_cases_PE.csv"
url_deaths <- "https://raw.githubusercontent.com/edneide/covid-19_Pernambuco/master/total_deaths_PE.csv"

df_pe_total_cases <- read_csv(url_cases) 
df_pe_total_deaths <- read_csv(url_deaths)


df_pe_total_cases$Data %>% tail(1)
df_pe_total_deaths$Data %>% tail(1)
data_considerada

# 2. Data Aldemar -----------------
# Tabela de Aldemar:
Quadro_Resumo_Cidades <- read_delim(paste0("planilhas_de_pe/", 
                                           mes_ano,
                                           "/", 
                                           data_considerada, 
                                           "/base/Quadro_Resumo_Cidades.csv"), 
                                    ";", escape_double = FALSE, trim_ws = TRUE)

## Colocar municípios em caixa alta
Quadro_Resumo_Cidades$MUNICÍPIO <- toupper(Quadro_Resumo_Cidades$MUNICÍPIO)
df_cidades <- clean_names(Quadro_Resumo_Cidades[-dim(Quadro_Resumo_Cidades)[1],])

# CASOS -----------
df_cidades_att_casos <- df_cidades %>% 
  dplyr::select(municipio, confirmados) %>% 
  spread(municipio, confirmados)

df_cidades_att_casos$Data <- as.Date(data_considerada, format = "%d-%m-%Y")

df_cidades_att_casos <- df_cidades_att_casos %>% 
  dplyr::select(Data, `ABREU E LIMA`:`XEXEU`)

# ÓBITOS -----------
df_cidades_att_obitos <- df_cidades %>% 
  dplyr::select(municipio, obitos) %>% 
  spread(municipio, obitos)

df_cidades_att_obitos$Data <- as.Date(data_considerada, format = "%d-%m-%Y")

df_cidades_att_obitos <- df_cidades_att_obitos %>% 
  dplyr::select(Data, `ABREU E LIMA`:`XEXEU`)

# Juntando as bases de dados:
df_casos_pe_wide <- rbind(df_pe_total_cases, df_cidades_att_casos)

df_obitos_pe_wide <- rbind(df_pe_total_deaths, df_cidades_att_obitos)

# 5. Att no github --------
path <- "/Users/edneideramalho/Documents/GitHub/covid-19_Pernambuco/"
write.csv(df_casos_pe_wide, 
          paste0(path, "total_cases_PE.csv"), 
          row.names = FALSE)
write.csv(df_obitos_pe_wide,
          paste0(path, "total_deaths_pe.csv"),
          row.names = FALSE)

