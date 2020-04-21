# Carregando a base de dados limpa
library(readr)
df <- read_delim("20-04-2020/recife_att_DOTS_2020-04-21_00-34.csv", 
                                               ";", escape_double = FALSE, trim_ws = TRUE)

# Aplicando a função para padronizar o nome das variáveis
library(janitor)
de <- clean_names(df)
names(de)

#path = '/Users/edneideramalho/Documents/GitHub/covid-19_Pernambuco/'
write.csv(de, "covid-19_Pernambuco.csv")

