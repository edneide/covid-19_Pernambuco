# Bibliotecas -----------------------------
library(readr)
library(ggplot2)
library(dplyr)
library(lubridate)
library(reshape2)
library(ggrepel)
library(gridExtra)
library(pracma)
library(tidyverse)
library(hrbrthemes)
library(plotly)

##--Selecionando o português com idioma nos gráficos-----
Sys.setlocale("LC_TIME", "pt_PT.UTF-8")

##--Data-----
hoje <- today()-1

# Diretório de trabalho-----
#setwd("/Users/edneideramalho/Google Drive/Coronavirus/IRRD/Informes e relatórios/")

#Criando pasta para salvar as figuras ----------
dir.create(paste0("graficos_", hoje)) #criando a pasta
path <- paste0(getwd(), "/", paste0("graficos_", hoje))

path

# Dados ------

Cov_D <- read_csv("https://raw.githubusercontent.com/wcota/covid19br/master/cases-brazil-states.csv")


# Pernambuco -----------
df <- Cov_D
pe <- filter(df, state == "PE")

tail(pe)


#======================================#
# Corrigindo alguns valores incorretos -----
#======================================#
pe[151,6] <- 21
pe[151,7] <- 6941
pe[151, 8] <- 1021
pe[151, 9] <- 105134
pe[151,]


pe[152,6] <- 29
pe[152,7] <- 6970
pe[152, 8] <- 247
pe[152, 9] <- 105381
pe[152,]

pe[412, 9] <- 399437

#View(pe)
write.csv(pe,
          "/Users/edneideramalho/Google Drive/Coronavirus/Paper - Modelos Matemático/analises_modelos_matematicos_covid/dados_pe.csv",
          row.names = FALSE)



# Corrigindo a data de 28/04/2021 -----
# pe <- pe %>% 
#   dplyr::filter(date < today() - 1)

# Organizando casos e mortes ----
class(pe$deaths)
tail(pe)
pe_mod <- dplyr::select(pe, date, deaths, totalCases)
pe_mod <- pe_mod %>% mutate(óbitos = na_if(deaths, 0),
                             casos = totalCases)
pe_mod <- pe_mod %>% dplyr::select(date, casos, óbitos)

# modificando o formato da base-----
pe_mod <- melt(pe_mod, id = "date")

# Criando as etiquetas-----
indices_casos = which(pe_mod$variable == "casos")
indices_obitos = which(pe_mod$variable == "óbitos")

# Últimos índices-----
ultimo_caso = indices_casos[length(indices_casos)]
ultimo_obito = indices_obitos[length(indices_obitos)]

# Criando a variavel-----
labels <- c(rep(NA, length(indices_casos)-1), formatC(pe_mod$value[ultimo_caso], big.mark = ".", format = "d"),
            rep(NA, length(indices_obitos)-1), formatC(pe_mod$value[ultimo_obito], big.mark = ".", format = "d"))
pe_mod$labels = labels


# Gráfico -----

plot_casesDeaths <- ggplot(pe_mod, aes(x = date, y = value, colour = variable)) +
  geom_line() + geom_point(size = 2) +
  scale_color_manual(values=c("blue", "red")) +
  theme_ipsum()

plot_casesDeaths

plot_mortes_casosi <- plot_casesDeaths +
  theme(axis.text.x = element_text(angle = 90)) +
  labs(title = "Casos confirmados \ne óbitos COVID-19",
       subtitle = "Pernambuco",
       caption = paste0("IRRD/PE. Fonte: https://covid.saude.gov.br/.\n Dados atualizados em ", 
                       format(ymd(hoje), "%d/%m/%Y"))
       ) +
  #scale_x_date(date_breaks = "30 days", date_labels = "%b %d") +
  xlab("Data de divulgação") +
  ylab("Quantidade de ocorrências") +
  theme(legend.title = element_blank(),
        legend.position = "bottom",
        legend.key.size = unit(0.5, 'cm'),
        legend.text = element_text(size = 6),
        axis.text = element_text(size = 5),
        axis.text.x = element_text(size = 8)) +
  geom_label_repel(label = labels,
                   show.legend = F)

plot_mortes_casosi

# Plotly -------
plot_mortes_casos2 <- ggplot(pe_mod, aes(x = date, y = value, colour = variable)) +
  geom_line() + geom_point(size = 1) +
  scale_color_manual(values=c("blue", "red")) +
  theme_ipsum() +
  theme(axis.text.x = element_text(angle = 90)) +
  labs(title = "Casos confirmados \ne óbitos COVID-19 em PE",
       subtitle = "Pernambuco",
       caption = paste0("IRRD/PE. Fonte: https://covid.saude.gov.br/.\n Dados atualizados em ", 
                       format(as.Date(hoje), "%d/%m/%Y"))) + 
  #scale_x_date(date_breaks = "20 days", date_labels = "%b %d") +
  xlab("Data de divulgação") + 
  ylab("Quantidade de ocorrências") +
  theme(legend.title = element_blank(),
        legend.position = "bottom") 
plot_mortes_casos2

#====================================================================#
##--Escala linear------------
pe_cases_deaths_linear <- ggplotly(plot_mortes_casos2)
# pe_cases_deaths_linear <- ggplotly(plot_mortes_casos2,
#                                    width = 3, height = 6)
# pe_cases_deaths_linear <- pe_cases_deaths_linear %>% 
# layout(margin = list(b=160), ##bottom margin in pixels
#       annotations = 
#         list(showarrow = F, xref='paper', yref='paper', 
#              xanchor='right', yanchor='auto', xshift=0, yshift=0,
#              font=list(size=12, color="red"))
#)
pe_cases_deaths_linear

# Salvando html: pe_cases_deaths_linear -----
htmlwidgets::saveWidget(pe_cases_deaths_linear, 
                        paste0(path, "/pe_cases_deaths_linear.html"))

### TESTE DOS GRÁFICO PARA SITE -----
plot_test <- ggplotly(plot_mortes_casos2) %>% 
  partial_bundle()

htmlwidgets::saveWidget(plot_test, 
                        paste0(path, "/pe_cases_deaths_linear_TESTE.html"))

#===============================#
##--Escala logaritmica---------
#===============================#
pe_cases_deaths_log <- plot_mortes_casosi +
  scale_y_continuous(trans = 'log10') +
  ylab("Quantidade de ocorrências\n(escala log)") 
pe_cases_deaths_logi <- ggplotly(pe_cases_deaths_log) %>% 
  partial_bundle()
pe_cases_deaths_logi

# Salvando html: pe_cases_deaths_log.html -----
htmlwidgets::saveWidget(pe_cases_deaths_logi, 
                        paste0(path, "/pe_cases_deaths_log.html"))
#===================================================================#

# Grid ------
## Escala linear -----
plot1 <- plot_mortes_casosi + 
  scale_y_continuous(breaks = seq(0, max(pe_mod$value, na.rm = TRUE), 100000)) +
  ylab("Quantidade de ocorrências\n(escala linear)")
plot1
## Escala log -------
plot2 <- plot_mortes_casosi + 
  scale_y_continuous(trans = 'log10') +
  ylab("Quantidade de ocorrências\n(escala log)") 
plot_casos_deaths_PE = grid.arrange(plot1, plot2, ncol = 2)

# Salvando em jpg ------
g <- arrangeGrob(plot1, plot2, ncol=2) 
ggsave(file= paste0(path, "/covid-19_pernambuco_confirmados_mortes.jpg"), g,
       dpi = 300, width = 14, height = 7, units = 'in') 

##=======================##
##--Novos casos por dia--##
##=======================##
# pe$media_movel_casos <- movavg(pe$newCases, 7, "s")
# pe$media_movel_casos <- round(pe$media_movel_casos, 2)
# 
# pe <- pe %>% 
#   mutate(newCases2 = totalCases - lag(totalCases, n = 1))
# plot_newcases <- ggplot(pe, aes(x = date, y = newCases, group = state)) +
#   geom_bar(stat="identity", fill = "orange", alpha = 0.9) +
#   geom_line(aes(y = media_movel_casos, color = "Média móvel (7 dias)"),
#             size = 2) +
#   scale_color_manual(values = c("darkred")) + 
#   # geom_text(aes(label=newCases), color = "black",
#   #           position=position_dodge(width=0.9), size = 2, angle = 90)+
#   theme_ipsum() +
#   theme(axis.text.x = element_text(angle = 90)) +
#   scale_x_date(date_breaks = "20 days", date_labels = "%b %d") +
#   labs(title = "Número de novos casos COVID-19 em Pernambuco",
#        subtitle = "",
#        caption = paste0("IRRD/PE. Fonte: https://covid.saude.gov.br/ \n Dados atualizados em", 
#                        format(ymd(hoje), "%d/%m/%Y"))) +
#   xlab("Data de divulgação") + ylab("Novos casos") +
#   theme(legend.position = "bottom",
#         legend.title = element_blank())
# 
# 
# plot_newcases
# ggplotly(plot_newcases)


#====================================================================#
# Plotly
# plot_new_cases_pe <- ggplot(pe, aes(x = date, group = state)) +
#   geom_bar(aes(y = newCases, 
#                color = "Novos casos"), 
#     stat="identity", 
#     alpha = 0.9,
#     fill = "orange") +
#   geom_line(aes(y = media_movel_casos, color = "Média móvel (7 dias)"),
#             size = 2) +
#   scale_color_manual(values = c("darkred", "orange")) +
#   theme_ipsum() +
#   theme(axis.text.x = element_text(angle = 90)) +
#   scale_x_date(date_breaks = "10 days", date_labels = "%b %d") +
#   labs(title = "Número de novos casos \n COVID-19 em PE",
#        subtitle = " ",
#        caption = paste0("IRRD/PE. Fonte: https://covid.saude.gov.br/ \n Dados atualizados em ", 
#                        format(ymd(hoje), "%d/%m/%Y"))) +
#   xlab("Data de divulgação") + ylab("Novos casos") +
#   theme(legend.position = "bottom",
#         legend.title = element_blank())
# plot_new_cases_pe
# plot_new_cases_pei <- ggplotly(plot_new_cases_pe, width = 3, height = 6)
# 
# plot_new_cases_pei
# htmlwidgets::saveWidget(plot_new_cases_pei, 
#                         paste0(path, "/plot_new_cases_pe.html"),
#                         selfcontained = FALSE)
#===================================================================#

# # Novos óbitos por dia
# day1 = pe$date[1]
# pe = pe %>% 
#   mutate(new.deaths = ifelse(date == day1, NA, deaths - lag(deaths, k=1)))
# 
# pe = pe %>% 
#   mutate(new.deaths = ifelse(new.deaths < 0, 0, new.deaths))
# 
# pe$new.deaths
# 
# pe$media_movel_obitos <- movavg(pe$new.deaths, 7, "s")
# pe$media_movel_obitos <- round(pe$media_movel_obitos, 2)
# 
# plot_newdeaths <- ggplot(pe, aes(x = date, y = new.deaths, group = state)) +
#   geom_bar(stat="identity", fill = "blue", alpha = 0.8) +
#   # geom_text(aes(label=new.deaths), color = "black", size = 2.5,
#   #           position=position_dodge(width=0.9), vjust=-0.25)+
#   geom_line(aes(y = media_movel_obitos, color = "Média móvel (7 dias)"),
#             size = 2) +
#   scale_color_manual(values = c("darkred")) +
#   theme_ipsum() +
#   theme(axis.text.x = element_text(angle = 90)) +
#   scale_x_date(date_breaks = "20 days", date_labels = "%b %d") +
#   labs(title = "Número de novos óbitos COVID-19 em Pernambuco",
#        subtitle = " ",
#        caption = paste0("IRRD/PE. Fonte: https://covid.saude.gov.br/\n Dados atualizados em", 
#                        format(ymd(hoje), "%d/%m/%Y"))) +
#   xlab("Data de divulgação") + ylab("Novos óbitos") +
#   theme(legend.position = "bottom",
#         legend.title = element_blank())
# 
# 
# 
# plot_newdeaths
# 
# ggplotly(plot_newdeaths)
# 
# # Salvando em jpg
# novos_casosMortes  <- arrangeGrob(plot_newcases, plot_newdeaths, ncol=2)  
# ggsave(file= paste0(path,"/", "new_cases_deaths.jpg"), novos_casosMortes,
#        dpi = 300, width = 14, height = 7, units = 'in') 

#====================================================================#
# Plotly
# plot_new_deaths_pe <- ggplot(pe, aes(x = date, group = state)) +
#   geom_bar(aes(y = new.deaths, 
#                color = "Óbitos"),
#            stat="identity", fill = "blue", alpha = 0.8) +
#   geom_line(aes(y = media_movel_obitos, color = "Média móvel (7 dias)"),
#             size = 2) +
#   scale_color_manual(values = c("darkred", "blue")) +
#   theme_ipsum() +
#   theme(axis.text.x = element_text(angle = 90)) +
#   scale_x_date(date_breaks = "20 days", date_labels = "%b %d",
#                limits = as.Date(c("2020-03-20", hoje))) +
#   labs(title = "Número de novos óbitos COVID-19 - PE",
#        subtitle = "Pernambuco",
#        caption = paste0("IRRD/PE. Fonte: Secretaria de Saúde de Pernambuco\n Dados atualizados em",
#                        format(as.Date(hoje), "%d/%m/%Y"))) +
#   xlab("Data de notificação") + ylab("Novos óbitos") +
#   theme(legend.position = "bottom",
#         legend.title = element_blank())
# 
# plot_new_deaths_pei <- ggplotly(plot_new_deaths_pe, 
#                                 width = 3, height = 6)
# 
# plot_new_deaths_pei
# htmlwidgets::saveWidget(plot_new_deaths_pei, 
#                         paste0(path, "plot_new_deaths_pe.html"),
#                         selfcontained = FALSE)
#===================================================================#


##--Top 7 - Estados---------
top5_br_df <- df %>% filter(date == max(date)) %>% 
  mutate(ranking = dense_rank(desc(totalCases)))

k <- 7

top5br <- top5_br_df %>% 
  filter(ranking <= k + 1) %>% 
  arrange(ranking) %>% 
  pull(state) %>% 
  as.character() 
top5br


#============================================================#
## Pernambuco em comparação com "SP"    "RJ"    "CE"    "PA"    "AM"    "MA"    "PE"
# Bases por estado
state1 <- filter(df, state == top5br[2])
state2 <- filter(df, state == top5br[3])
state3 <- filter(df, state == top5br[4])
state4 <- filter(df, state == top5br[5])
state5 <- filter(df, state == top5br[6])
state6 <- filter(df, state == top5br[7])
estados <- c(top5br[2], 
             top5br[3], 
             top5br[4],
             top5br[5],
             top5br[6],
             top5br[7]
             )
# Juntando as bases
pe2 <- filter(df, state == "PE") 
estados_data <- rbind(state1, state2, state3, state4, state5, state6, pe2)
estados_data$state <- factor(estados_data$state, 
                             levels = c(estados, "PE"))

# Gráfico
#================================================================#
# A function factory for getting integer y-axis values.
integer_breaks <- function(n = 5, ...) {
  fxn <- function(x) {
    breaks <- floor(pretty(x, n, ...))
    names(breaks) <- attr(breaks, "labels")
    breaks
  }
  return(fxn)
}
#================================================================#
plot_comp <- ggplot(estados_data, 
                    aes(x = date, y = totalCases, group = state)) +
  geom_line(aes(color = state)) +
  theme_ipsum() + 
  xlab("") +
  labs(title = "Casos confirmados COVID-19", 
       subtitle = "Alguns estados do Brasil",
       caption = paste0("IRRD/PE. Fonte:https://github.com/wcota/covid19br/. \nDados atualizados em",
                       format(as.Date(hoje), "%d/%m/%Y"))) +
  theme(legend.title=element_blank())+
  theme(axis.text.x = element_text(angle = 90)) 
  #scale_x_date(date_breaks = "20 days", date_labels = "%b %d",
#               limits = as.Date(c("2020-03-12", hoje))) 


plot_comp 

# Salvando em jpg
plot_comp1 = plot_comp +
  scale_y_continuous(breaks = integer_breaks()) +
  ylab("Casos confirmados\n(escala linear)")


plot_comp2 = plot_comp + scale_y_continuous(trans = 'log10') +
  ylab("Casos confirmados\n(escala log)")

#save
plot_comparacoes  <- arrangeGrob(plot_comp1, plot_comp2, ncol=2) 
ggsave(file= paste0(path, "/covid-19_comparativo_brasil.jpg"), plot_comparacoes,
       dpi = 300, width = 12, height = 5, units = 'in') 

#==============================================#
# Salvando html: plot_compare_brasil_linear.html -----
# Plotly
plot_comp1i <- ggplotly(plot_comp1, width = 3, height = 6)
plot_comp1i
htmlwidgets::saveWidget(plot_comp1i, 
                        paste0(path, "/plot_compare_brasil_linear.html"),
                        selfcontained = FALSE)

##--Escala log--##
plot_comp_log <- ggplotly(plot_comp2, width = 3, height = 6)
plot_comp_log
htmlwidgets::saveWidget(plot_comp_log, 
                        paste0(path, "/plot_compare_brasil_log.html"),
                        selfcontained = FALSE)




#==============================================#

#===============================#
# Médias móveis de óbito em PE  #
#===============================#

library(pracma) # biblioteca para calcular média móvel
library(ggplot2)

# obitos_pe <- pe_mod %>% 
#   filter(variable == "óbitos") %>% 
#   dplyr::select(value) %>% na.omit() %>% pull()
# 
# # "s" é para média móvel simples
# y <- movavg(obitos_pe, 2, "s") 
# y2 <- movavg(obitos_pe, 30, "s")
# 
# # Juntando numa date frame
# mov_avg_death <- data.frame(obitos_pe, y, y2)
# mov_avg_death <- mov_avg_death %>% 
#   mutate(x = seq(1, dim(mov_avg_death)[1]))
# 
# ggplot(mov_avg_death) +
#   geom_line(aes(x = x, y = y), color = "blue") +
#   geom_line(aes(x = x, y = y2), color = "red") +
#   geom_line(aes(x = x, y = obitos_pe), color = "green")
# 
# # Média móvel para os novos óbitos
# new_deaths <- obitos_pe - lag(obitos_pe, n = 1)
# new_deaths = na.omit(new_deaths)
# new_deaths5 <- movavg(new_deaths, 5, "s") 
# new_deaths7 <- movavg(new_deaths, 7, "s") 
# new_deathsDF <- data.frame(new_deaths, 
#                            new_deaths5, 
#                            new_deaths7)
# new_deathsDF <- new_deathsDF %>% 
#   mutate(x = seq(1, dim(new_deathsDF)[1]))
# 
# # Gráfico 1
# novas_mortes_media_movel <- ggplot(data = new_deathsDF, 
#        aes(x = x)) +
#   geom_bar(aes(y = new_deaths, 
#                fill = "óbitos"),
#            alpha = 0.5,
#            stat="identity") +
#   scale_fill_manual(values = c("red")) + 
#   #breaks deixa só nível que queremos para a legenda, neste caso, somento os óbitos
#   geom_line(aes(y = new_deaths7, color = "Média móvel"),
#             size = 2) +
#   scale_color_manual(values = c("darkred")) +
#   theme_ipsum() +
#   xlab("Dias desde o 1º óbito") +
#   ylab("Novos óbitos") +
#   theme(legend.position = "bottom",
#         axis.text.x = element_text(angle = 90),
#         legend.title = element_blank()) +
#   labs(fill="",
#        title = "Novos óbitos por COVID-19",
#        subtitle = "Pernambuco",
#        caption = paste0("Média móvel simples (7 dias). \nIRRD. Fonte: Ministério da Saúde. \nDados atualizados em", 
#                        format(as.Date(hoje), "%d/%m/%Y")))
#   
# novas_mortes_media_movel
# # # Gráfico
# # new_deathsDFi = melt(new_deathsDF, id = "x")
# # ggplot(new_deathsDF, aes(x = x, y = value, color = variable)) +
# #   geom_line()
# # 
# # # selecionando só média móvel para 5 dias 
# # new_deathsDF2 = new_deathsDF %>% 
# #   filter(variable == "new_deaths5") %>% 
# #   ggplot(aes(x = x, y = value), color = "darkblue") +
# #   geom_line() +
# #   theme_ipsum()
# # 
# # novas_mortes_media_movel = new_deathsDF2 + 
# #   labs(fill="",
# #        title = "Novas mortes no estado de PE",
# #        subtitle = "Média móvel de 5 dias",
# #        caption = paste("Média móvel simples. \nIRRD. Fonte: Ministério da Saúde. \nDados atualizados em", 
# #                        format(as.Date(today() - 1), "%d/%m/%Y")))+
# #   xlab("") +
# #   ylab("novas mortes")
# # novas_mortes_media_movel
# 
# # Salvando em jpeg
# jpeg(paste0(path, "media_movel_7_mortes_PE.jpg"), 
#      width = 6, height = 6, units = 'in', res = 300)
# novas_mortes_media_movel
# dev.off()

#==========================================================#
#--Número diário de casos em PE e média móvel de 7 dias------------
#==========================================================#
new_cases_PE <- pe %>% 
  select(date, newCases) %>% 
  mutate(moving_avg = movavg(newCases, 7, "s")) ## Adicionando média móvel de 7 dias

total_cases_PE <- pe$totalCases[length(pe$totalCases)]
library(ggplot2)
library(hrbrthemes)
casos_PE_movavg <- ggplot(data = new_cases_PE, aes(x = date)) +
  geom_bar(aes(y = newCases, color = "Casos por dia"),
           alpha = 0.7,
           fill = "#ffe6e6",
           stat="identity") +
  # geom_point(aes(y = moving_avg),
  #            color = "white", size = 3) +
  # geom_point(aes(y = moving_avg, color = "Média móvel (7 dias)")) +
  geom_line(aes(y = moving_avg, color = "Média móvel (7 dias)"), size = 2)+
  scale_color_manual(values = c("#ff9999", "#990000")) +
  theme_ipsum() + 
  theme(legend.position = "bottom",
        axis.text.x = element_text(angle = 90),
        legend.title = element_blank()) +
  labs(title = paste0("Total de casos de COVID-19 \nem Pernambuco: ", 
                     formatC(total_cases_PE, big.mark = ".", format = "d")),
       subtitle = "",
       caption = paste0("IRRD/PE. Fonte: https://covid.saude.gov.br/.\n Dados atualizados em ", 
                       format(as.Date(hoje), "%d/%m/%Y"))) + 
  #scale_x_date(date_breaks = "30 days", date_labels = "%b %d",
               #limits = as.Date(c("2020-03-25", hoje))) +
  xlab("") + 
  ylab("Casos diários") 
casos_PE_movavg


# Salvando o jpeg para casos em PE ----
cases_PE_movavgJPG <- ggplot(data = new_cases_PE, aes(x = date)) +
  geom_bar(aes(y = newCases, fill = "Casos por dia"),
           alpha = 0.7,
           stat="identity") +
  geom_line(aes(y = moving_avg, group = 1, color = "Média móvel (7 dias)"), size = 2) +
  scale_color_manual(" ", values = c("Casos por dia" = "#ffb3b3", "Média móvel (7 dias)" = "#cc0000")) +
  scale_fill_manual("", values = "#ffb3b3") +
  theme_ipsum() + 
  theme(legend.position = "bottom",
        axis.text.x = element_text(angle = 90),
        legend.title = element_blank(),
        legend.key = element_blank()) +
  labs(title = paste0("Total de casos de COVID-19 \nem Pernambuco: ", 
                      formatC(total_cases_PE, big.mark = ".", format = "d")),
       subtitle = "",
       caption = paste0("IRRD/PE. Fonte: https://covid.saude.gov.br/.\n Dados atualizados em ", 
                        format(as.Date(hoje), "%d/%m/%Y"))) + 
  scale_x_date(date_breaks = "30 days", date_labels = "%b %d",
               limits = as.Date(c("2020-03-25", hoje))) +
  xlab("") + 
  ylab("Casos diários") 
  
cases_PE_movavgJPG
# Salvando em jpeg
jpeg(paste0(path, "/media_movel_7_casos_PE.jpg"),
     width = 6, height = 6, units = 'in', res = 300)
cases_PE_movavgJPG
dev.off()


# Salvando o html cases_PE_moving_average.html -----
library(plotly)
casos_PE <- ggplotly(casos_PE_movavg)  %>% 
  partial_bundle()
casos_PE
htmlwidgets::saveWidget(casos_PE, 
                        paste0(path, "/cases_PE_moving_average.html"))


#--------------------------------------------------------------------#
#--Número diário de óbitos em PE e média móvel de 7 dias--------------
#--------------------------------------------------------------------#

new_deaths_PE <- pe %>% 
  select(date, newDeaths) %>% 
  mutate(moving_avg = movavg(newDeaths, 7, "s")) ## Adicionando média móvel de 7 dias

new_deaths_PE <- new_deaths_PE %>% 
  mutate(newDeaths = ifelse(newDeaths < 0, 0, newDeaths))

total_deaths_PE <- pe$deaths[length(pe$deaths)]

library(ggplot2)
library(hrbrthemes)
deaths_PE_movavg <- ggplot(data = new_deaths_PE, aes(x = date)) +
  geom_bar(aes(y = newDeaths, color = "Óbitos por dia"),
           fill = "#bfbfbf",
           stat="identity", alpha = 0.9)+
  # geom_point(aes(y = moving_avg),
  #            color = "white", size = 3) +
  # geom_point(aes(y = moving_avg, color = "Média móvel (7 dias)")) +
  geom_line(aes(y = moving_avg, color = "Média móvel (7 dias)"), size = 2)+
  scale_color_manual(values = c("black", "#bfbfbf")) +
  theme_ipsum() + 
  theme(legend.position = "bottom",
        axis.text.x = element_text(angle = 90),
        legend.title = element_blank()) +
  labs(title = paste0("Total de óbitos por COVID-19\nem PE: ", 
                     formatC(total_deaths_PE, big.mark = ".", format = "d")),
       subtitle = "",
       caption = paste0("IRRD/PE. Fonte: https://covid.saude.gov.br/.\n Dados atualizados em ", 
                       format(as.Date(hoje), "%d/%m/%Y"))) + 
 # scale_x_date(date_breaks = "30 days", date_labels = "%b %d",
  #             limits = as.Date(c("2020-03-25", hoje))) +
  xlab("") + 
  ylab("Óbitos diários") 
deaths_PE_movavg

# Salvando o jpeg para óbitos em PE ----
deaths_PE_movavgJPG <- ggplot(data = new_deaths_PE, aes(x = date)) +
  geom_bar(aes(y = newDeaths, fill = "Óbitos por dia"),
           alpha = 0.7,
           stat="identity") +
  geom_line(aes(y = moving_avg, group = 1, color = "Média móvel (7 dias)"), size = 2) +
  scale_color_manual(" ", values = c("Óbitos por dia" = "black", "Média móvel (7 dias)" = "black")) +
  scale_fill_manual("", values = "#bfbfbf") +
  theme_ipsum() + 
  theme(legend.position = "bottom",
        axis.text.x = element_text(angle = 90),
        legend.title = element_blank()) +
  labs(title = paste0("Total de óbitos por COVID-19\nem PE: ", 
                      formatC(total_deaths_PE, big.mark = ".", format = "d")),
       subtitle = "",
       caption = paste0("IRRD/PE. Fonte: https://covid.saude.gov.br/.\n Dados atualizados em ", 
                        format(as.Date(hoje), "%d/%m/%Y"))) + 
  #scale_x_date(date_breaks = "20 days", date_labels = "%b %d",
   #            limits = as.Date(c("2020-03-25", hoje))) +
  xlab("") + 
  ylab("Óbitos diários") 

deaths_PE_movavgJPG

# Salvando em jpeg
jpeg(paste0(path, "/media_movel_7_obitos_PE.jpg"),
     width = 6, height = 6, units = 'in', res = 300)
deaths_PE_movavgJPG
dev.off()

# Salvando o html
library(plotly)
deaths_PE <- ggplotly(deaths_PE_movavg) %>% 
  partial_bundle()  
deaths_PE
htmlwidgets::saveWidget(deaths_PE, 
                        paste0(path, "/deaths_PE_moving_average.html"))



#######################
#### Brasil ----
#######################
library(readr)
base_brasil <- read_csv("https://raw.githubusercontent.com/wcota/covid19br/master/cases-brazil-states.csv")

#"https://raw.githubusercontent.com/wcota/covid19br/master/cases-brazil-states.csv"

brasil <- filter(base_brasil, state == "TOTAL")

names(brasil)

# Corrigindo valores do Ministério da saúde-------------------
# brasil$deathsMS[length(brasil$deathsMS)] <- 232170
# brasil$totalCasesMS[length(brasil$totalCasesMS)] <- 9548079

# Atualizando por MS-------------------------------------------
brasil_mod = brasil %>%
  dplyr::select(date, totalCasesMS, deathsMS)

tail(brasil_mod)
# Atualizando por wcota----
# brasil_mod = brasil %>%
#   dplyr::select(date, totalCases, deaths)

brasil_mod = melt(brasil_mod, id = "date")
brasil_mod$variable = as.character.factor(brasil_mod$variable)

## MS----
brasil_mod = brasil_mod %>%
  mutate(var = if_else(variable == "totalCasesMS", "casos", "óbitos"))

## Wcota----
# brasil_mod = brasil_mod %>%
#   mutate(var = if_else(variable == "totalCases", "casos", "óbitos"))



# Adicionando etiqueta
# Criando as etiquetas
indices_casos = which(brasil_mod$var == "casos")
indices_obitos = which(brasil_mod$var == "óbitos")
# Últimos índices
ultimo_caso = indices_casos[length(indices_casos)]
ultimo_obito = indices_obitos[length(indices_obitos)]

labels <- c(rep(NA, length(indices_casos)-1), formatC(brasil_mod$value[ultimo_caso], big.mark = ".", format = "d"),
            rep(NA, length(indices_obitos)-1), formatC(brasil_mod$value[ultimo_obito], big.mark = ".", format = "d"))
brasil_mod$labels = labels

# Gráfico------------------------------------------------
library(hrbrthemes)
plot_casos_mortesBR <- ggplot(brasil_mod, 
                              aes(x = date, 
                                  y = value, 
                                  colour = var)) +
  geom_line() + 
  geom_point() +
  scale_color_manual(values=c("blue", "darkred")) +
  theme_ipsum() +
  theme(axis.text.x = element_text(angle = 90)) +
  labs(title = "Casos confirmados \ne óbitos COVID-19",
       subtitle = "Brasil",
       caption = paste("IRRD/PE. Fonte: https://github.com/wcota/covid19br/\n Dados atualizados em", 
                       format(hoje, "%d/%m/%Y"))) + 
  #scale_x_date(date_breaks = "20 days", date_labels = "%b %d") +
  xlab("Data da notificação") +
  theme(legend.title = element_blank(),
        legend.position = "bottom") 

plot_casos_mortesBR

plot_casos_mortesBR1 = plot_casos_mortesBR +
  geom_label_repel(label = labels, show.legend = F) 

plot_casos_mortesBR1

plot_casos_mortesBR2 = plot_casos_mortesBR +
  geom_label_repel(label = labels,
                   point.padding =  0.2,
                   nudge_x = .05,
                   nudge_y = .15,
                   show.legend = F)

plot_casos_mortesBR2

# Escala linear 
plotBR1 <- plot_casos_mortesBR2 + 
  ylab("Quantidade de ocorrências\n(escala linear)") 
plotBR1
plotBR2 <- plot_casos_mortesBR2 + 
  scale_y_continuous(trans = 'log10') +
  ylab("Quantidade de ocorrências\n(escala log)")  
plotBR2

#save
plotBR_casos_obitos  <- arrangeGrob(plotBR1, plotBR2, ncol=2) #generates g
ggsave(file= paste0(path, "/covid-19_brasil_casos_obitos.jpg"), plotBR_casos_obitos,
       dpi = 300, width = 14, height = 7, units = 'in') #saves g

#==================================================#
# Plotly -----
plotBR1i <- ggplot(brasil_mod, 
                   aes(x = date, 
                       y = value, 
                       colour = var)) +
  geom_line() + 
  geom_point() +
  scale_color_manual(values=c("blue", "darkred")) +
  theme_ipsum() +
  theme(axis.text.x = element_text(angle = 90)) +
  labs(title = "Casos confirmados e óbitos \n COVID-19 no Brasil",
       subtitle = "Brasil",
       caption = paste("IRRD/PE. Fonte: https://https://github.com/wcota/covid19br/\n Dados atualizados em", 
                       format(hoje, "%d/%m/%Y"))) + 
  #scale_x_date(date_breaks = "30 days", date_labels = "%b %d",
   #            limits = as.Date(c("2020-03-25", hoje))) +
  xlab("Data da notificação") +
  theme(legend.title = element_blank(),
        legend.position = "bottom") +
  ylab("Quantidade de ocorrências\n(escala linear)")
plotBR1i

library(plotly)
plotBR1ii <- ggplotly(plotBR1i) %>% 
  partial_bundle()
plotBR1ii
htmlwidgets::saveWidget(plotBR1ii, 
                        paste0(path, "/cases_deaths_BR.html"))



library(plotly)
### escala logaritmica
plotBR2i <- ggplot(brasil_mod, 
                   aes(x = date, 
                       y = value, 
                       colour = var)) +
  geom_line() + 
  geom_point() +
  scale_color_manual(values=c("blue", "darkred")) +
  theme_ipsum() +
  theme(axis.text.x = element_text(angle = 90)) +
  labs(title = "Casos confirmados e óbitos \n COVID-19 no Brasil",
       subtitle = "Brasil",
       caption = paste("IRRD/PE. Fonte: https://covid.saude.gov.br/\n Dados atualizados em", 
                       format(hoje, "%d/%m/%Y"))) + 
  #scale_x_date(date_breaks = "30 days", date_labels = "%b %d",
   #            limits = as.Date(c("2020-03-25", hoje))) +
  xlab("Data da notificação") +
  theme(legend.title = element_blank(),
        legend.position = "bottom") +
  scale_y_continuous(trans = 'log10') +
  ylab("Quantidade de ocorrências\n(escala log)")

plotBR2ii <- ggplotly(plotBR2i) %>% 
  partial_bundle()
plotBR2ii
htmlwidgets::saveWidget(plotBR2ii, 
                        paste0(path,"/cases_deaths_BR_log.html"))


#=============================================================#
#--Número diário de casos no Brasil e média móvel de 7 dias----------------
#=============================================================#
##--Criando vetor de novos casos MS

##---MS----
new_cases_BR <- brasil %>%
  dplyr::select(date, newCases) %>%
  mutate(moving_avg = movavg(newCases, 7, "s")) ## Adicionando média móvel de 7 dias

##---Wcota----
# new_cases_BR <- brasil %>%
#   dplyr::select(date, newCases) %>%
#   mutate(moving_avg = movavg(newCases, 7, "s")) ## Adicionando média móvel de 7 dias

# new_cases_BR <- brasil_mod_corrigido %>% 
#   mutate(newCases = totalCases - lag(totalCases))

# new_cases_BR <- new_cases_BR %>% 
#   mutate(moving_avg = movavg(newCases, 7, "s")) ## Adicionando média móvel de 7 dias


 #total_cases_BR <- brasil_mod_corrigido$totalCases[length(brasil_mod_corrigido$totalCases)]
total_cases_BR <- brasil$totalCasesMS[length(brasil$totalCasesMS)]

#total_cases_BR <- brasil_mod[193,3]

#brasil_mod[169,3] <- 3109630


library(ggplot2)
library(hrbrthemes)

cases_BR_movavg <- ggplot(data = new_cases_BR, aes(x = date)) +
  geom_bar(aes(y = newCases, fill = "Casos por dia"), stat = "identity", alpha = 0.9) +
  geom_line(aes(y = moving_avg, group = 1, color = "Média móvel (7 dias)"), size = 2)+
  scale_color_manual(" ", values = c("Casos por dia" = "#ffb3b3", "Média móvel (7 dias)" = "#cc0000")) +
  scale_fill_manual("", values = "#ffb3b3") +
  theme_ipsum() + 
  theme(legend.position = "bottom",
        axis.text.x = element_text(angle = 90),
        legend.title = element_blank(),
        legend.key = element_blank()) +
  labs(title = paste("Total de casos de COVID-19 \nno Brasil:", 
                     formatC(total_cases_BR, big.mark = ".", format = "d")),
       subtitle = "",
       caption = paste("IRRD/PE. Fonte: https://covid.saude.gov.br/.\n Dados atualizados em ", 
                       format(as.Date(hoje), "%d/%m/%Y"))) + 
  scale_x_date(date_breaks = "30 days", date_labels = "%b %d") +
  xlab("") + 
  ylab("Casos diários") 
cases_BR_movavg


cases_BR_movavg2 <- ggplot(data = new_cases_BR, aes(x = date)) +
  geom_bar(aes(y = newCases,
               color = "Casos por dia"),
           fill = "#ffb3b3",
           alpha = 0.9,
           stat="identity") +
  geom_line(aes(y = moving_avg, color = "Média móvel (7 dias)"), size = 2) +
  scale_color_manual(" ", values = c("Casos por dia" = "#ffb3b3", "Média móvel (7 dias)" = "#cc0000")) +
  theme_ipsum() +
  theme(legend.position = "bottom",
        axis.text.x = element_text(angle = 90),
        legend.title = element_blank(),
        legend.key = element_blank()) +
  labs(title = paste("Total de casos de COVID-19 \nno Brasil:",
                     formatC(total_cases_BR, big.mark = ".", format = "d")),
       subtitle = "",
       caption = paste("IRRD/PE. Fonte: https://covid.saude.gov.br/.\n Dados atualizados em ",
                       format(as.Date(hoje), "%d/%m/%Y"))) +
  #scale_x_date(date_breaks = "30 days", date_labels = "%b %d") +
  xlab("") +
  ylab("Casos diários")
cases_BR_movavg2

#--Salvando o jpg
jpeg(paste0(path, "/casos_brasil_media_movel.jpg"),
     width = 6, height = 6, units = 'in', res = 300)
cases_BR_movavg
dev.off()

# Salvando o html
library(plotly)
cases_BR_movavgPlot <- ggplotly(cases_BR_movavg2) %>% 
  partial_bundle()  
cases_BR_movavgPlot
htmlwidgets::saveWidget(cases_BR_movavgPlot, 
                        paste0(path, "/cases_BR_movavg.html"),
                        selfcontained = TRUE)



#=============================================================#
#--Número diário de óbitos no Brasil e média móvel de 7 dias----------------
#=============================================================#
# new_deaths_BR <- brasil %>% 
#   dplyr::select(date, newDeaths) %>% 
#   mutate(moving_avg = movavg(newDeaths, 7, "s")) ## Adicionando média móvel de 7 dias

## MS----
new_deaths_BR <- brasil %>%
  mutate(newDeaths = deathsMS - lag(deathsMS, n=1))

## Wcota----
# new_deaths_BR <- brasil_mod_corrigido %>% 
#   mutate(newDeaths = deaths - lag(deaths, n=1))

new_deaths_BR <- new_deaths_BR %>% 
  mutate(moving_avg = movavg(newDeaths, 7, "s"))

total_deaths_BR <- brasil$deathsMS[length(brasil$deathsMS)]
#total_deaths_BR <- brasil_mod_corrigido$deaths[length(brasil_mod_corrigido$deaths)]

#total_deaths_BR <- brasil_mod[386,3] 


## Gráfico de óbitos para jpeg---------
# deaths_BR_movavg2 <- ggplot(data = new_deaths_BR, aes(x = date)) +
#   geom_bar(aes(y = newDeaths, 
#                fill = "Óbitos por dia"),
#            stat = "identity", 
#            alpha = 0.9) +
#   geom_line(aes(y = moving_avg, group = 1, color = "Média móvel (7 dias)"), size = 2)+
#   scale_color_manual(" ", values = c("Óbitos por dia" = "#808080", "Média móvel (7 dias)" = "black")) +
#   scale_fill_manual(" ", values = "#808080") +
#   theme_ipsum() + 
#   theme(legend.position = "bottom",
#         axis.text.x = element_text(angle = 90),
#         legend.title = element_blank(),
#         legend.key = element_blank()) +
#   labs(title = paste("Total de óbitos por COVID-19 \nno Brasil:", 
#                      formatC(total_deaths_BR, big.mark = ".", format = "d")),
#        subtitle = "",
#        caption = paste("IRRD/PE. Fonte: https://covid.saude.gov.br/.\n Dados atualizados em ", 
#                        format(hoje, "%d/%m/%Y"))) + 
#   scale_x_date(date_breaks = "15 days", date_labels = "%b %d") +
#   xlab("") + 
#   ylab("Óbitos diários") 
# deaths_BR_movavg2


deaths_BR_movavg2 <- ggplot(data = new_deaths_BR, aes(x = date)) +
  geom_bar(aes(y = newDeaths, fill = "Óbitos por dia"), stat = "identity", alpha = 0.9) +
  geom_line(aes(y = moving_avg, group = 1, color = "Média móvel (7 dias)"), size = 2)+
  scale_color_manual(" ", values = c("Óbitos por dia" = "#808080", "Média móvel (7 dias)" = "black")) +
  scale_fill_manual("", values = "#808080") +
  theme_ipsum() + 
  theme(legend.position = "bottom",
        axis.text.x = element_text(angle = 90),
        legend.title = element_blank(),
        legend.key = element_blank()) +
  labs(title = paste("Total de óbitos por COVID-19 \nno Brasil:", 
                     formatC(total_deaths_BR, big.mark = ".", format = "d")),
       subtitle = "",
       caption = paste("IRRD/PE. Fonte: https://covid.saude.gov.br/.\n Dados atualizados em ", 
                       format(as.Date(hoje), "%d/%m/%Y"))) + 
  #scale_x_date(date_breaks = "30 days", date_labels = "%b %d") +
  xlab("") + 
  ylab("Óbitos diários") 
deaths_BR_movavg2

## Gráficos de óbitos para html----------
library(ggplot2)
library(hrbrthemes)
deaths_BR_movavg <- ggplot(data = new_deaths_BR, aes(x = date)) +
  geom_bar(aes(y = newDeaths, 
               color = "Óbitos por dia"),
           stat = "identity", 
           alpha = 0.9) +
  geom_line(aes(y = moving_avg, color = "Média móvel (7 dias)"), size = 2)+
  scale_color_manual(values = c("black", "#808080")) +
  theme_ipsum() + 
  theme(legend.position = "bottom",
        axis.text.x = element_text(angle = 90),
        legend.title = element_blank()) +
  labs(title = paste("Total de óbitos por COVID-19 \nno Brasil:", 
                     formatC(total_deaths_BR, big.mark = ".", format = "d")),
       subtitle = "",
       caption = paste("IRRD/PE. Fonte: https://covid.saude.gov.br/.\n Dados atualizados em ", 
                       format(hoje, "%d/%m/%Y"))) + 
  #scale_x_date(date_breaks = "30 days", date_labels = "%b %d") +
  xlab("") + 
  ylab("Óbitos diários") 
deaths_BR_movavg

#--Salvando o jpg
jpeg(paste0(path, "/obitos_brasil_media_movel.jpg"),
     width = 6, height = 6, units = 'in', res = 300)
deaths_BR_movavg2
dev.off()

# Salvando o html
library(plotly)
deaths_BR_movavgPlot <- ggplotly(deaths_BR_movavg)  %>% 
  partial_bundle()
deaths_BR_movavgPlot

# Figura Grande ----
htmlwidgets::saveWidget(deaths_BR_movavgPlot, 
                        paste0(path, "/deaths_BR_movavg.html"))


# Figura Reduzida -----
# htmlwidgets::saveWidget(deaths_BR_movavgPlot, 
#                         paste(path, "deaths_BR_movavg_teste.html"),
#                         selfcontained = FALSE)

