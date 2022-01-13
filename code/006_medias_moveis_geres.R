# BIBLIOTECAS ----
library(shinydashboard)
library(dplyr)
library(ggplot2)
library(readr)
library(lubridate)
library(readr)
library(ggpubr)
library(pracma)
library(plotly)
library(tidyr)
library(colourpicker)
library(hrbrthemes)
library(DT)
library(jsonlite)
library(shinythemes)
library(leaflet)
library(GISTools)
library(rgdal)

# BASE DE DADOS ----

## Pernambuco ---------
df <- read_csv("https://raw.githubusercontent.com/wcota/covid19br/master/cases-brazil-states.csv")
pe_df <- filter(df, state == "PE")

new_cases_PE <- pe_df %>% 
  dplyr::select(date, newCases) 

# Correção no número de novos casos
new_cases_PE[new_cases_PE$date=='2021-12-17',]$newCases <- 13
new_cases_PE[new_cases_PE$date=='2021-12-18',]$newCases <- 7
tail(new_cases_PE)

new_cases_PE <- new_cases_PE %>% 
  dplyr::mutate(moving_avg = movavg(newCases, 7, "s"))

new_deaths_PE <- pe_df %>% 
  dplyr::select(date, newDeaths) %>% 
  dplyr::mutate(moving_avg = movavg(newDeaths, 7, "s"))


# GERES -------
path_geres_movavg <- "https://raw.githubusercontent.com/edneide/covid-19_Pernambuco/master/geres_media_movel.csv"

df_geres <- read_csv(path_geres_movavg)

variacoes_geres <- read_csv("https://raw.githubusercontent.com/edneide/covid-19_Pernambuco/master/variacoes_casos_geres.csv")

variacoes_geresi <- variacoes_geres[-c(5, 10, 11, 12), ]
variacoes_geresi <- rbind(variacoes_geresi, 
                          variacoes_geres[5,],
                          variacoes_geres[10,],
                          variacoes_geres[11,],
                          variacoes_geres[12,])
  
df_geres$geres <- factor(df_geres$geres,
                         levels = c("I", "II", "III",
                                    "IV", "V", "VI", "VII", "VIII",
                                    "IX", "X", "XI", "XII"))

nomes_geres <- levels(df_geres$geres)


# Variação de Macros ----
path_var_macros <- "https://raw.githubusercontent.com/edneide/covid-19_Pernambuco/master/variacoes_casos_macros.csv"
df_var_macros <- read_csv(path_var_macros)


# Municípios ----
path_municipios <- "https://raw.githubusercontent.com/edneide/covid-19_Pernambuco/master/variacao_casos_PE.csv"

df_municipios <- read_csv(path_municipios)

# Teste
nomes_municipios <- df_municipios$municipio %>% unique()
df_municipios %>% names()


# Mapa ----------
url_casos <- "https://raw.githubusercontent.com/edneide/covid-19_Pernambuco/master/variacao_casos_PE.csv"
casos_df <- read_csv(url_casos)
shp <- readOGR("/Users/edneideramalho/Google Drive/Coronavirus/IRRD/Scripts_R_covid_informe/malhas pe/pe_municipios/pe_municipios.shp",
               encoding ="UTF-8")

shp@data$NOME
uni2latex <- function(x){
  x <- gsub("\x87", "ç", x, fixed = TRUE)
  x <- gsub("\x82", "é", x, fixed = TRUE)
  x <- gsub("\x88", "ê", x, fixed = TRUE)
  x <- gsub("\x83", "â", x, fixed = TRUE)
  x <- gsub("\xa2", "ó", x, fixed = TRUE)
  x <- gsub("\xa1", "í", x, fixed = TRUE)
  x <- gsub("\xa3", "ú", x, fixed = TRUE)
  x <- gsub("\xa0", "á", x, fixed = TRUE)
  x
}

rm_accent <- function(str,pattern="all") {
  if(!is.character(str))
    str <- as.character(str)
  
  pattern <- unique(pattern)
  
  if(any(pattern=="Ç"))
    pattern[pattern=="Ç"] <- "ç"
  
  symbols <- c(
    acute = "áéíóúÁÉÍÓÚýÝ",
    grave = "àèìòùÀÈÌÒÙ",
    circunflex = "âêîôûÂÊÎÔÛ",
    tilde = "ãõÃÕñÑ",
    umlaut = "äëïöüÄËÏÖÜÿ",
    cedil = "çÇ"
  )
  
  nudeSymbols <- c(
    acute = "aeiouAEIOUyY",
    grave = "aeiouAEIOU",
    circunflex = "aeiouAEIOU",
    tilde = "aoAOnN",
    umlaut = "aeiouAEIOUy",
    cedil = "cC"
  )
  
  accentTypes <- c("´","`","^","~","¨","ç")
  
  if(any(c("all","al","a","todos","t","to","tod","todo")%in%pattern)) # opcao retirar todos
    return(chartr(paste(symbols, collapse=""), paste(nudeSymbols, collapse=""), str))
  
  for(i in which(accentTypes%in%pattern))
    str <- chartr(symbols[i],nudeSymbols[i], str) 
  
  return(str)
}

shp@data$municipio <- uni2latex(shp@data$NOME)
shp@data$municipio2 <- toupper(rm_accent(shp@data$municipio))


# which(shp@data$municipio2 == "LAGOA DO ITAENGA")

shp@data$municipio2[23] <- "BELEM DO SAO FRANCISCO"
shp@data$municipio2[49] <- "IGUARACY"
shp@data$municipio2[156] <- "LAGOA DE ITAENGA"

shp@data <- shp@data %>% 
  left_join(casos_df, by = c("municipio2" = "municipio"))


colors <- c("red", "green", "yellow")

pal <- colorFactor(
  palette = colors,
  levels = c("Aumento", "Diminuição", "Estabilidade")
)
#df_municipios_novos_casos <- read_csv()


# HEADER ----
header <- dashboardHeader(
  title = "COVID-19 em PE"
)


# SIDEBAR ----  
sidebar <- dashboardSidebar(
  # Sidebar para ESTADO DE PE----
  sidebarMenu(
    menuItem("Estado de PE",
             tabName = "estado_pe")
  ),
  # Sidebar para MUNICÍPIOS----
  sidebarMenu(
    menuItem("Municípios",
             tabName = "municipios")),
  # Sidebar para GERES----
  sidebarMenu(
    menuItem("GERES",
             tabName = "geres")),
  # Sidebar para MACROS----
  sidebarMenu(
    menuItem("MACROS",
             tabName = "macros"))
)

# BODY ----
body <- dashboardBody(
  fluidPage(theme = shinytheme("united")),
  tabItems(
    # TabItem de ESTADO -------
    tabItem(tabName = "estado_pe",
            fluidRow(
              h2("COVID-19 no estado de Pernambuco"),
              valueBoxOutput("casos_total", width = 3),
              valueBoxOutput("obitos_total", width = 3),
              valueBoxOutput("novos_casos", width = 3),
              valueBoxOutput("novos_obitos", width = 3),
            ),
            fluidRow(
              column(6,
                     plotly::plotlyOutput('casos_PE_movavg')
                     ),
              column(6,
                     plotly::plotlyOutput('obitos_PE_movavg'))
            )),
  # TabItem de MUNICÍPIOS ----
  tabItem(tabName = "municipios",
          fluidRow(
            h2("Variação de casos por município em relação a duas semanas anteriores"),
            h5("Clique no município para ver o percentual de variação dos casos"),
            leafletOutput("mymap"),
            DT::DTOutput('tabela_municipios'),
            img(src='logos.png', align = "center", height = "30%",
                width = "30%", style="display: block; margin-left: auto; margin-right: auto;")
          )), # FIM DE MUNICÍPIOS
  
  # # TabItems GERES ----
  
    tabItem(tabName = "geres",
            fluidRow(
                column(width = 3,
                       selectInput("geres", "Escolha uma GERES:",
                                   choices = nomes_geres, selected = "I"),
                       colourInput("col", "Escolha uma cor", value = "#ffb3b3")),
                column(width = 5,
                       plotly::plotlyOutput('plot_geres', width = 900, height = 700))
            ),
            fluidRow(
              paste("Atualizado em:", format(as.Date(today()), "%d/%m/%Y")),
              br(),
              br(),
              DT::DTOutput('tabela_geres'),
              img(src='logos.png', align = "center", height = "30%",
                  width = "30%", style="display: block; margin-left: auto; margin-right: auto;")
            )
            ), # FIM DE GERES
  # 
  # TabItem de MACROS ----
    tabItem(tabName = "macros",
            fluidRow(
              column(width = 8, offset = 4,
                     img(src='macros_pe.png', align = "center", height = "60%",
                         width = "60%")
                     )),
              fluidRow(
                DT::DTOutput('tabela_macros'),
                img(src='logos.png', align = "center", height = "30%",
                    width = "30%", style="display: block; margin-left: auto; margin-right: auto;")
              )
            ) # FIM DE MACROS
)
)










# UI ----
ui <- dashboardPage(header, sidebar, body)


# SERVER ----
server <- function(input, output, session){
  
  # value boxes ----------
  output$casos_total <- renderValueBox({
    valueBox(
      paste0(formatC(pe_df$totalCases[length(pe_df$totalCases)], format = "d", big.mark = ".")), 
      "Casos Acumulados", 
      icon = icon("virus"),
      color = "red"
    )
  })
  
  output$obitos_total <- renderValueBox({
    valueBox(
      paste0(formatC(pe_df$deaths[length(pe_df$deaths)], format = "d", big.mark = ".")), 
      "Óbitos Acumulados", icon = icon("cross"),
      color = "black"
    )
  })
  
  
  output$novos_casos <- renderValueBox({
    valueBox(
      paste0(pe_df$newCases[length(pe_df$newCases)]), 
      "Novos Casos", 
      icon = icon("viruses"),
      color = "yellow"
    )
  })
  
  
  output$novos_obitos <- renderValueBox({
    valueBox(
      paste0(pe_df$newDeaths[length(pe_df$newDeaths)]), "Novos Óbitos", 
      icon = icon("hand-holding"),
      color = "aqua"
    )
  })
  
  # plot pernambuco ---------
  # Plot Cases
  output$casos_PE_movavg <- renderPlotly({
    ggplotly(ggplot(data = new_cases_PE, aes(x = date)) +
               geom_bar(aes(y = newCases, color = "Casos por dia"),
                        alpha = 0.7,
                        fill = "#ffe6e6",
                        stat="identity") +
               geom_line(aes(y = moving_avg, color = "Média móvel (7 dias)"), size = 2)+
               scale_color_manual(values = c("#ff9999", "#990000")) +
               theme_ipsum() + 
               theme(legend.position = "bottom",
                     axis.text.x = element_text(angle = 90),
                     legend.title = element_blank()) +
               xlab("") + 
               ylab("Casos diários")) 
  }) 
  
  output$obitos_PE_movavg <- renderPlotly({
    ggplotly(ggplot(data = new_deaths_PE, aes(x = date)) +
    geom_bar(aes(y = newDeaths, color = "Óbitos por dia"),
             fill = "#bfbfbf",
             stat="identity", alpha = 0.9)+
    geom_line(aes(y = moving_avg, color = "Média móvel (7 dias)"), size = 2)+
    scale_color_manual(values = c("black", "#bfbfbf")) +
    theme_ipsum() + 
    theme(legend.position = "bottom",
          axis.text.x = element_text(angle = 90),
          legend.title = element_blank()) +
    xlab("") + 
    ylab("Óbitos diários")) 
    })
  
  # plot geres ----
  output$plot_geres  <- plotly::renderPlotly({
    fig <- df_geres %>% 
      dplyr::filter(geres == input$geres) %>%
      ggplot(aes(x = Data)) +
      geom_bar(aes(y = total_cases,
                   color = "Casos por dia"),
               fill = input$col,
               alpha = 0.9,
               stat="identity") +
      geom_line(aes(y = media_movel, color = "Média móvel (7 dias)"), size = 1) +
      scale_color_manual(" ", values = c("Casos por dia" = input$col, 
                                         "Média móvel (7 dias)" = "#cc0000")) +
      theme_ipsum() +
      theme(legend.position = "bottom",
            axis.text.x = element_text(angle = 90),
            legend.title = element_blank(),
            legend.key = element_blank()) +
      labs(title = paste0("Casos de COVID-19 em PE - GERES ", input$geres),
           subtitle = "",
           caption = paste0("IRRD/PE. Fonte: SES-PE.\n Dados atualizados em ",
                            format(today(), "%d/%m/%Y"))) +
      scale_x_date(date_breaks = "15 days", date_labels = "%b %d") +
      xlab("") +
      ylab("Casos diários")
    #fig %>% layout(paper_bgcolor='transparent')
  }) 
  
  
  # table geres ----
  output$tabela_geres <- DT::renderDT(
    DT::datatable(rownames=FALSE, 
      {
        names(variacoes_geresi) <- c("GERES", "Variação percentual", "Status")
        variacoes_geresi
      },
      extensions = 'Buttons',
      
      callback = JS('table.page("next").draw(false);'),
      #filter = 'top',
      options = list(
        deferRender = TRUE,
        pageLength = -1,
        autoWidth = TRUE,
        dom = 'Blfrtip',
        #dom = 'Bt',
        buttons = c('csv', 'excel'), # buttons = c('copy', 'csv', 'excel', 'pdf', 'print'),
        lengthMenu = list(c(25, 50, -1), c(25, 50, "All")))
    )
  )
  
  
  # table macros ----
  output$tabela_macros <- DT::renderDT(
    DT::datatable(rownames=FALSE, 
                  {
                    df_var_macros
                  },
                  extensions = 'Buttons',
                  
                  callback = JS('table.page("next").draw(false);'),
                  #filter = 'top',
                  options = list(
                    deferRender = TRUE,
                    pageLength = -1,
                    autoWidth = TRUE,
                    dom = 'Blfrtip',
                    #dom = 'Bt',
                    buttons = c('csv', 'excel'), # buttons = c('copy', 'csv', 'excel', 'pdf', 'print'),
                    lengthMenu = list(c(25, 50, -1), c(25, 50, "All")))
    )
  )
  
  
  # mapa municípios ------
output$mymap <- renderLeaflet({
    shp  %>%
      leaflet() %>%
      addTiles() %>%
      addPolygons(stroke = TRUE,
                  smoothFactor = 0.2,
                  fillOpacity = 0.5,
                  weight = 1,
                  color = ~pal(status),
                  label = ~municipio2,
                  popup = ~ paste0(municipio2, "<br/>", status, ": ", variacao_percentual, " %"),
                  highlight = highlightOptions(weight = 3, color = "red",
                                               bringToFront = TRUE)
      ) 
  })
    

  # table municípios ----
  output$tabela_municipios <- DT::renderDT(
    DT::datatable(rownames=FALSE, 
                  {
                    data <-  df_municipios %>% 
                      dplyr::select(-geres)
                    names(data) <- c("Município", "Variação percentual", "Status")
                    data
                  },
                  extensions = 'Buttons',
                  
                  callback = JS('table.page("next").draw(false);'),
                  #filter = 'top',
                  options = list(
                    deferRender = TRUE,
                    pageLength = 15,
                    autoWidth = TRUE,
                    dom = 'Blfrtip',
                    #dom = 'Bt',
                    buttons = c('csv', 'excel'), # buttons = c('copy', 'csv', 'excel', 'pdf', 'print'),
                    lengthMenu = list(c(25, 50, -1), c(25, 50, "All")))
    )
  )
}

# APP ----
shiny::shinyApp(ui, server)





