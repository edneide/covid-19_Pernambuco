setwd("~/Google Drive/Coronavirus/IRRD/planilhas de pe/16-05-2020/")

library(readr)

# Casos 
casos_total <- read.csv("https://raw.githubusercontent.com/JTeodomiro/covid19PE/master/PE_Cidades_DATA.csv")
casos_srag <- read.csv("https://raw.githubusercontent.com/JTeodomiro/covid19PE/master/PE_Cidades_DATA_SRAG.csv")

# Óbitos
obitos_pe <- read.csv("https://raw.githubusercontent.com/JTeodomiro/covid19PE/master/Obitos_PE_Cidades.csv")


dim(casos_total)
dim(casos_srag)
dim(covid19_PE_casos_leves_por_municipio)


# Salvando em csv
write.csv(casos_srag, "covid_19_PE_SRAG_att_em_17_05_2020.csv")
write.csv(obitos_pe, "covid_19_PE_obitos_att_em_17_05_2020.csv")
