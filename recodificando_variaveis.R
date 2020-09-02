library(lubridate)
setwd("~/Documents/GitHub/covid-19_Pernambuco")



hoje <- format(as.Date(today()-1), "%d-%m-%Y")


# Carregando a base de dados limpa
library(readr)
df <- read_delim(paste0("~/Google Drive/Coronavirus/IRRD/planilhas de pe/setembro/", hoje,
"/bases/recife_att.csv"), ";", escape_double = TRUE, trim_ws = TRUE)
names(df)
dim(df)

# Aplicando a função para padronizar o nome das variáveis
library(janitor)
de <- janitor::clean_names(df)
names(de)


#path = '/Users/edneideramalho/Documents/GitHub/covid-19_Pernambuco/'
write.csv(de, "covid-19_Pernambuco.csv")

