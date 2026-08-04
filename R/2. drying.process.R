#ayumi
#nelson
# apr.2026

rm(list = ls())
# preambulo -----------------------------------------------------------------------------------
# Instalação e carregamento compulsório das bibliotecas críticas para inferência causal moderna e dados fechados.
# install.packages(c("dagitty", "ggdag", "tidyverse", "compositions"))
library(tidyverse)
library(readxl)

library(ggcorrplot)

rstudioapi::getActiveDocumentContext()$path %>% 
  dirname %>% 
  setwd

# data ----------------------------------------------------------------------------------------
#read_xlsx("../data/20260521_Data_Sensitivity.xlsx") %>% colnames
read_xlsx("../data/20260609_Data_Sensitivity.xlsx") %>% colnames

raw.dat <- 
  read_xlsx("../data/20260609_Data_Sensitivity.xlsx") %>% 
  .[-1, ] %>% 
  rename(
    SW    = Separation_Work,
    POF   = Pull_off_Force,
    D90_o = D90,              
    DM_o  = DM,              
    LOI_o = LOI              
  ) %>% 
  select(-Day, -Time, -Ash, -FC, -O, -Cl, -To) %>% 
  mutate(
    WWTP = as_factor(WWTP),
    POF = abs(parse_number(as.character(POF), locale = locale(decimal_mark = ","))),
    SW  = parse_number(as.character(SW), locale = locale(decimal_mark = ","))
  ) %>% 
  mutate(across(-WWTP, ~ as.numeric(.)))

cor(raw.dat$tau0, raw.dat$eta0.1)
cor(raw.dat$SW, raw.dat$POF)
correlation::correlation(select(raw.dat, c('tau0', 'eta0.1')))
correlation::correlation(select(raw.dat, c('SW', 'POF')))
# reologia -------------------------------------------------------------------------------------------------------
var <- c("WWTP", 'POF', 'SW', 'tau0', 'eta0.1')

dat <-
  raw.dat[, colnames(raw.dat) %in% var] %>% 
  pivot_longer(2:5) %>% 
  mutate(name = as_factor(name))

dat %>% 
  ggplot() +
  geom_line(aes(x = name, y = value, color = WWTP, group = WWTP), linewidth = 1, alpha = .75) +
  theme_minimal() +
  labs(x = 'Variável', y = 'Valor (log10)') +
  scale_y_log10() +
  theme(legend.position = 'top')
  
dat.cor.org <-
  raw.dat[, colnames(raw.dat) %in% var] #%>% select(WWTP, LOI_i, S)

dat.cor.org %>% 
  correlation::correlation(., method = 'spearman')

dat.cor.org %>% 
  correlation::correlation(., method = 'spearman') %>% 
  as_tibble() %>% 
  writexl::write_xlsx('../data/results/drying.reol.correlation_v3.xlsx')

dat.cor.org %>% 
  select(-1) %>% 
  prcomp(scale. = T) %>% 
  ggbiplot::ggbiplot()
  
#dat.cor <- select(raw.dat, eta0.1, tau0, SW)
dat.cor <- select(raw.dat, eta0.1, POF, tau0, SW)

WWTP <- raw.dat$WWTP

# PCA
pca <- prcomp(dat.cor, scale. = T)

# scores (observations)
scores <- as_tibble(pca$x) %>% 
  mutate(WWTP = WWTP)

# loadings (variables)
loadings <- as_tibble(pca$rotation, rownames = "var")
loadings %>% writexl::write_xlsx('../data/results/drying.reol.loadings.all_v3.xlsx')


var_exp <- (pca$sdev^2) / sum(pca$sdev^2)

# plot 
ggplot(scores, aes(PC1, PC2, color = WWTP)) +
  geom_point(size = 3, alpha = 0.8) +
  geom_segment(
    data = loadings,
    aes(x = 0, y = 0, xend = PC1 * 4, yend = PC2 * 4),
    arrow = arrow(length = unit(0.2, "cm")),
    inherit.aes = FALSE
  ) +
  geom_text(
    data = loadings,
    aes(x = PC1 * 4, y = PC2 * 4, label = var),
    inherit.aes = FALSE
  ) +
  theme_minimal() +
  theme(legend.position = "top") +
  labs(
    title = "PCA (Reologia)",
    x = paste0("PC1 (", round(var_exp[1] * 100, 1), "%)"),
    y = paste0("PC2 (", round(var_exp[2] * 100, 1), "%)")
  )

# drying -------------------------------------------------------------------------------------------------------
var <- c("WWTP", 'D90_o', 'DM_o', 'LOI_o')

dat <-
  raw.dat[, colnames(raw.dat) %in% var] %>% 
  pivot_longer(2:4) %>% 
  mutate(name = as_factor(name))

dat %>% 
  ggplot() +
  geom_line(aes(x = name, y = value, color = WWTP, group = WWTP), linewidth = 1, alpha = .75) +
  theme_minimal() +
  labs(x = 'Variável', y = 'Valor (log10)') +
  okcolors::scale_color_okcolors() +
  scale_y_log10() +
  theme(legend.position = 'top')
  
dat.cor.org <-
  raw.dat[, colnames(raw.dat) %in% var] #%>% select(WWTP, LOI_i, S)

dat.cor.org %>% 
  correlation::correlation(., method = 'spearman')

# dat.cor.org %>% 
#   correlation::correlation(., method = 'spearman') %>% 
#   writexl::write_xlsx('../data/results/drying.output.correlation_v2.xlsx')

dat.cor.org %>% 
  select(-1) %>% 
  prcomp(scale. = T) %>% 
  ggbiplot::ggbiplot()
  
dat.cor <-
  dat  %>%
  select(-WWTP) %>%
  pivot_wider(names_from = name, values_from = value) %>% 
  select(-D90_o) %>% 
  unnest()

WWTP <- raw.dat$WWTP

# PCA
pca <- prcomp(dat.cor, scale. = T)

# scores (observations)
scores <- as_tibble(pca$x) %>% 
  mutate(WWTP = WWTP)

# loadings (variables)
loadings <- as_tibble(pca$rotation, rownames = "var")
#loadings %>% writexl::write_xlsx('../data/results/drying.reol.loadings.sel_v2.xlsx')

var_exp <- (pca$sdev^2) / sum(pca$sdev^2)

# plot 
ggplot(scores, aes(PC1, PC2, color = WWTP)) +
  geom_point(size = 3, alpha = 0.8) +
  geom_segment(
    data = loadings,
    aes(x = 0, y = 0, xend = PC1 * 4, yend = PC2 * 4),
    arrow = arrow(length = unit(0.2, "cm")),
    inherit.aes = FALSE
  ) +
  geom_text(
    data = loadings,
    aes(x = PC1 * 4, y = PC2 * 4, label = var),
    inherit.aes = FALSE
  ) +
  theme_minimal() +
  okcolors::scale_color_okcolors() +
  theme(legend.position = "top") +
  labs(
    title = "PCA (Drying Output)",
    x = paste0("PC1 (", round(var_exp[1] * 100, 1), "%)"),
    y = paste0("PC2 (", round(var_exp[2] * 100, 1), "%)")
  )

int.est.mean <- 
  dat.cor.org %>% 
  group_by(WWTP) %>% 
  reframe(
    n = n(),
    mean.DM_o = mean(DM_o),
    sd.DM_o = sd(DM_o),
    se.DM_o = sd.DM_o / sqrt(n),
    ic.DM_o = mean.DM_o + (qnorm(p = .025) * se.DM_o),
    sc.DM_o = mean.DM_o + (qnorm(p = .975) * se.DM_o),
    mean.D90_o = mean(D90_o),
    sd.D90_o = sd(D90_o),
    se.D90_o = sd.D90_o / sqrt(n),
    ic.D90_o = mean.D90_o + (qnorm(p = .025) * se.D90_o),
    sc.D90_o = mean.D90_o + (qnorm(p = .975) * se.D90_o),
    mean.LOI_o = mean(LOI_o),
    sd.LOI_o = sd(LOI_o),
    se.LOI_o = sd.LOI_o / sqrt(n),
    ic.LOI_o = mean.LOI_o + (qnorm(p = .025) * se.LOI_o),
    sc.LOI_o = mean.LOI_o + (qnorm(p = .975) * se.LOI_o)
  )

int.est.mean %>% 
  ggplot() +
  geom_line(data = . %>% select(WWTP, sc.DM_o, ic.DM_o) %>% pivot_longer(2:3), aes(y = WWTP, x = value, color = WWTP)) +
  geom_point(aes(y = WWTP, x = mean.DM_o, color = WWTP), size = 3) +
  geom_point(aes(y = WWTP, x = ic.DM_o, color = WWTP)) +
  geom_point(aes(y = WWTP, x = sc.DM_o, color = WWTP)) +
  theme_minimal() +
  labs(title ='DM_o', subtitle = 'Estimativa Intervalar da Média') +
  theme(legend.position = 'none', 
        axis.title = element_blank(),
        title = element_text(face = 'bold')) +
  okcolors::scale_color_okcolors()

int.est.mean %>% 
  ggplot() +
  geom_line(data = . %>% select(WWTP, sc.D90_o, ic.D90_o) %>% pivot_longer(2:3), aes(y = WWTP, x = value, color = WWTP)) +
  geom_point(aes(y = WWTP, x = mean.D90_o, color = WWTP), size = 3) +
  geom_point(aes(y = WWTP, x = ic.D90_o, color = WWTP)) +
  geom_point(aes(y = WWTP, x = sc.D90_o, color = WWTP)) +
  theme_minimal() +
  labs(title ='D90_o', subtitle = 'Estimativa Intervalar da Média') +
  theme(legend.position = 'none', 
        axis.title = element_blank(),
        title = element_text(face = 'bold')) +
  okcolors::scale_color_okcolors()

int.est.mean %>% 
  ggplot() +
  geom_line(data = . %>% select(WWTP, sc.LOI_o, ic.LOI_o) %>% pivot_longer(2:3), aes(y = WWTP, x = value, color = WWTP)) +
  geom_point(aes(y = WWTP, x = mean.LOI_o, color = WWTP), size = 3) +
  geom_point(aes(y = WWTP, x = ic.LOI_o, color = WWTP)) +
  geom_point(aes(y = WWTP, x = sc.LOI_o, color = WWTP)) +
  theme_minimal() +
  labs(title ='LOI_o', subtitle = 'Estimativa Intervalar da Média') +
  theme(legend.position = 'none', 
        axis.title = element_blank(),
        title = element_text(face = 'bold')) +
  okcolors::scale_color_okcolors()


# regressoes ------------------------------------------------------------------------------------------------------
# forms <-
#   c(
#     sw = SW ~ DM_i + D90_i,
#     k = k ~  DM_i + D90_i,
#     DMo.all = DM_o ~ DM_i + D90_i + SW + k + tau0 + n,
#     DMo.sel = DM_o ~ DM_i + D90_i +  + SW + k,
#     LOIo.all = LOI_o ~ DM_i + D90_i +  + SW + k + tau0 + n,
#     LOIo.sel = LOI_o ~ DM_i + D90_i +  + SW + k
#     )

forms <-
  c(
    POF = POF ~ DM_i + D90_i,
    eta0.1 =  eta0.1 ~ DM_i + D90_i,
    DMo.all = DM_o ~ DM_i + D90_i + POF + eta0.1 + tau0 ,
    DMo.sel = DM_o ~ DM_i + D90_i + SW + POF + eta0.1,
    LOIo.all = LOI_o ~ DM_i + D90_i + SW + POF + eta0.1 + tau0,
    LOIo.sel = LOI_o ~ DM_i + D90_i + SW + POF + eta0.1
    )

lapply(forms, function(x) {
  
  temp <-
    lm(data = raw.dat, formula = x) %>% 
    summary()
  
  return(temp)

  })

purrr::imap(forms, function(f, name) {
  temp <- lm(data = raw.dat, formula = f) |>
    summary() |>
    coef() |>
    as.data.frame() |>
    tibble::rownames_to_column("term") |>
    tibble::as_tibble()
  
  writexl::write_xlsx(
    temp,
    paste0("../data/results/drying.regression_v3.", name, ".xlsx")
  )
})

