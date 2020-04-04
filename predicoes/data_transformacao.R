# Transformando datas
library(dplyr)
library(readr)

Casos_confirmados_Brazil_Fitting <- read_csv("Casos_confirmados_Brazil_Fitting.csv")
Casos_confirmados_Brazil_Fitting$Data = as.Date.character(Casos_confirmados_Brazil_Fitting$Data, format = "%d %b")
class(Casos_confirmados_Brazil_Fitting$Data)

write.csv(Casos_confirmados_Brazil_Fitting, "Casos_confirmados_Brazil_Fitting.csv")

# Mundial 
Casos_confirmados_Pernambuco_Fitting <- read_csv("Casos_confirmados_Pernambuco_Fitting.csv")


Casos_confirmados_Pernambuco_Fitting$Data = as.Date.character(Casos_confirmados_Pernambuco_Fitting$Data, format = "%d %b")
class(Casos_confirmados_Pernambuco_Fitting$Data)

write.csv(Casos_confirmados_Pernambuco_Fitting, "Casos_confirmados_Pernambuco_Fitting.csv")
