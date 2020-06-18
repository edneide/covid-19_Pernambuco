setwd("~/Documents/GitHub/covid-19_Pernambuco")

# Carregando a base de dados limpa
library(readr)
df <- read_delim("~/Google Drive/Coronavirus/IRRD/planilhas de pe/17-06-2020/Bases/recife_att_DOTS_2020-06-18_06-24.csv", 
                                               ";", escape_double = FALSE, trim_ws = TRUE)

head(df)
dim(df)

# Aplicando a função para padronizar o nome das variáveis
library(janitor)
de <- janitor::clean_names(df)
names(de)


#path = '/Users/edneideramalho/Documents/GitHub/covid-19_Pernambuco/'
write.csv(de, "covid-19_Pernambuco.csv")

