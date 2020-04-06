# Carregando a base de dados limpa
library(readr)
df <- read_delim("~/Google Drive/Coronavirus/IRRD/planilhas de pe/06-04-2020/recife_att_2020-04-06_19-14.csv", 
                                          ";", escape_double = FALSE, trim_ws = TRUE)
#View(recife_att_2020_04_06_19_14)
names(df)

# Aplicando a função para padronizar o nome das variáveis
library(janitor)
de <- clean_names(df)
names(de)

#path = '/Users/edneideramalho/Documents/GitHub/covid-19_Pernambuco/'
write.csv(de, "covid-19_Pernambuco.csv")

