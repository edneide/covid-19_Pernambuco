library(dplyr)
library(ggplot2)
library(readr)
library(lubridate)
library(readr)
library(ggpubr)
library(pracma)
library(plotly)
  
Sys.setlocale("LC_TIME", "pt_PT.UTF-8")
hoje <- format(as.Date(today()-1), "%d-%m-%Y")
hoje2 <- today() - 1

setwd("~/Google Drive/Coronavirus/IRRD/Scripts_R_covid_informe")
path <- paste0(getwd(), "/", "graficos_",
                hoje2)
path

#Criando pasta----
dir.create(paste0(path, "/graficos_parte_2")) 
path2 <- paste0(path, "/graficos_parte_2/")

# BASE DE DADOS ------  
base_pe <- paste0("planilhas_de_pe/dezembro2021/", hoje, "/covid-19_Pernambuco.csv")
  
# Puxando do Git
# pe_municipios <- read.csv('https://raw.githubusercontent.com/edneide/covid-19_Pernambuco/master/covid-19_Pernambuco.csv')
pe_municipios <- read_csv(base_pe)
dim(pe_municipios)
dim(de)
  
names(pe_municipios)
  
df <- pe_municipios
class(df$classificacao_final)
  
# Convertendo em character
df <- data.frame(lapply(df, as.character), stringsAsFactors=FALSE)
# Checando a classe
class(df$classificacao_final)
  
# Classificação Final
cenarios_pe = as.data.frame(table(df$classificacao_final))
cenarios_pe
  
# Casos confirmados
table(df$srag)
  
  
# Confirmados SRAG
confirmados_srag = df %>% 
  filter(classificacao_final == "CONFIRMADO", srag == "SIM")
dim(confirmados_srag)
  
# Confirmados leves
confirmados_leves = df %>% 
  filter(classificacao_final == "CONFIRMADO", 
          srag == "NÃO",
          !is.na(geres),
          estado_de_residencia == "PERNAMBUCO")
dim(confirmados_leves)
  
dim(confirmados_leves)[1] + dim(confirmados_srag)[1]

# Evolução SRAG
  confirmados_srag <- confirmados_srag %>% 
    mutate(evolucao = ifelse(evolucao == "INTERNADO EM LEITO DE ISOLAMENTO",
                             "INTERNADO LEITO DE ISOLAMENTO", evolucao))
  evolucao = as.data.frame(table(confirmados_srag$evolucao))
  evolucao 
  
  
plot_evolucao = ggplot(evolucao, aes(x = reorder(Var1, -Freq), y = Freq, fill = Var1)) +
    geom_bar(stat = "identity", position = position_dodge()) +
    geom_text(aes(label = Freq), color = "black") + 
    labs(title = "Casos confirmados", 
         subtitle = "Evolução") +
    xlab("") + ylab("Frequência")
  plot_evolucao + coord_flip() + theme(legend.position = "none") 
  
  {# Gráfico de pizza
    bp_evolucao <- ggplot(evolucao, aes(x = "", y = Freq, fill = Var1)) +
      geom_bar(width = 1, stat = "identity", color = "white")
    bp_evolucao
    # Pie chart
    pie_evolucao <- bp_evolucao + coord_polar("y", start=0)
    # Customize
    blank_theme <- theme_minimal()+
      theme(
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        panel.border = element_blank(),
        panel.grid=element_blank(),
        axis.ticks = element_blank(),
        plot.title=element_text(size=14, face="bold")
      )
    # Apply blank theme
    library(scales)
    plot_evolucao = pie_evolucao +  blank_theme +
      theme(axis.text.x=element_blank()) 
    
    # Compute the position of labels
    data = evolucao
    data <- data %>% 
      arrange(desc(Var1)) %>%
      mutate(prop = Freq / sum(data$Freq) *100) %>%
      mutate(ypos = cumsum(prop)- 0.5*prop )
    
    # Basic piechart
    names(data)[1] <- "Evolução"
    evolucao_pie <- ggplot(data, aes(x="", y=prop, fill=Evolução)) +
      geom_bar(stat="identity", width=1, color="white") +
      coord_polar("y", start=0) +
      theme_void() + 
      geom_text(aes(y = ypos, 
                    label = paste(round(prop,1), "%", sep = "")), 
                color = "black", size=2) +
      scale_fill_brewer(palette="Set1") +  
      theme(legend.title = element_blank())
    
    evolucao_pie = evolucao_pie + 
      ggtitle("Evolução dos casos SRAG confirmados para \nCOVID-19 em Pernambuco") + 
      labs(caption = paste("Número de casos SRAG confirmados = ", 
                           dim(confirmados_srag)[1], "\nDados atualizados em",
                           format(dmy(hoje), "%d/%m/%Y")))
    
    evolucao_pie}
  
  # jpeg(paste(path2, "evolucao_pie_pe.jpg", sep = ""), 
  #      width = 6, height = 4, units = 'in', res = 300)
  # evolucao_pie
  # dev.off()
  
  ##--Legenda fora--##
  library(ggplot2)
  library(ggrepel)
  p <- ggplot(data, aes(1, prop, fill = Evolução)) +
    geom_col(color = 'white', 
             position = position_stack(reverse = FALSE), 
             show.legend = TRUE) +
    scale_fill_brewer(palette="Set1") +
    geom_text_repel(aes(x = 1.4, y = ypos, 
                        label = paste(round(prop,1), "%", sep = "")), 
                    nudge_x = .3, 
                    segment.size = .7, 
                    show.legend = FALSE) +
    coord_polar('y', start = 0) +
    theme_void()
  
  p
  
  evolucao_plot = p + ggtitle("Evolução dos casos SRAG confirmados para \nCOVID-19 em Pernambuco") + 
    labs(caption = paste("Número de casos SRAG confirmados = ", 
                         dim(confirmados_srag)[1], "\nDados atualizados em",
                         format(dmy(hoje), "%d/%m/%Y")))
  
  evolucao_plot
  
jpeg(paste0(path2, "evolucao_pie_pe.jpg"), 
       width = 6, height = 4, units = 'in', res = 300)
evolucao_plot
dev.off()
##-----------------------------------------##
  
  ##-----------------##
  ##--Sexo-----------##
  ##-----------------##
  sexo = as.data.frame(table(confirmados_srag$sexo))
  sexo
  
  # Retirando Ignorado
  #sexo[1,2] <- 11791
  ##sexo
  names(sexo) <- c("Sexo", "value")
  sexo
  
  ##--Sexo - Casos Leves --##
  sexoleve = as.data.frame(table(confirmados_leves$sexo))
  sexoleve
  
  ##--Retirando o ignorado:
  sexo_leve_ig <- sexoleve[2,2]
  
  sexo_leve_ig_perc <- paste0("Ignorado ",
                              sexo_leve_ig, 
                              " (", 
                              round(100*sexo_leve_ig/sum(sexoleve$Freq), 2), 
                              "%", ")")
  
  sexoleve <- sexoleve[-2,]
  sexoleve
  names(sexoleve) <- c("Sexo", "value")
  
  ##Corrigindo informação
  #sexoleve[1,2] <- 58700
  
  # Customize
  {## Código novo para o gráfico de pizza 
    # Gráfico de pizza
    sexo_bp <- ggplot(sexo, aes(x = "", y = value, fill = Sexo)) +
      geom_bar(width = 1, stat = "identity", color = "white")
    
    
    # Pie chart
    pie_sexo <- sexo_bp + coord_polar("y", start=0)
    blank_theme <- theme_minimal()+
    theme(
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
      panel.border = element_blank(),
      panel.grid=element_blank(),
      axis.ticks = element_blank(),
      plot.title=element_text(size=14, face="bold")
    )
  
  # Apply blank theme
  library(scales)
  pie_sexo = pie_sexo +  blank_theme +
    theme(axis.text.x=element_blank()) 
  pie_sexo
  
  # Compute the position of labels
  data = sexo
  data <- data %>% 
    arrange(desc(Sexo)) %>%
    mutate(prop = value / sum(data$value) *100) %>%
    mutate(ypos = cumsum(prop)- 0.5*prop )
  
  
  
  # Basic piechart
  sexo_pizza <- ggplot(data, aes(x="", y=prop, fill=Sexo)) +
    geom_bar(stat="identity", width=1, color="black") +
    coord_polar("y", start=0) +
    theme_void() + 
    theme(legend.position="bottom") +
    geom_text(aes(y = ypos, label = paste0(value, "\n", "(", round(prop,1), "%", ")")), 
              color = "white", size=6) +
    scale_fill_brewer(palette="Set1")
  
  sexo_pizza = sexo_pizza + 
    ggtitle("Sexo - Casos confirmados de SRAG para\n COVID-19 em Pernambuco") +
    labs(caption = paste("Total de casos SRAG confirmados = ", 
                         dim(confirmados_srag)[1], "\n Dados atualizados em",
         format(dmy(hoje), "%d/%m/%Y"))) +
    theme(legend.title = element_blank())
  
  sexo_pizza
  }
  
  # Salvando em jpg
  jpeg(paste0(path2, "sexo_pe.jpg"), 
       width = 4, height = 4, units = 'in', res = 300)
  sexo_pizza
  dev.off()
  
  ##---------------------------------##
  #--Gráfico de pizza - casos leves--##
  ##---------------------------------##
  {sexo_bpleve <- ggplot(sexoleve, aes(x = "", y = value, fill = Sexo)) +
    geom_bar(width = 1, stat = "identity", color = "white")
  sexo_bpleve
  
  # Pie chart
  pie_sexoleve <- sexo_bpleve + coord_polar("y", start=0)
  pie_sexoleve
  
  
  # Customize
  blank_theme <- theme_minimal()+
    theme(
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
      panel.border = element_blank(),
      panel.grid=element_blank(),
      axis.ticks = element_blank(),
      plot.title=element_text(size=14, face="bold")
    )
  
  # Apply blank theme
  library(scales)
  pie_sexoleve = pie_sexoleve +  blank_theme +
    theme(axis.text.x=element_blank()) 
  pie_sexoleve
  
  # Compute the position of labels
  data = sexoleve
  data <- data %>% 
    arrange(desc(Sexo)) %>%
    mutate(prop = value / sum(data$value) *100) %>%
    mutate(ypos = cumsum(prop)- 0.5*prop )
  
  
  
  # Basic piechart
  sexo_pizza_leve <- ggplot(data, aes(x="", y=prop, fill=Sexo)) +
    geom_bar(stat="identity", width=1, color="black") +
    coord_polar("y", start=0) +
    theme_void() + 
    theme(legend.position="bottom") +
    geom_text(aes(y = ypos, label = paste0(value, "\n", "(", round(prop,1), "%", ")")), 
              color = "white", size=6) +
    scale_fill_brewer(palette="Set1")
  
  sexo_pizza_leve = sexo_pizza_leve + 
    ggtitle("Sexo - Casos confirmados leves de \nCOVID-19 em Pernambuco") +
    labs(caption = paste(sexo_leve_ig_perc, "\nTotal de casos leves confirmados = ", 
                         dim(confirmados_leves)[1], "\nDados atualizados em",
         format(dmy(hoje), "%d/%m/%Y"))) +
    theme(legend.title = element_blank())
  
  sexo_pizza_leve
  }
  
  # Salvando em jpg
  jpeg(paste0(path2, "sexo_pe_leve.jpg"), 
       width = 4, height = 4, units = 'in', res = 300)
  sexo_pizza_leve
  dev.off()
  
##---------------------------------------------------------------------------##
# Faixa etária---------------------------------------------------------------
##---------------------------------------------------------------------------##
dim(confirmados_srag)
confirmados_srag$idade = as.numeric(confirmados_srag$idade)
summary(confirmados_srag$idade)
round(sd(confirmados_srag$idade, na.rm = TRUE),2)
  
## Recategorizando a idade -----------------------------------------------------
  
  # casos srag
  class(confirmados_srag$idade)
  confirmados_srag = confirmados_srag %>% 
    mutate(idade_cat = if_else(idade < 10, "0-9",
                               if_else(between(idade, 10, 19), "10-19",
                                       if_else(between(idade, 20, 29), "20-29", 
                                               if_else(between(idade, 30, 39), "30-39",
                                                       if_else(between(idade, 40, 49), "40-49", 
                                                               if_else(between(idade, 50, 59), "50-59", 
                                                                       if_else(between(idade, 60, 69), "60-69", 
                                                                               if_else(between(idade, 70, 79), "70-79", "80 e mais"))))))))) 
  #casos leves
  confirmados_leves$idade = as.numeric(confirmados_leves$idade)
  class(confirmados_leves$idade)
  confirmados_leves = confirmados_leves %>% mutate(idade_cat = if_else(idade < 10, "0-9",
                                                                       if_else(between(idade, 10, 19), "10-19",
                                                                               if_else(between(idade, 20, 29), "20-29", if_else(between(idade, 30, 39), "30-39",
                                                                                                                                if_else(between(idade, 40, 49), "40-49", if_else(between(idade, 50, 59), "50-59", if_else(between(idade, 60, 69), "60-69", if_else(between(idade, 70, 79), "70-79", "80 e mais"))))))))) 
  idadeCategorialeve = as.data.frame(table(confirmados_leves$idade_cat))
  idadeCategorialeve
  
  ##--Corrigindo valor
  #idadeCategorialeve[3, 2] <- 18487
  #idadeCategorialeve
  
  plot_idadecatleve = ggplot(idadeCategorialeve, aes(x = Var1, 
                                                     y = Freq)) +
    geom_bar(stat = "identity", position = position_dodge(), fill = "orange",
             alpha = 0.85) +
    geom_text(aes(label = Freq), color = "black") +
    ggtitle("Faixa etária dos casos leves confirmados para COVID-19\nem Pernambuco") + 
    theme_light() +
    xlab("") + ylab("Frequência") +
    labs(caption = paste("IRRD-PE. Fonte: Secretaria de Saúde de PE.\nDados atualizados em", 
                         format(dmy(hoje), "%d/%m/%Y")))
  plot_idadecatleve
  jpeg(paste0(path2, "barra_idade_leve.jpg"), 
       width = 6, height = 4, units = 'in', res = 300)
  plot_idadecatleve
  dev.off()
  
  ##---------------------------------##
  ## idade srag
  ##---------------------------------##
  idadeCategoria = as.data.frame(table(confirmados_srag$idade_cat))
  idadeCategoria
  
  ##--Correção--##
  #idadeCategoria[1,2] <- 497
  #idadeCategoria[7,2] <- 3797
  #idadeCategoria
  
  plot_idadecat = ggplot(idadeCategoria, aes(x = Var1, y = Freq)) +
    geom_bar(stat = "identity", position = position_dodge(), fill = "lightblue",
             alpha = 0.9) +
    geom_text(aes(label = Freq), color = "black") +
    ggtitle("Faixa etária dos casos confirmados SRAG para COVID-19\nem Pernambuco") + 
    theme_light() +
    xlab("") + ylab("Frequência")+
    labs(caption = "") +
    labs(caption = paste("IRRD. Fonte: Secretaria de Saúde de PE.\nDados atualizados em", 
                         format(dmy(hoje), "%d/%m/%Y")))
  plot_idadecat
  
  jpeg(paste0(path2, "barra_idade.jpg"), 
       width = 6, height = 4, units = 'in', res = 300)
  plot_idadecat
  dev.off()
  
  
  
# Óbitos---------------------------------
df_obito <- confirmados_srag %>% 
    filter(evolucao == "ÓBITO")
dim(df_obito)[1]
  
  
## letalidade -----------------------------------
paste("letalidade = ", round(100*dim(df_obito)[1]/(dim(confirmados_srag)[1]+dim(confirmados_leves)[1]),2), "%", sep = "")
  
## Sexo-----------------------------------------
round(100*table(df_obito$sexo)/sum(table(df_obito$sexo)), 2)
  
# Sumário da Idade --------------------------------------
summary(as.numeric(df_obito$idade))
sd(df_obito$idade, na.rm = TRUE) %>% round(digits = 2)
  
# Porcentagem de idosos ---------------------------------
  df_obito = df_obito %>% 
    mutate(idosos = if_else(idade >= 60, "Idoso", "Não Idoso"))
  
props = as.data.frame(table(df_obito$idosos)) %>% 
    mutate(prop = round(100*Freq/sum(Freq), 2))
props
  
dim(confirmados_leves)
  
## Gráfico de barras da idade----
idadeobito <- as.data.frame(table(df_obito$idade_cat))
  idadeobito
  
  #-- Corrigindo o NA--##
  #idadeobito[1,2] <- 45
  idadeobito
  
  {plot_idadecatobito = ggplot(idadeobito, aes(x = Var1, 
                                              y = Freq)) +
    geom_bar(stat = "identity", position = position_dodge(), fill = "darkred",
             alpha = 0.75) +
    geom_text(aes(label = Freq), color = "black") +
    ggtitle("Faixa etária dos óbitos SRAG confirmados para COVID-19\nem Pernambuco") + 
    theme_bw() +
    xlab("") + ylab("Frequência") +
      labs(caption = paste("IRRD. Fonte: Secretaria de Saúde de PE.\nDados atualizados em", 
                           format(dmy(hoje), "%d/%m/%Y")))
  plot_idadecatobito}
  
  jpeg(paste0(path2, "barra_idadeobito.jpg"), 
       width = 6, height = 4, units = 'in', res = 300)
  plot_idadecatobito
  dev.off()
  
##---------------------------------##
##--Confirmados SRAG e Leves-------
##---------------------------------##
#confirmados_geral = df %>% 
#  filter(classificacao_final == "CONFIRMADO")
#dim(confirmados_geral)
##---------------------------------##
confirmados_geral <- rbind(confirmados_srag,
                            confirmados_leves)
  
dim(confirmados_geral)




##---------------------------------##
##--Histograma de sintomas---------##
##---------------------------------##
  df_sintomas <- as.data.frame(table(confirmados_geral$data_dos_primeiros_sintomas))
  names(df_sintomas) <- c("data", "casos")
  sum(df_sintomas$casos)
  df_sintomas
  
  class(df_sintomas$data)
  
  df_sintomas$data = dmy(df_sintomas$data)
  class(df_sintomas$data)
  
  head(df_sintomas$data)
  tail(df_sintomas$data)
  
  #df_sintomas$data = ymd(df_sintomas$data)
  df_sintomas$data = as.Date(df_sintomas$data)
  head(df_sintomas$data)
  
  #df_sintomas$data = as.Date(df_sintomas$data, format = "%Y-%m-%d")
  class(df_sintomas$data)
  
  df_sintomas <- df_sintomas %>% 
    filter(data <= as.Date(today()-1),
           data >= as.Date("2020-01-15"))   
  
  #library(ggdark)
  library(hrbrthemes)
  plot_newcases <- ggplot(df_sintomas, aes(x = data, y = casos)) +
    geom_bar(stat="identity", fill = "orange", alpha = 0.9) +
   theme_ipsum() +
    theme(axis.text.x = element_text(angle = 90)) +
    labs(title = "Número de novos casos COVID-19",
         subtitle = "Pernambuco",
         caption = paste("IRRD/PE. Fonte: Secretaria de Saúde de Pernambuco\n Dados atualizados em", 
                         format(dmy(hoje), "%d/%m/%Y"))) +
    xlab("Data do início dos sintomas") + ylab("Novos casos") +
    scale_x_date(date_breaks = "15 days", date_labels = "%b %d",
                 limits = as.Date(c(min(df_sintomas$data), max(df_sintomas$data)))) +
    scale_y_continuous(breaks = seq(0, max(df_sintomas$casos), by =200))
  
  
  plot_newcases
  
  jpeg(paste0(path2, "histograma_casos_sintomas.jpg"), 
       width = 7, height = 5, units = 'in', res = 300)
  plot_newcases
  dev.off()
  
  ##--Salvando em html--##
  # Salvando o html
  library(plotly)
  plot_newcases2 <- ggplotly(plot_newcases)  
  plot_newcases2
  htmlwidgets::saveWidget(plot_newcases2, 
                          paste0(path2, "histograma_casos_sintomas.html"))
  
  
  
  #--------------------------------------------#
  ##--Em inglês--##
  #--------------------------------------------#
  # Sys.getlocale()
  # Sys.setlocale("LC_TIME", "en_US.UTF-8")
  # plot_newcases_eng <- ggplot(df_sintomas, aes(x = data, y = casos)) +
  #   geom_bar(stat="identity", fill = "orange", alpha = 0.9) +
  #   theme_ipsum() +
  #   theme(axis.text.x = element_text(angle = 90)) +
  #   labs(title = "Number of new cases of COVID-19",
  #        subtitle = "Pernambuco - Brazil") +
  #   xlab("Date from onset of symptons") + ylab("Novos casos") +
  #   scale_x_date(date_breaks = "7 days", date_labels = "%b %d",
  #                limits = as.Date(c(min(df_sintomas$data), max(df_sintomas$data)))) +
  #   scale_y_continuous(breaks = seq(0, max(df_sintomas$casos), by =200))
  # 
  # 
  # plot_newcases_eng
  
  ##---------------------------##
  ##--Inserindo médias móveis----
  ##---------------------------##
  # df_sintomasi <- df_sintomas %>% 
  #   arrange(data)
  # 
  # df_sintomasi <- df_sintomasi %>% 
  #   dplyr::mutate(media_movel = rollmean(casos, k = 7, align = "right", fill = NA))
  # 
  # dados <- df_sintomasi[1:157,]
  # plot_newcases_engi <- ggplot(dados, aes(x = data)) +
  #   geom_bar(aes(y = casos),
  #            stat="identity", 
  #            fill = "orange", 
  #            alpha = 0.9) +
  #   geom_line(aes(y = media_movel),
  #             color = "black", 
  #             size = 1.1, 
  #             linetype = "dotdash") +
  #   theme_ipsum() +
  #   theme(axis.text.x = element_text(angle = 90)) +
  #   labs(title = "Number of new cases of COVID-19",
  #        subtitle = "Pernambuco - Brazil") +
  #   xlab("Date from onset of symptons") + ylab("New cases") +
  #   scale_x_date(date_breaks = "7 days", date_labels = "%b %d") +
  #   scale_y_continuous(breaks = seq(0, max(df_sintomas$casos), by =200))
  # 
  # 
  # plot_newcases_engi
  
  # ##--Salvando plot
  # jpeg(paste0(path2, "plot_newcases_eng.jpg"),
  #      width = 7, height = 5, units = 'in', res = 300)
  # plot_newcases_engi
  # dev.off()
  
  
  
  # plot_newcases_eng <- ggplot(df_sintomas, aes(x = data, y = casos)) +
   #   geom_bar(stat="identity", fill = "orange", alpha = 0.9) +
   #   theme_ipsum() +
   #   theme(axis.text.x = element_text(angle = 45)) +
   #   labs(title = "New cases vs. onset of symptoms",
   #        subtitle = "Pernambuco - Brazil") +
   #   xlab("Onset of symptoms") + ylab("New cases") +
   #   scale_x_date(date_breaks = "8 days", date_labels = "%b %d",
   #                limits = as.Date(c("2020-02-27", "2020-07-01"))) +
   #   coord_cartesian(ylim = c(0, 1500))
   #   #scale_y_continuous(breaks = seq(0, 1500, by =200))
   #   #scale_y_continuous(breaks = seq(0, max(df_sintomas$casos), by =200))
   # 
   # 
   # plot_newcases_eng
  
  ##--Salvando em jpg--##
  # jpeg(paste0(path2, "plot_newcases_eng.jpg", sep = ""),
  #      width = 7, height = 5, units = 'in', res = 300)
  # plot_newcases_eng
  # dev.off()
  
  ##--Inserindo média móvel 
  library(zoo)
  df_sintomas_media_movel <- df_sintomas %>% 
    mutate(media_movel = rollmean(casos, k = 7, align = "right", fill = NA))
  
  ggplot(pe, aes(x = date, y = newCases, group = state)) +
    geom_bar(stat="identity", fill = "orange", alpha = 0.9) +
    geom_line(aes(y = media_movel_casos, color = "Média móvel"),
              size = 2) +
    scale_color_manual(values = c("darkred")) + 
    # geom_text(aes(label=newCases), color = "black",
    #           position=position_dodge(width=0.9), size = 2, angle = 90)+
    theme_ipsum() +
    theme(axis.text.x = element_text(angle = 90)) +
    scale_x_date(date_breaks = "7 days", date_labels = "%b %d",
                 limits = as.Date(c("2020-03-11", hoje))) +
    labs(title = "Número de novos casos COVID-19",
         subtitle = "Pernambuco",
         caption = paste("IRRD/PE. Fonte: https://covid.saude.gov.br/ \n Dados atualizados em", 
                         format(as.Date(hoje), "%d/%m/%Y"))) +
    xlab("Data de divulgação") + ylab("Novos casos") +
    theme(legend.position = "bottom",
          legend.title = element_blank())
  
  
  #--------------------------------------------#
  # antes <- df_sintomas %>% 
  #   filter(data < "2020-05-18")
  # 
  # depois <- df_sintomas %>% 
  #   filter(data > "2020-05-18")
  # 
  # summary(antes)
  # 
  # summary(depois)
  # 
  # wilcox.test(antes$casos, depois$casos)
  #--------------------------------------------#
  
  names(pe_municipios)[2] <- "data"
  class(pe_municipios$data)
  pe_municipios$data <- as.character.factor(pe_municipios$data)
  pe_municipios$data <- ymd(pe_municipios$data)
  class(pe_municipios$data)
  
  # Classificação final de notificados
  
  {
    class_final_df <- table(pe_municipios$data, 
                            pe_municipios$classificacao_final)
    class_final_df <- as.data.frame(class_final_df)
    
    names(class_final_df) <- c("data", "classificacao", "freq")
    
    class(class_final_df$data)
    class_final_df$data <- as.character.factor(class_final_df$data)
    class_final_df$data <- as.POSIXct(class_final_df$data, format = "%Y-%m-%d")
    class(class_final_df$data)
    class_final_df$data = as.Date(class_final_df$data)
  }
  
  {
    table(class_final_df$classificacao)
    class(class_final_df$classificacao)
    class_final_df$classificacao <- as.character.factor(class_final_df$classificacao)
    table(class_final_df$classificacao)
  }
  
  {class_final_df <- class_final_df %>% 
      mutate(classificacao2 = if_else(classificacao == "DESCARTADO NO FORMSUS"|
                                        classificacao == "DESCARTADONOFORMSUS", 
                                      "DESCARTADO", 
                                      if_else(classificacao == "EM INVESTIGACAO", 
                                              "EM INVESTIGAÇÃO", classificacao)))
    class_final_plot = ggplot(class_final_df, 
                              aes(x = data, y = freq, fill = classificacao2)) +
      geom_bar(stat = "identity", alpha = 0.9) +
      xlab("Data da notificação") + 
      ylab("Frequência") +
      theme_ipsum() +
      theme(legend.title = element_blank(),
            legend.position = "bottom",
            axis.text.x = element_text(angle = 90, size = 10),
            legend.text = element_text(size = 7.5)) +
      scale_x_date(date_breaks = "7 days", date_labels = "%b %d",
                   limits = as.Date(c("2020-03-17", today()-1)))+
      ggtitle("Classificação final dos casos notificados\n em PE" ) +
      labs(caption = paste("IRRD/PE. Fonte: Secretaria de Saúde de Pernambuco.\nDados atualizados em",
                           format(dmy(hoje), "%d/%m/%Y"))) 
    
    
    
    class_final_plot}
  
  jpeg(paste0(path2, "class_final_notificados_PE.jpg"), 
       width = 10, height = 6, units = 'in', res = 300)
  class_final_plot 
  dev.off()
  
  
#### Evolução dos casos confirmados ####
  
  confirmados_geral <- rbind(confirmados_leves, confirmados_srag)
  
  names(confirmados_geral)[2] <- "data"
  class(confirmados_geral$data)
  confirmados_geral$data <- ymd(confirmados_geral$data)
  class(confirmados_geral$data)
  
  
  conf_evo = table(confirmados_geral$data, confirmados_geral$evolucao)
  conf_evo = as.data.frame(conf_evo)
  names(conf_evo) <- c("data", "evolucao", "freq")
  conf_evo <- conf_evo %>% 
    mutate(evolucao = ifelse(evolucao == "INTERNA NO HOSPITAL MUNICIPAL" | 
                                evolucao == "INTERNADO LEITO DE ISOLAMENTO", 
                              "INTERNADO ISOLAMENTO", if_else(evolucao == "RECUPRERADO", "RECUPERADO",as.character(evolucao))))
  
  table(conf_evo$evolucao)
  
  
  
  ## Eliminando as linhas com "#N/DISP"
  #indices_ND = which(conf_evo$evolucao == "#N/DISP")
  #indices_ND
  #conf_evo = conf_evo[-indices_ND,]
  #table(conf_evo$evolucao)
  ##
  
  
  class(conf_evo$data)
  conf_evo$data <- as.character.factor(conf_evo$data)
  conf_evo$data <- as.POSIXct(conf_evo$data, format = "%Y-%m-%d")
  class(class_final_df$data)
  conf_evo$data = as.Date(conf_evo$data)
  
  ###
  conf_evo = conf_evo %>% 
    mutate(evolucao2 = if_else(evolucao == "INTERNA NO HOSPITAL MUNICIPAL", "INTERNADO LEITO DE ISOLAMENTO", 
                               if_else(evolucao == "RECUPRERADO", "RECUPERADO", evolucao)))
  
  # Gráfico
  evolucao_conf = ggplot(conf_evo, 
                         aes(x = data, y = freq, fill = evolucao2)) +
    geom_bar(stat = "identity", alpha = 0.9) +
    xlab("Data da notificação") + 
    ylab("Frequência") +
    theme_ipsum() +
    theme(legend.title = element_blank(),
          legend.position = "bottom",
          axis.text.x = element_text(angle = 90),
          legend.text = element_text(size = 7)) +
    scale_x_date(date_breaks = "20 days", date_labels = "%b %d",
                 limits = as.Date(c("2020-03-17", dmy(hoje))))+
    ggtitle("Evolução dos casos confirmados para COVID-19 \nem PE" ) +
    labs(caption = paste("IRRD/PE. Fonte: Secretaria de Saúde de Pernambuco.\nDados atualizados em", 
                         format(dmy(hoje), "%d/%m/%Y"))) 
  
  evolucao_conf
  
  jpeg(paste0(path2, "evolucao_confirmados_PE.jpg"), 
       width = 10, height = 6, units = 'in', res = 300)
  evolucao_conf
  dev.off()
  

  ##------------------##
  ###### Raça/Cor ######
  ##------------------##
  names(confirmados_geral)
  confirmados_geral$raca %>% unique()
  
  # confirmados_geral <- confirmados_geral %>% 
  #   mutate(racai = if_else(raca == "INDIGENA", "INDÍGENA",
  #                          if_else(raca == "#N/DISP", "IGNORADO",
  #                                  if_else(raca == "DEPLICIDADE N NOT", "IGNORADO",
  #                          as.character(raca)))))
  
  
  
  table(confirmados_geral$raca)
  
  raca_corDF <- as.data.frame(table(confirmados_geral$raca))
  raca_corDF
  names(raca_corDF) <- c("category", "count")
  
  raca_corDF$category <- as.character.factor(raca_corDF$category)
  
  
    
  
  
  # Compute percentages
  data <- raca_corDF
  data$fraction <- data$count / sum(data$count)
  
  # Compute the cumulative percentages (top of each rectangle)
  data$ymax <- cumsum(data$fraction)
  
  # Compute the bottom of each rectangle
  data$ymin <- c(0, head(data$ymax, n=-1))
  
  # Compute label position
  data$labelPosition <- (data$ymax + data$ymin) / 2
  
  # Compute a good label
  data$label <- paste0(data$category, "\n ", round(100*data$fraction,2), "%")
  data$label2 <- paste0(round(100*data$fraction,2), "%")
  # The palette with grey:
  cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
  # Make the plot
  raca_cor_plot <- ggplot(data, aes(ymax=ymax, ymin=ymin, xmax=4, xmin=3, fill=category)) +
    geom_rect() +
    geom_text(x = 1.5, 
              aes(y=labelPosition, 
                  label=label, color=category), 
              size=4) + # x here controls label position (inner / outer)
    scale_fill_manual(values = cbPalette) +
    scale_color_manual(values=cbPalette) +
    coord_polar(theta="y") +
    xlim(c(-1, 4)) +
    theme_void() +
    theme(legend.position = "none")
  
  raca_cor_plot
  
  ##
  labels <- data$label2
  raca_cor_plot <- ggdonutchart(data, "count", label = labels,
               fill = "category", color = "white") +
    theme(legend.title = element_blank(),
          legend.position = "bottom") +
    labs(fill="",
         title = "Raça/Cor \n(COVID-19 em PE)",
         subtitle = "",
         caption = paste("IRRD-PE. Fonte:SES-PE.\nDados atualizados em", 
                         format(dmy(hoje), "%d/%m/%Y")))
  
  
  ###################################
  # Salvando em jpg
  #path <- "/Users/edneideramalho/Google Drive/Coronavirus/IRRD/Informes e relatórios/graficos 28-04-2020/"
  jpeg(paste0(path2, "raca_cor_plot.jpg"), 
       width = 15, height = 9, units = 'in', res = 300)
  raca_cor_plot
  dev.off()
  
  ### Gráfico de Barras

  ##=============================================##
  ##--Gráfico de novos óbitos por data de óbito--##
  ##============================================##
  ##--Filtrando os óbitos--##
  names(confirmados_geral)
  confirmados_geral$evolucao %>% unique()
  
  obitos_geral <- confirmados_geral[,-1] %>% 
    filter(evolucao == "ÓBITO")
  
  obitos_geral$data_do_obito %>% class()
  dmy(obitos_geral$data_do_obito[1])
  obitos_geral$data_do_obito <- dmy(obitos_geral$data_do_obito)
  table_obito <- table(obitos_geral$data_do_obito)
  head(table_obito)
  
  ##--Convertendos em data frame--##
  df_obito <- as.data.frame(table_obito)
  names(df_obito) <- c("data", "obitos")
  head(df_obito)
  
  ##--Checando se a data está no formato correto--##
  #class(df_obito$data)
  #df_obito$data <- as.character.factor(df_obito$data)
  #class(df_obito$data)
  #head(df_obito$data)
  #df_obito$data_mod <- dmy(df_obito$data)
  #head(df_obito$data_mod)
  #df_obito <- df_obito %>% 
  #  arrange(data_mod)
  
  ##--Adicionando média móvel--##
  media_movel_obito <- movavg(df_obito$obitos, 7, "s") 
  df_obito <- df_obito %>% 
    mutate(media_movel = media_movel_obito)
  
  ##-Gráfico--##
  plot_obitos_dt_ob <- ggplot(df_obito, aes(x = as.Date(data))) +
    geom_bar(aes(y = obitos, fill = "Óbitos"),
             stat = "identity", alpha = 0.9) +
    scale_fill_manual(values = c("black")) +
    geom_line(aes(y = media_movel, color = "Média móvel"),
              size = 2) +
    scale_color_manual(values = c("orange")) +
    theme_ipsum() +
    scale_x_date(date_breaks = "20 days", date_labels = "%b %d") +
    ylab("Óbitos") +
    xlab("Data do óbito") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(title = "Óbitos diários por data do óbito \nCOVID-19/Pernambuco",
         caption = paste("IRRD-PE. Fonte: SES-PE.\nDados atualizados em:", hoje)) +
    theme(legend.position = "bottom",
          axis.text.x = element_text(angle = 90),
          legend.title = element_blank())
  plot_obitos_dt_ob
  
  
  # ##--sem a linha branca--##
  plot_obitos_dt_ob2 <- ggplot(df_obito, aes(x = as.Date(data))) +
     geom_bar(aes(y = obitos, color = "Óbitos"),
              fill = "black",
              stat = "identity", alpha = 0.85) +
     geom_line(aes(y = media_movel, color = "Média móvel"),
               size = 2) +
     scale_color_manual(values = c("orange", "black")) +
     theme_ipsum() +
     ylab("Óbitos") +
     xlab("Data do óbito") +
     theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
     labs(title = "Óbitos diários por data do óbito \nCOVID-19/Pernambuco",
          caption = paste("IRRD-PE. Fonte: SES-PE.\nDados atualizados em:", 
                          format(as.Date(today()-1), "%d/%m/%Y"))) +
     theme(legend.position = "bottom",
           axis.text.x = element_text(angle = 45),
           legend.title = element_blank())
   
   plot_obitos_dt_ob2
  
   ##--Salvando em jpg--##
  jpeg(paste0(path2,"obitos_pe_data_obito.jpg"), width = 8, height = 7, 
       units = "in", res = 300)
  plot_obitos_dt_ob
  dev.off()
  ##--Convertendo em html--##
  obitos_por_data <- ggplotly(plot_obitos_dt_ob2)
  obitos_por_data
  htmlwidgets::saveWidget(obitos_por_data, 
                          paste0(path2, "obitos_por_data.html"))
  
  
  ##-----------------------------------------------##
  ###### Hospitalizados: leitos e UTI por data ######
  ##----------------------------------------------##
  
  ##-------------------##
  ##--TS Confirmados----
  ##-------------------##
  
  library(readr)
  library(janitor)
  library(ggplot2)
  library(dplyr)
  library(tidyverse)
  library(plotly)
  library(hrbrthemes)
  library(lubridate)
  
  
  ##--Base de dados-------
  library(readr)
  evolucao_pe <- read_delim(paste0("~/Google Drive/Coronavirus/IRRD/planilhas de pe/junho2021/", hoje, "/base/TS_evolucao.csv"), 
                                             ";", escape_double = FALSE, trim_ws = TRUE)
  names(evolucao_pe)
  
  library(janitor)
  df <- clean_names(evolucao_pe)
  names(df)
  
  ##--Internados em leito--## 
  internados <- df %>% 
    dplyr::select(data_da_base, 
           interna_no_hospital_municipal,
           internado_leito, internado)
  
  total_internados <- internados$interna_no_hospital_municipal + 
    internados$internado_leito + internados$internado
  
  internados <- internados %>% 
    mutate(total_internados = total_internados)

##--Internados em UTI--## 
  # ggplot(data = df, 
  #        aes(x = data_da_base, 
  #            y = internado_uti)) +
  #   geom_line()
  # 
  ##--Juntando as duas informações--##
  df <- df %>% 
    mutate(internados_leito = total_internados)
  
  ##--Gráfico--##
  dfi <- df %>% 
    dplyr::select(data_da_base, internados_leito, internado_uti)
  class(dfi$data_da_base)
  
  
  #--Long format--##
  library(tidyverse)
  dfi.long <- dfi %>% 
    gather(key = type, value = count, -c(data_da_base))
  
  dfi.long <- dfi.long %>% 
    mutate(type = if_else(type == 'internados_leito', 'Leito', 'UTI'))
  
  plot_internados <- ggplot(data = dfi.long, 
                            aes(x = data_da_base, y = count)) +
    geom_area(aes(fill = type), alpha = 0.75) +
    theme_ipsum() +
    labs(title = "Hospitalizações em Pernambuco\nCOVID-19") +
    scale_fill_manual(values = c('purple','red')) +
    theme(legend.title = element_blank(),
          legend.position = 'bottom',
          axis.text.x = element_text(angle = 45, hjust = 1),
          axis.title.x = element_blank()) +
    ylab('Hospitalizações')
  
  plot_internados
  
  jpeg(paste0(path2, "plot_internados.jpg"),
       width = 5, height = 5, units = 'in', res = 300)
  plot_internados
  dev.off()
  
  ##--Salvando o jpg e o html--##
  plot_internadosi <- ggplotly(plot_internados)
  plot_internadosi
  htmlwidgets::saveWidget(plot_internadosi, 
                          paste0(path2,"plot_internados.html"))
  
  
  ##--Curva de recuperados--##
  class(df$data_da_base)
  #df$data_da_base <- dmy(df$data_da_base)
  plot_rec <- ggplot(df, aes(x = data_da_base, y = recuperado)) +
    geom_bar(stat = "identity", color = "blue") +
    theme_ipsum() +
    ylab("Recuperados") +
    xlab(" ") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(title = "Recuperados - COVID-19\nPernambuco",
         caption = paste("IRRD-PE. Fonte: SES-PE.\nDados atualizados em:", 
                         format(hoje)))
  
  plot_rec
  
  jpeg(paste0(path2, "recuperados_pe.jpg"),
       width = 5, height = 5, units = 'in', res = 300)
  plot_rec
  dev.off()
  
  ##--html--##
  plot_reci <- ggplotly(plot_rec)
  plot_reci
  htmlwidgets::saveWidget(plot_reci,
                          paste0(path2, "recuperados_pe.html"))
  
  
