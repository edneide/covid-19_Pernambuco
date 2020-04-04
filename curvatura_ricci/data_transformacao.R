# Transformando datas
library(dplyr)
library(readr)
forman_ricci_brasil <- read_csv("~/Documents/GitHub/covid-19_Pernambuco/curvatura_ricci/forman_ricci_brasil.csv")

forman_ricci_brasil$periodo = as.Date.character(forman_ricci_brasil$periodo, format = "%d %b")
class(forman_ricci_brasil$periodo)

write.csv(forman_ricci_brasil, "forman_ricci_brasil2.csv")

# Mundial 
forman_ricci_mundial <- read_csv("~/Documents/GitHub/covid-19_Pernambuco/curvatura_ricci/forman_ricci_mundial.csv")
forman_ricci_mundial$periodo = as.Date.character(forman_ricci_mundial$periodo, format = "%d %b")
class(forman_ricci_mundial$periodo)
write.csv(forman_ricci_mundial, "forman_ricci_mundial2.csv")

