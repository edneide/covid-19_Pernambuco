library(readr)
# Casos
municipios_pe <- read.csv("https://raw.githubusercontent.com/JTeodomiro/covid19PE/master/PE_Cidades_DATA.csv")

# Óbitos
library(readr)
obitos_pe <- read_csv("~/Google Drive/Coronavirus/IRRD/Projeções para Pernambuco/Óbitos_PE_Cidades.csv")

# Selecionando os municípios
library(dplyr)
casos <- municipios_pe %>% 
  dplyr::select(Data, RECIFE, OLINDA, CAMARAGIBE, SAO.LOURENCO.DA.MATA)

# Organizando a data
library(lubridate)
casos <- casos %>% 
  mutate(datei = paste(Data, "2020"),
         date = dmy(datei)) %>% 
  dplyr::select(date, RECIFE:SAO.LOURENCO.DA.MATA)

# Óbitos 
obitos <- obitos_pe %>% 
  dplyr::select(X1, Recife, Olinda, Camaragibe, `São Lourenço da Mata`)

names(obitos) <- c("date", "RECIFE", "OLINDA", "CAMARAGIBE", "SAO.LOURENCO.DA.MATA")

# Add linha para 14-05-2020


# Gráfico Recife 
library(ggplot2)
ggplot(NULL) +
  geom_point(data = casos, aes(x = date, y = RECIFE)) +
  geom_line(data = casos, aes(x = date, y = RECIFE)) +
  theme(axis.text.x = element_text(angle = 45)) + 
  labs(title = "Casos confirmados de COVID-19",
       subtitle = "Recife",
       caption = paste("IRRD/PE. Fonte: Secretaria de Saúde de PE.\nDados atualizados em ", format(as.Date(today()), "%d/%m/%Y"))) + 
  xlab("Data") + ylab("Casos acumulados") 

