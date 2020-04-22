# Carregando a base de dados limpa
library(readr)
recife_att_2020_04_22_01_02 <- read_delim("~/Google Drive/Coronavirus/IRRD/planilhas de pe/21-04-2020/recife_att_2020-04-22_01-02.csv", 
                                          ";", escape_double = FALSE, trim_ws = TRUE)

df <- recife_att_2020_04_22_01_02

# Aplicando a função para padronizar o nome das variáveis
library(janitor)
de <- clean_names(df)
names(de)

#path = '/Users/edneideramalho/Documents/GitHub/covid-19_Pernambuco/'
write.csv(de, "covid-19_Pernambuco.csv")

