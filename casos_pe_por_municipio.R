library(readr)

casos_total <- read.csv("https://raw.githubusercontent.com/JTeodomiro/covid19PE/master/PE_Cidades_DATA.csv")
casos_srag <- read.csv("https://raw.githubusercontent.com/JTeodomiro/covid19PE/master/PE_Cidades_DATA_SRAG.csv")


covid19_PE_casos_leves_por_municipio <- as.data.frame.matrix(table(confirmados_leves$data_da_notificacao, confirmados_leves$municipio))

dim(casos_total)
dim(casos_srag)
dim(covid19_PE_casos_leves_por_municipio)

setwd("~/Google Drive/Coronavirus/IRRD/planilhas de pe/16-05-2020/")
write.csv(casos_srag, "covid_19_PE_SRAG.csv")
