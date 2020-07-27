#setwd("~/Google Drive/Coronavirus/IRRD/planilhas de pe/21-07-2020/")
caminho <- "/Users/edneideramalho/Google Drive/Coronavirus/IRRD/planilhas de pe/Casos e óbitos por município - PE/"

library(readr)

# Casos 
casos_total <- read.csv("https://raw.githubusercontent.com/JTeodomiro/covid19PE/master/PE_Cidades_DATA.csv")
casos_srag <- read.csv("https://raw.githubusercontent.com/JTeodomiro/covid19PE/master/PE_Cidades_DATA_SRAG.csv")
#casos_leve <- read.csv("")

# Óbitos
obitos_pe <- read.csv("https://raw.githubusercontent.com/JTeodomiro/covid19PE/master/Obitos_PE_Cidades.csv")


dim(casos_total)
dim(casos_srag)

library(lubridate)
# Salvando em csv
write.csv(casos_srag, paste0(caminho,"covid_19_PE_SRAG.csv"))
write.csv(obitos_pe, paste0(caminho, "covid_19_PE_obitos.csv"))
write.csv(casos_total,paste0(caminho, "covid_19_PE_casos_total.csv"))

