library(reticulate) #para rodar códigos em Python
library(readr)
library(ggplot2)
library(tidyr)
library(dplyr)
library(plotly)


use_python('/opt/anaconda3/bin/python', required = TRUE)
#py_install("orca")
# Rodando 
# Importante: mudar o diretório para onde se encontra o arquivo!
py_run_file("Fitting_curvature_.py")


# Carregando os csv's gerados
Casos_confirmados_Brazil_Fitting <- read_csv("Casos_confirmados_Brazil_Fitting.csv")

Casos_confirmados_Brazil_Fitting$Data = 
  as.Date.character(Casos_confirmados_Brazil_Fitting$Data, format = "%d %b")

class(Casos_confirmados_Brazil_Fitting$Data)

write.csv(Casos_confirmados_Brazil_Fitting, 
          "Casos_confirmados_Brazil_Fitting.csv")

# Pernambuco

Casos_confirmados_Pernambuco_Fitting <- read_csv("Casos_confirmados_Pernambuco_Fitting.csv")


Casos_confirmados_Pernambuco_Fitting$Data = 
  as.Date.character(Casos_confirmados_Pernambuco_Fitting$Data, format = "%d %b")
class(Casos_confirmados_Pernambuco_Fitting$Data)

write.csv(Casos_confirmados_Pernambuco_Fitting, 
          "Casos_confirmados_Pernambuco_Fitting.csv")


