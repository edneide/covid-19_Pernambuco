library(reticulate) #para rodar códigos em Python
library(readr)
library(ggplot2)
library(tidyr)
library(dplyr)
library(plotly)


# Local da versão do Python a ser utilizada
use_python('/opt/anaconda3/bin/python', required = TRUE)

py_run_file("Ricci.py")


# Carregando os csv's gerados
ricci_mundo <- read_csv("forman_ricci_mundial.csv")
ricci_brasil <- read_csv("forman_ricci_brasil.csv")


### Mudando o formato das datas
ricci_brasil$periodo = as.Date.character(ricci_brasil$periodo, format = "%d %b")
class(ricci_brasil$periodo)
write.csv(ricci_brasil, "forman_ricci_brasil.csv")

ricci_mundo$periodo = as.Date.character(ricci_mundo$periodo, format = "%d %b")
class(ricci_mundo$periodo)
write.csv(ricci_mundo, "forman_ricci_mundial.csv")
