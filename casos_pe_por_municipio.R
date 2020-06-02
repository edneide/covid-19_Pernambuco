setwd("~/Google Drive/Coronavirus/IRRD/planilhas de pe/31-05-2020/")

library(readr)

# Casos 
casos_total <- read.csv("https://raw.githubusercontent.com/JTeodomiro/covid19PE/master/PE_Cidades_DATA.csv")
casos_srag <- read.csv("https://raw.githubusercontent.com/JTeodomiro/covid19PE/master/PE_Cidades_DATA_SRAG.csv")

# Óbitos
obitos_pe <- read.csv("https://raw.githubusercontent.com/JTeodomiro/covid19PE/master/Obitos_PE_Cidades.csv")


dim(casos_total)
dim(casos_srag)

library(lubridate)
# Salvando em csv
write.csv(casos_srag, paste("covid_19_PE_SRAG_att_em_", today(), ".csv"))
write.csv(obitos_pe, paste("covid_19_PE_obitos_att_em_", today(), ".csv"))
