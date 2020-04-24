# Carregando a base de dados limpa
library(readr)
df <- read_delim("~/Google Drive/Coronavirus/IRRD/Limpeza e análises - Dados PE covid-19/22-04-2020/recife_att_DOTS_2020-04-23_01-06.csv", 
                                               ";", escape_double = FALSE, trim_ws = TRUE)



library(readr)
recife_att_DOTS_2020_04_24_00_45 <- read_delim("~/Google Drive/Coronavirus/IRRD/Limpeza e análises - Dados PE covid-19/23-04-2020/recife_att_DOTS_2020-04-24_00-45.csv", 
                                               ";", escape_double = FALSE, trim_ws = TRUE)
View(recife_att_DOTS_2020_04_24_00_45)

# Aplicando a função para padronizar o nome das variáveis
library(janitor)
de <- clean_names(df)
names(de)

#path = '/Users/edneideramalho/Documents/GitHub/covid-19_Pernambuco/'
write.csv(de, "covid-19_Pernambuco.csv")

