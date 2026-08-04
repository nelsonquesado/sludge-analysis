#ayumi
#nelson
# apr.2026

rm(list = ls())
# preambulo -----------------------------------------------------------------------------------
# Instalação e carregamento compulsório das bibliotecas críticas para inferência causal moderna e dados fechados.
# install.packages(c("dagitty", "ggdag", "tidyverse", "compositions"))
library(tidyverse)
library(readxl)

library(dagitty)
library(lmtest)

rstudioapi::getActiveDocumentContext()$path %>% 
  dirname %>% 
  setwd

# data ----------------------------------------------------------------------------------------
raw.dat <- 
  read_xlsx("../data/20260609_Data_Sensitivity.xlsx") %>% 
  .[-1, ] %>% 
  rename(
    SW   = Separation_Work,
    POF = Pull_off_Force,
    D90_o = D90,              
    DM_o = DM,              
    LOI_o = LOI              
  ) %>% 
  select(-Day, -Time, -Ash, -FC, -O, -Cl, -To) %>% 
  mutate(
    WWTP = as_factor(WWTP),
    POF = abs(parse_number(as.character(POF), locale = locale(decimal_mark = "."))),
    SW  = parse_number(as.character(SW), locale = locale(decimal_mark = "."))
  ) %>% 
  mutate(across(-WWTP, ~ as.numeric(.)))


raw.dat_scaled <- raw.dat %>%
  mutate(across(where(is.numeric), ~ as.numeric(scale(.))))
# model specification -------------------------------------------------------------------------------------------------------------
# sludge_model <- '
#   D90_i ~ Al + S + LOI_i
#   DM_i  ~ Al + S + LOI_i
#   SW ~ D90_i + DM_i
#   k  ~ D90_i + DM_i
#   D90_o ~ D90_i + SW + k
#   LOI_o ~ D90_i + DM_i + SW + k
#   DM_o  ~ DM_i + SW + k
# '

# sludge_model <- '
#   D90_i ~ Al + S + LOI_i
#   DM_i  ~ Al + S + LOI_i
#   tau0 ~ D90_i + DM_i
#   D90_o ~ D90_i + tau0
#   LOI_o ~ D90_i + DM_i + tau0
#   DM_o  ~ DM_i + tau0
# '
#
#This model runs, but with error:lavaan->lav_model_vcov():  
#    # The variance-covariance matrix of the estimated parameters (vcov) does not appear to be positive definite! The smallest eigenvalue (= 1.328955e-18) is close to zero. This 
#    # may be a symptom that the model is not identified.
# sludge_model <- ' 
#   D90_i ~ Al + S + LOI_i
#   DM_i  ~ Al + S + LOI_i
#   POF ~ D90_i + DM_i
#   eta0.1  ~ D90_i + DM_i
#   D90_o ~ D90_i + POF + eta0.1
#   DM_o  ~ DM_i + POF + eta0.1
# '


# sludge_model <- ' #This model does not run: lavaan->lav_samplestats_icov():  sample covariance matrix is not positive-definite
#   D90_i ~ Al + S + LOI_i
#   DM_i  ~ Al + S + LOI_i
#   POF ~ D90_i + DM_i
#   tau0  ~ D90_i + DM_i
#   D90_o ~ D90_i + POF + tau0
#   DM_o  ~ DM_i + POF + tau0
# '

#This model runs without errors!!
# sludge_model <- ' 
#   D90_i ~ Al + S + LOI_i
#   DM_i  ~ Al + S + LOI_i
#   eta0.1  ~ D90_i + DM_i
#   D90_o ~ D90_i + eta0.1
#   DM_o  ~ DM_i + eta0.1
# '

#This model runs without errors!!
sludge_model <- '   
  D90_i ~ Al + S + LOI_i
  DM_i  ~ Al + S + LOI_i
  POF ~ D90_i + DM_i
  D90_o ~ D90_i + POF
  DM_o  ~ DM_i + POF
'

# Isolate endogenous variables from the SCALED dataset
# endo_vars <- raw.dat_scaled %>% dplyr::select(D90_i, DM_i, POF, eta0.1, D90_o, DM_o)
# endo_vars <- raw.dat_scaled %>% dplyr::select(D90_i, DM_i, POF, tau0, D90_o, DM_o)
# endo_vars <- raw.dat_scaled %>% dplyr::select(D90_i, DM_i, eta0.1, D90_o, DM_o)
endo_vars <- raw.dat_scaled %>% dplyr::select(D90_i, DM_i, POF, D90_o, DM_o)

# Execute Mardia's test using the correct snake_case arguments
mvn_result <- MVN::mvn(data = endo_vars, mvn_test = "mardia", univariate_test = "SW")

cat("--- Multivariate Normality (Mardia's Test) ---\n")
print(mvn_result$multivariateNormality)
print(mvn_result)

# Fit the structural model using the SCALED dataset
fit_sem <- lavaan::sem(sludge_model, 
                       data = raw.dat_scaled, 
                       estimator = "MLM")

cat("\n--- Full Path Analysis Estimates (Robust) ---\n")
# Print the results
print(lavaan::summary(fit_sem, standardized = TRUE, fit.measures = TRUE, rsquare = TRUE))
lavaan::summary(fit_sem, standardized = TRUE, fit.measures = TRUE, rsquare = TRUE) %>% .['pe'] %>%  writexl::write_xlsx('../data/results/DAG.regressions_POF.xlsx')
