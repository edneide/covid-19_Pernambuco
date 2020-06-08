setwd("~/Documents/GitHub/covid-19_Pernambuco")

# Carregando a base de dados limpa
library(readr)
df <- read_delim("~/Google Drive/Coronavirus/IRRD/planilhas de pe/07-06-2020/bases_2020-06-08_00/recife_att_DOTS_2020-06-08_06-00.csv", 
                                               ";", escape_double = FALSE, trim_ws = TRUE)
names(df)

# Aplicando a função para padronizar o nome das variáveis
library(janitor)
de <- janitor::clean_names(df)
names(de)


#path = '/Users/edneideramalho/Documents/GitHub/covid-19_Pernambuco/'
write.csv(de, "covid-19_Pernambuco.csv")

