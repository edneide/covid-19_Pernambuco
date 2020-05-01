library(scales)
library(formatR) 
library(eeptools)
library(readxl)
library(Rclean)

PE_full <- read_excel("Covid19_19.27.2020_Lika.xlsx", col_types = c("numeric", "skip", "text", "date", "skip", "text", "date", "numeric", "skip", "text", "text", 
                                                                    "text", "text", "text", "skip", "date", "text", "text", "text", "skip", "skip", "skip", "skip", 
                                                                    "text", "text", "text", "text", "numeric", "numeric", "text", "text", "text", "text", "text", 
                                                                    "date", "text", "text", "text", "skip", "skip", "skip", "skip"))

PE_full <- as_tibble(clean_names(PE_full)) %>% 
  print()



PE_full1 <- PE_full %>% 
  select(id, data_atualizacao, data_de_nascimento, idade, sexo, estado_de_residencia, municipio, endereco_completo, cep_residencia, 
         data_dos_primeiros_sintomas, data_da_notificacao, data_do_obito, local_do_obito, selecione_os_sintomas_apresentados, 
         morbidades_previas_selecionar_todas_as_morbidades_pertinentes, paciente_foi_hospitalizado, coleta_de_exames,
         classificacao_final, resultado, laboratorio, teste_rapido, local_de_atendimento_unidade_notificadora, internado,
         local_internamento, evolucao, tipo_de_local_de_internamento, ocupacao_do_paciente, tipo_da_notificacao) %>% 
  rename(sintomas_aprest = selecione_os_sintomas_apresentados, atend_unid_notif = local_de_atendimento_unidade_notificadora,
         morbidades_previas = morbidades_previas_selecionar_todas_as_morbidades_pertinentes) %>% 
  mutate(data_atualizacao = lubridate::as_date(data_atualizacao), data_da_notificacao = lubridate::as_date(data_da_notificacao), 
         data_de_nascimento = lubridate::as_date(data_de_nascimento), data_dos_primeiros_sintomas = lubridate::as_date(data_dos_primeiros_sintomas),
         data_do_obito = lubridate::as_date(data_do_obito)) %>% 
  mutate(idade = lubridate::time_length(difftime(Sys.Date(), data_de_nascimento), "years"), idade = base::round(idade, digits = 0), 
         TL1 = data_da_notificacao - data_dos_primeiros_sintomas, TL2 = data_do_obito - data_dos_primeiros_sintomas, TL2_i = data_do_obito - data_da_notificacao) %>%
  print()






### RINOVÍRUS = RV

PE_full1i <- PE_full1 %>% 
  mutate(sexo = stringr::str_to_sentence(sexo), 
         coleta_de_exames = stringr::str_replace_all(coleta_de_exames, c("Sim" = "SIM", "REPETIR TESTE" = "SIM", "SEM" = "SIM", 
                                                                         "VERIFICAR" = "SIM", "NÃO REALIZADA" = "NÃO", "NA_character_" = "SIM")),
         coleta_de_exames = stringr::str_replace_na(coleta_de_exames, replacement = "SIM"), resultado = stringr::str_replace_all(resultado,  c("\\)" = "", "\\(" = "", "\\\\" = "",
                                                                                                                                               "/" = " "))) %>% 
  unite("reclas", classificacao_final:resultado, sep = " ", remove = FALSE) %>%
  mutate(reclas = stringr::str_replace_all(reclas, c("DESCARTADO NEGATIVO SARS-COV-2" = "Negativo", 
                                                     "DESCARTADO INFLUENZA B" = "Influenza B",
                                                     "CONFIRMADO SARS-COV-2" = "Covid-19", 
                                                     "CONFIRMADO NEGATIVO INFLUENZA SARS-COV-2" = "Covid-19",
                                                     "DESCARTADO NEGATIVO INFLUENZA NEGATIVO SARS-COV-2" = "Negativo", 
                                                     "CONFIRMADO AGUARDANDO INFLUENZA SARS-COV-2" = "Covid-19",
                                                     "DESCARTADO INFLUENZA A H1N1" = "H1N1", 
                                                     "DESCARTADO OUTRO CORONAVÍRUS OC43" = "HCoV-OC43", 
                                                     "DESCARTADO RINOVÍRUS" = "RV", 
                                                     "DESCARTADO RINOVÍRUS CORONAVÍRUS 229E" = "RV HCoV-229E", 
                                                     "DESCARTADO INFLUENZA A" = "Influenza A", 	
                                                     "DESCARTADO METAPNEUMOVÍRUS" = "Metapneumovírus", 
                                                     "DESCARTADO OUTRO CORONAVÍRUS NL63" = "HCoV-NL63", 
                                                     "DESCARTADO VÍRUS SINCICIAL RESPIRATÓRIO" = "VSR",
                                                     "DESCARTADO RINOVÍRUS INLUENZA A" = "RV Influenza A", 
                                                     "INCONCLUSIVO COLETA NÃO REALIZADA" = "Inconclusivo",
                                                     "DESCARTADO AGUARDANDO INFLUENZA NEGATIVO SARS-COV-2" = "Negativo", 
                                                     "DESCARTADO INFLUENZA A H1N1 NEGATIVO SARS-COV-2" = "H1N1", 
                                                     "EM INVESTIGAÇÃO NEGATIVO INFLUENZA AGUARDANDO SARS-COV-2" = "Negativo", 
                                                     "DESCARTADO INFLUENZA A E B" = "Influenza A.B",
                                                     "DESCARTADO INFLUENZA A NEGATIVO SARS-COV-2" = "Influenza A", 
                                                     "DESCARTADO INFLUENZA B NEGATIVO SARS-COV-2" = "Influenza B",
                                                     "EM INVESTIGAÇÃO AGUARDANDO RESULTADO" = "Negativo",
                                                     "EM INVESTIGAÇÃO INCONCLUSIVO SARS-COV-2" = "Negativo",
                                                     "CONFIRMADO INFLUENZA A SARS-COV-2" = "Influenza A Covid-19", 
                                                     "EM INVESTIGAÇÃO AGUARDANDO INFLUENZA INCONCLUSIVO SARS-COV-2" = "Negativo", 
                                                     "EM INVESTIGAÇÃO NEGATIVO INFLUENZA INCONCLUSIVO SARS-COV-2" = "Negativo", 
                                                     "EM INVESTIGAÇÃO INFLUENZA A INCONCLUSIVO SARS-COV-2" = "Negativo", 
                                                     "DESCARTADO INFLUENZA A E B NEGATIVO SARS-COV-2" = "Negativo", 
                                                     "CONFIRMADO INFLUENZA B SARS-COV-2" = "Influenza B Covid-19", 
                                                     "CONFIRMADO INFLUENZA A E B SARS-COV-2" = "Influenza A.B Covid-19",
                                                     "EM INVESTIGAÇÃO NEGATIVO INFLUENZA" = "Negativo", 
                                                     "EM INVESTIGAÇÃO NA" = "Negativo", 
                                                     "DESCARTADO NEGATIVO INFLUENZA" = "Negativo"))) %>% 
  print()

PE_full1i <- PE_full1i %>%
  mutate(reclas = stringr::str_replace_all(reclas, c("H1N1 NEGATIVO SARS-COV-2" = "H1N1", 	
                                                     "INFLUENZA-A E B" = "Influenza A.B", 
                                                     "INFLUENZA-A E B NEGATIVO SARS-COV-2" = "Influenza A.B", 
                                                     "INFLUENZA-A NEGATIVO SARS-COV-2" = "Influenza A",
                                                     "INFLUENZA-B NEGATIVO SARS-COV-2" = "Influenza B", 
                                                     "RV CORONAVÍRUS 229E" = "HCoV-229E",
                                                     "RV INLUENZA A" = "	RV Influenza A"
  ))) %>% 
  print()

PE_full1i <- PE_full1i %>%
  mutate(reclas = stringr::str_replace(reclas, "INFLUENZA-AB NEGATIVO SARS-COV-2", "Influenza A.B"), 
         reclas = stringr::str_replace(reclas, "HCoV-229E", "RV HCoV-229E"), 
         reclas = stringr::str_replace(reclas, "Influenza A E B", "Influenza A.B"),
         reclas = stringr::str_replace(reclas, "Influenza A NEGATIVO SARS-COV-2", "Influenza A"),
         reclas = stringr::str_replace(reclas, "Influenza B NEGATIVO SARS-COV-2", "Influenza B"),
         reclas = stringr::str_replace(reclas, "Influenza A E B NEGATIVO SARS-COV-2", "Influenza A.B"),
         reclas = stringr::str_replace(reclas, "DESCARTADO NEGATICO SARS-COV-2", "Negativo")
  ) %>% 
  mutate(reclas = stringr::str_replace(reclas, "Influenza A.B NEGATIVO SARS-COV-2", "Influenza A.B"),
         reclas = factor(reclas)) %>% 
  mutate(reclas = stringr::str_replace(reclas, "RV RV RV HCoV-229E", "RV HCoV-229E")) %>% 
  print()


PE_full1i <- PE_full1i %>%
  mutate( reclas = factor(reclas, levels = c("Negativo", "Inconclusivo", "Metapneumovírus", "VSR", "RV", "HCoV-NL63", "HCoV-OC43", 
                                             "Influenza A", "Influenza B", "Influenza A.B", "H1N1", "RV HCoV-229E", "	RV Influenza A",
                                             "Influenza A Covid-19", "Influenza B Covid-19", "Influenza A.B Covid-19", "Covid-19"))) %>% 
  print()