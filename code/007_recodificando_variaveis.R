library(lubridate)
library(dbplyr)
library(readr)
library(janitor)



#--Datas
data_considerada <- today()-1

hoje <- format(as.Date(data_considerada), "%d-%m-%Y")
hoje

#--Carregando a base de dados limpa
library(readr)
df <- read_delim(paste0("planilhas_de_pe/janeiro2022/", 
                        hoje,
                        "/base/recife_att.csv"), 
                         ";", escape_double = TRUE, trim_ws = TRUE)
dim(df)


#--Aplicando a função para padronizar o nome das variáveis
de <- janitor::clean_names(df)
names(de)
names(de)[1] <- "data"
glimpse(de)

confirmados_srag <-  de %>% 
  dplyr::filter(classificacao_final == "CONFIRMADO", srag == "SIM")
dim(confirmados_srag)

#--Confirmados leves
confirmados_leves <-  de %>% 
  dplyr::filter(classificacao_final == "CONFIRMADO", 
         srag == "NÃO",
         !is.na(geres),
         estado_de_residencia == "PERNAMBUCO")
dim(confirmados_leves)

path_salvar <- paste0("planilhas_de_pe/janeiro2022/",
                      hoje, "/") 
write.csv(de, paste0(path_salvar, "covid-19_Pernambuco.csv"))

