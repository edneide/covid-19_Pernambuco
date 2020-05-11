setwd("~/Documents/GitHub/covid-19_Pernambuco")

# Carregando a base de dados limpa
library(readr)
df <- read_delim("~/Google Drive/Coronavirus/IRRD/planilhas de pe/09-05-2020/recife_att_DOTS_2020-05-10_05-00.csv", 
                                               ";", escape_double = FALSE, trim_ws = TRUE)
names(df)

# Aplicando a função para padronizar o nome das variáveis
library(janitor)
de <- janitor::clean_names(df)
names(de)

# # Limpeza Hospitais
# de1 <- de %>% 
#   filter(local_internamento != "#REF!") %>% 
#   mutate(local_internamento = stringr::str_replace_all(local_internamento, c(
#     "CENTRO MÉDICO HOSPITALAR - PMPE" = "CMH",
#     "HOSPITAL AGAMENOM MAGALHÃES" = 	"HAM",
#     "HOSPITAL AGAMENON MAGALHAES" = 	"HAM",
#     "HOSPITAL AGAMENON MAGALHÃES" = 	"HAM", 
#     "HOSPITAL AGAMENON MAGALHAES - RECIFE" = 	"HAM",
#     "HOSPITAL PRIVADOOUTROHAPVIDA OLINDA" = "HAPVIDA OLINDA",
#     "HOSPITAL HAPVIDA - DERBY" = "HAPVIDA DERBY",
#     "HOSPITAL BARÃO DE LUCENA" = "HB",
#     "HOSPITAL DOM HELDER" = "HDH",
#     "HOSPITAL DOM HÉLDER" = "HDH",
#     "HOSPITAL DOM HELDER CAMARA" = "HDH",
#     "HOSPITAL OTAVIO DE FREITAS" = "HOF",
#     "HOSPITAL OTÁVIO DE FREITAS" = "HOF",
#     "HOSPITAL OTAVIO DE FREITAS - RECIFE" = "HOF",
#     "HOSPITAL AGAMENOM MAGALHÃES" = "AGAMENON MAGALHÃES",
#     "HOSPITAL AGAMENON MAGALHAES" = "AGAMENON MAGALHÃES",
#     "HOSPITAL AGAMENON MAGALHÃES" = "AGAMENON MAGALHÃES",
#     "HOSPITAL AGAMENON MAGALHAES - RECIFE" = "AGAMENON MAGALHÃES",
#     "HOSPITAL ALFA - BOA VIAGEM" = "HOSPITAL ALFA",
#     "HOSPITAL ALFA BOA VIAGEM" = "HOSPITAL ALFA",
#     "HOSPITAL DA MULHER DE RECIFE" = "HOSPITAL DA MULHER",
#     "HOSPITAL DA MULHER DO RECIFE" = "HOSPITAL DA MULHER",
#     "HOSPITAL DA POLICIA MILITAR" = "HOSPITAL DA POLÍCIA MILITAR",
#     "HOSPITAL DA RESTAURA" = "HOSPITAL DA RESTAURAÇÃO",
#     "HOSPITAL DA RESTAURACAO" = "HOSPITAL DA RESTAURAÇÃO",
#     "HOSPITAL DAS CLINICAS" = "HOSPITAL DAS CLÍNICAS",
#     "HOSPITAL DE CAMPANHA COVID 19 HPR" = "HOSPITAL DE CAMPANHA COVID 19 HPR1",
#     "HPR I HOSPITAL PROVISORIO DO RECIFE SANTO AMARO (AURORA)" = "HOSPITAL DE CAMPANHA COVID 19 HPR2",
#     "HOSPITAL ESPERANCA" = "HOSPITAL ESPERANÇA",
#     "HOSPITAL ESPERANÇA OLINDA" = "HOSPITAL ESPERANÇA",
#     "HOSPITAL OTAVIO DE FREITAS" = "HOSPITAL OTÁVIO DE FREITAS",
#     "HOSPITAL OTAVIO DE FREITAS - RECIFE" = "HOSPITAL OTÁVIO DE FREITAS",
#     "HOSPITAL PELOPIDAS SILVEIRA" = "HOSPITAL PELÓPIDAS SILVEIRA",
#     "HOSPITAL REGIONAL DE PALMARES DR. SILVIO MAGALHÃES" = "HOSPITAL REGIONAL DR SÍLVIO MAGALHÃES",
#     "HOSPITAL SAO MARCOS" = "HOSPITAL SÃO MARCOS",
#     "HOSPITAL UNIME RECIFE I" = "HOSPITAL UNIMED RECIFE I",
#     "HOSPITAL UNIMED DE PETROLINA" = "HOSPITAL UNIMED PETROLINA",
#     "MATERNIDADE BRITES DE ALBUQUERQUE-OLINDA" = "MATERNIDADE BRITES DE ALBUQUERQUE",
#     "OUTRO" = "NÃO IDENTIFICADO",
#     "POLICLÍNICA E MATERNIDADE PROFESSOR BARROS LIMA" = "POLICLINICA E MATERNIDADE BARROS LIMA",
#     "UNIDADE MISTA PROF. BARROS LIMA" = "POLICLINICA E MATERNIDADE BARROS LIMA",
#     "SEM INFORMAÇÃO" = "NÃO IDENTIFICADO",
#     "UPA SÃO LOURENÇO" = "UPA SÃO LOURENÇO DA MATA",
#     "HOSPITAL DA RESTAURAÇÃOCAO" = "HOSPITAL DA RESTAURAÇÃO",
#     "HOSPITAL DA RESTAURAÇÃOÇÃO" = "HOSPITAL DA RESTAURAÇÃO",
#     "HOSPITAL DE CAMPANHA COVID 19 HPR12" = "HOSPITAL DE CAMPANHA COVID 19 HPR2"
#   )))
# 
# de1 <- de1 %>% 
#   mutate(local_internamento = stringr::str_replace(local_internamento, "REAL HOSPITAL PORTUGUÊS", "HOSPITAL PORTUGUÊS"), 
#          local_internamento = stringr::str_replace(local_internamento, "VEHHOSPITAL REGIONAL DR SÍLVIO MAGALHÃES", "HOSPITAL REGIONAL DR SÍLVIO MAGALHÃES"))
# 
# de1 <- de1 %>% 
#   mutate(
#     local_internamento = if_else(local_internamento == "CENTRO HOSPITALAR - PMPE", "CMH",
#                                  if_else(local_internamento == "CENTRO MEDICO HOSPITALAR PM PE", "CMH", 
#                                          if_else(local_internamento == "HOSPITAL E MATERNIDADE NOSSA SENHORA DO O", "CESAC - PRADO", 
#                                                  if_else(local_internamento == "HOSPITAL NOSSA SENHORA DO O", "CESAC - PRADO",
#                                                          if_else(local_internamento == "HOSPITAL NOSSA SENHORA DO O - JANGA PAULISTA", "CESAC - PAULISTA",
#                                                                  if_else(local_internamento == "HOSPITAL NOSSA SENHORA DO O JANGA PAULISTA", "CESAC - PAULISTA",
#                                                                          if_else(local_internamento == "GERES", "	NÃO IDENTIFICADO",
#                                                                                  if_else(local_internamento == "HDH CAMARA", "HDH",
#                                                                                          if_else(local_internamento == "HMR - ENFERMARIA CLINICA", "HMR",
#                                                                                                  if_else(local_internamento == "HMR - UTI", "HMR",
#                                                                                                          if_else(local_internamento == "HOF - RECIFE", "HOF",
#                                                                                                                  if_else(local_internamento == "HOSITAL DOM MOURA", "HOSPITAL DOM MOURA",
#                                                                                                                          if_else(local_internamento == "HOSPITAL SANTA TERESINHA", "HOSPITAL SANTA TEREZINHA",
#                                                                                                                                  if_else(local_internamento == "POLICLINICA E MATERNIDADE PROFESSOR BARROS LIMA", "POLICLINICA E MATERNIDADE BARROS LIMA",
#                                                                                                                                          if_else(local_internamento == "POLICLINICA BARROS LIMA", "POLICLINICA E MATERNIDADE BARROS LIMA",
#                                                                                                                                                  if_else(local_internamento == "MATERNIDADE BARROS LIMA", "POLICLINICA E MATERNIDADE BARROS LIMA",
#                                                                                                                                                          if_else(local_internamento == "PCR AURORA", "PCR - AURORA",
#                                                                                                                                                                  if_else(local_internamento == "VEH-HAM", "HAM",
#                                                                                                                                                                          if_else(local_internamento == "VEH - HAM", "HAM",
#                                                                                                                                                                                  if_else(local_internamento == "VEH-HOF", "HOF",
#                                                                                                                                                                                          if_else(local_internamento == "HOSPITAL AGAMENOM MAGALHAES", "HAM",
#                                                                                                                                                                                                  if_else(local_internamento == "HOSPITAL ARLINDO MOURA", "HOSPITAL ARMINDO MOURA",
#                                                                                                                                                                                                          if_else(local_internamento == "HOSPITAL BARAO DE LUCENA", "HBL",
#                                                                                                                                                                                                                  if_else(local_internamento == "HOSPITAL  DE CAMPANHA COVID19 HPR", "HOSPITAL DE CAMPANHA COVID-19 HPR2",
#                                                                                                                                                                                                                          if_else(local_internamento == "HOSPITAL DE CAMPANHA COVID 19 HPR1 2", "HOSPITAL DE CAMPANHA COVID-19 HPR2",
#                                                                                                                                                                                                                                  if_else(local_internamento == "HOSPITAL DE CAMPANHA COVID 19 HPR2", "HOSPITAL DE CAMPANHA COVID-19 HPR2",
#                                                                                                                                                                                                                                          if_else(local_internamento == "HOSPITAL DE CAMPANHA COVID19 HPR", "HOSPITAL DE CAMPANHA COVID-19 HPR2",
#                                                                                                                                                                                                                                                  if_else(local_internamento == "HOSPITAL DE CAMPANHA COVID19 HPR 2&NBSP;", "HOSPITAL DE CAMPANHA COVID-19 HPR2",
#                                                                                                                                                                                                                                                          if_else(local_internamento == "HOSPITAL MILITAR DE AREA", "Hospital Militar de Área",
#                                                                                                                                                                                                                                                                  if_else(local_internamento == "HOSPITAL MILITAR DE AREA DO RECIFE", "Hospital Militar de Área",
#                                                                                                                                                                                                                                                                          if_else(local_internamento == "HOSPITAL PRIVADO", "NÃO IDENTIFICADO",
#                                                                                                                                                                                                                                                                                  if_else(local_internamento == "HOSPITAL PRIVADOHAPVIDA OLINDA", "HAPVIDA OLINDA",
#                                                                                                                                                                                                                                                                                          if_else(local_internamento == "HOSPITAL PORTUGUES", "HOSPITAL PORTUGUÊS",
#                                                                                                                                                                                                                                                                                                  if_else(local_internamento == "REAL HOSPITAL PORTUGUES", "HOSPITAL PORTUGUÊS",
#                                                                                                                                                                                                                                                                                                          if_else(local_internamento == "HOSPITAL DA RESTAURAÇÃOÇAO", "HOSPITAL DA RESTAURAÇÃO",
#                                                                                                                                                                                                                                                                                                                  if_else(local_internamento == "HOSPITAL REGIONAL DE PALMARES DR SILVIO MAGALHAES", "Hospital Regional de Palmares",
#                                                                                                                                                                                                                                                                                                                          if_else(local_internamento == "HOSPITAL REGIONAL DR SILVIO MAGALHAES", "Hospital Regional de Palmares",
#                                                                                                                                                                                                                                                                                                                                  if_else(local_internamento == "VEHHOSPITAL REGIONAL DR SILVIO MAGALHAES", "Hospital Regional de Palmares",
#                                                                                                                                                                                                                                                                                                                                          if_else(local_internamento == "PCR COELHOS", "PCR - COELHOS",
#                                                                                                                                                                                                                                                                                                                                                  as.character(local_internamento))))))))))))))))))))))))))))))))))))))))) %>% 
#   print()


#path = '/Users/edneideramalho/Documents/GitHub/covid-19_Pernambuco/'
write.csv(de, "covid-19_Pernambuco.csv")

