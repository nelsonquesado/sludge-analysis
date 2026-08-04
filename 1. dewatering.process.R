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
raw.dat <- 
  #read_xlsx("../data/20260521_Data_Sensitivity.xlsx") %>% 
  read_xlsx("../data/20260609_Data_Sensitivity.xlsx") %>% 
  .[-1, ] %>% 
  rename(
    SW   = Separation_Work,   
    D90_o = D90,              
    DM_o = DM,              
    LOI_o = LOI              
  ) %>% 
  select(-Day, -Time, -Ash, -FC, - O, -Pull_off_Force, -Cl, -To) %>% 
  mutate(WWTP = as_factor(WWTP),
         SW = trimws(SW)) %>% 
  mutate_at(2:20, as.numeric)

raw.dat %>% print(n = 24)

# organicos -------------------------------------------------------------------------------------------------------
var <- c("WWTP", "C", "H", "N", "S", 'VM', 'LOI_i', "Al", "Ca", "Fe", "P", "Si")

dat <-
  raw.dat[, colnames(raw.dat) %in% var] %>% 
  mutate(S. = S) %>% 
  pivot_longer(2:13) %>% 
  mutate(organico = if_else(name %in% c('S', 'N', 'C', 'H', 'VM', 'LOI_i'), 'Orgânico', 'Não Orgânico'),
         name = ifelse(name == 'S.', 'S', name)) %>% 
    mutate(name = as_factor(name))

dat %>% 
  filter(organico == "Orgânico") %>% 
  ggplot() +
  geom_line(aes(x = name, y = value, color = WWTP, group = WWTP), linewidth = 1, alpha = .75) +
  theme_minimal() +
  labs(x = 'Variável', y = 'Valor (log10)') +
  okcolors::scale_color_okcolors() +
  scale_y_log10() +
  facet_grid(.~organico) +
  theme(legend.position = 'top')
  
dat.cor.org <-
  raw.dat[, colnames(raw.dat) %in% var] %>% 
    select(WWTP, LOI_i, VM, C, H, N, S)
    #select(WWTP, LOI_i, S)

dat.cor.org %>% 
  correlation::correlation(., method = 'spearman')

dat.cor.org %>% 
  correlation::correlation(., method = 'spearman') %>% 
  as_tibble() %>% 
  writexl::write_xlsx('../data/results/dewatering.correlation.xlsx')

dat.cor.org %>% 
  select(-1) %>% 
  prcomp(scale. = T) %>% 
  ggbiplot::ggbiplot()
  
dat.cor <-
  dat  %>%
  filter(organico == 'Orgânico') %>% 
  select(-WWTP, - organico) %>%
  pivot_wider(names_from = name, values_from = value) %>% 
  select(LOI_i, S) %>% 
  unnest()

WWTP <- raw.dat$WWTP

# PCA
pca <- prcomp(dat.cor, scale. = T)

# scores (observations)
scores <- as_tibble(pca$x) %>% 
  mutate(WWTP = WWTP)

# loadings (variables)
loadings <- as_tibble(pca$rotation, rownames = "var")
loadings %>% writexl::write_xlsx('../data/results/dewatering.loadings.sel.xlsx')

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
    title = "PCA (Orgânico)",
    x = paste0("PC1 (", round(var_exp[1] * 100, 1), "%)"),
    y = paste0("PC2 (", round(var_exp[2] * 100, 1), "%)")
  )

# nao organicos -------------------------------------------------------------------------------------------------------
var <- c("WWTP", "C", "H", "N", "S", 'VM', 'LOI_i', "Al", "Ca", "Fe", "P", "Si")

dat <-
  raw.dat[, colnames(raw.dat) %in% var] %>% 
  mutate(S. = S) %>% 
  pivot_longer(2:13) %>% 
  mutate(organico = if_else(name %in% c('S', 'N', 'C', 'H', 'VM', 'LOI_i'), 'Orgânico', 'Não Orgânico'),
         name = ifelse(name == 'S.', 'S', name)) %>% 
    mutate(name = as_factor(name))

dat %>% 
  filter(!organico == "Orgânico") %>% 
  ggplot() +
  geom_line(aes(x = name, y = value, color = WWTP, group = WWTP), linewidth = 1, alpha = .75) +
  theme_minimal() +
  labs(x = 'Variável', y = 'Valor (log10)') +
  okcolors::scale_color_okcolors() +
  scale_y_log10() +
  facet_grid(.~organico) +
  theme(legend.position = 'top')
  
dat.cor.org <-
  raw.dat[, colnames(raw.dat) %in% var] %>% 
    #select(WWTP, Al, S)
    select(WWTP, Al, Ca, Fe, P, Si, S)

dat.cor.org %>% 
  correlation::correlation(., method = 'spearman')

dat.cor.org %>% 
  correlation::correlation(., method = 'spearman') %>% 
  as_tibble() %>% 
  writexl::write_xlsx('../data/results/dewatering.norg.correlation.xlsx')

dat.cor.org %>% 
  select(-1) %>% 
  prcomp(scale. = T) %>% 
  ggbiplot::ggbiplot()
  
dat.cor <-
  dat  %>%
  filter(organico == 'Não Orgânico') %>% 
  select(-WWTP, - organico) %>%
  pivot_wider(names_from = name, values_from = value) %>% 
  #select(Al, S) %>% 
  unnest()

  
WWTP <- raw.dat$WWTP

# PCA
pca <- prcomp(dat.cor, scale. = T)

# scores (observations)
scores <- as_tibble(pca$x) %>% 
  mutate(WWTP = WWTP)

# loadings (variables)
loadings <- as_tibble(pca$rotation, rownames = "var")
loadings %>% writexl::write_xlsx('../data/results/dewatering.norg.loadings.sel.xlsx')

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
    title = "PCA (Não Orgânico)",
    x = paste0("PC1 (", round(var_exp[1] * 100, 1), "%)"),
    y = paste0("PC2 (", round(var_exp[2] * 100, 1), "%)")
  )

# dewatering output -------------------------------------------------------------------------------------------------------
var <- c("WWTP", 'DM_i', 'D90_i')

dat <-
  raw.dat[, colnames(raw.dat) %in% var] %>% 
  pivot_longer(2:3) %>% 
  mutate(name = as_factor(name))

dat.cor.org <-
  raw.dat[, colnames(raw.dat) %in% var]

dat.cor.org %>% 
  correlation::correlation(., method = 'spearman')

dat.cor.org %>% 
  correlation::correlation(., method = 'spearman') %>% 
  as_tibble() %>% 
  writexl::write_xlsx('../data/results/dewatering.output.correlation.xlsx')

dat.cor.org %>% 
  select(-1) %>% 
  prcomp(scale. = T) %>% 
  ggbiplot::ggbiplot()
  
dat.cor <-
  dat  %>%
  select(-WWTP) %>%
  pivot_wider(names_from = name, values_from = value) %>% 
  unnest()

WWTP <- raw.dat$WWTP

# PCA
pca <- prcomp(dat.cor, scale. = T)

# scores (observations)
scores <- as_tibble(pca$x) %>% 
  mutate(WWTP = WWTP)

# loadings (variables)
loadings <- as_tibble(pca$rotation, rownames = "var")
loadings %>% writexl::write_xlsx('../data/results/dewatering.output.loadings.xlsx')

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
    title = "PCA (Dewatering Output)",
    x = paste0("PC1 (", round(var_exp[1] * 100, 1), "%)"),
    y = paste0("PC2 (", round(var_exp[2] * 100, 1), "%)")
  )

int.est.mean <- 
  raw.dat %>% 
  select(WWTP, DM_i, D90_i, LOI_i) %>% 
  group_by(WWTP) %>% 
  reframe(
    n = n(),
    mean.DM_i = mean(DM_i),
    sd.DM_i = sd(DM_i),
    se.DM_i = sd.DM_i / sqrt(n),
    ic.DM_i = mean.DM_i + (qnorm(p = .025) * se.DM_i),
    sc.DM_i = mean.DM_i + (qnorm(p = .975) * se.DM_i),
    mean.D90_i = mean(D90_i),
    sd.D90_i = sd(D90_i),
    se.D90_i = sd.D90_i / sqrt(n),
    ic.D90_i = mean.D90_i + (qnorm(p = .025) * se.D90_i),
    sc.D90_i = mean.D90_i + (qnorm(p = .975) * se.D90_i),
    mean.LOI_i = mean(LOI_i),
    sd.LOI_i = sd(LOI_i),
    se.LOI_i = sd.LOI_i / sqrt(n),
    ic.LOI_i = mean.LOI_i + (qnorm(p = .025) * se.LOI_i),
    sc.LOI_i = mean.LOI_i + (qnorm(p = .975) * se.LOI_i)
  )

int.est.mean %>% 
  ggplot() +
  geom_line(data = . %>% select(WWTP, sc.DM_i, ic.DM_i) %>% pivot_longer(2:3), aes(y = WWTP, x = value, color = WWTP)) +
  geom_point(aes(y = WWTP, x = mean.DM_i, color = WWTP), size = 3) +
  geom_point(aes(y = WWTP, x = ic.DM_i, color = WWTP)) +
  geom_point(aes(y = WWTP, x = sc.DM_i, color = WWTP)) +
  theme_minimal() +
  labs(title ='DM_i', subtitle = 'Estimativa Intervalar da Média') +
  theme(legend.position = 'none', 
        axis.title = element_blank(),
         title = element_text(face = 'bold')) +
  okcolors::scale_color_okcolors()

int.est.mean %>% 
  ggplot() +
  geom_line(data = . %>% select(WWTP, sc.D90_i, ic.D90_i) %>% pivot_longer(2:3), aes(y = WWTP, x = value, color = WWTP)) +
  geom_point(aes(y = WWTP, x = mean.D90_i, color = WWTP), size = 3) +
  geom_point(aes(y = WWTP, x = ic.D90_i, color = WWTP)) +
  geom_point(aes(y = WWTP, x = sc.D90_i, color = WWTP)) +
  theme_minimal() +
  labs(title ='D90_i', subtitle = 'Estimativa Intervalar da Média') +
  theme(legend.position = 'none', 
        axis.title = element_blank(),
         title = element_text(face = 'bold')) +
  okcolors::scale_color_okcolors()

int.est.mean %>% 
  ggplot() +
  geom_line(data = . %>% select(WWTP, sc.LOI_i, ic.LOI_i) %>% pivot_longer(2:3), aes(y = WWTP, x = value, color = WWTP)) +
  geom_point(aes(y = WWTP, x = mean.LOI_i, color = WWTP), size = 3) +
  geom_point(aes(y = WWTP, x = ic.LOI_i, color = WWTP)) +
  geom_point(aes(y = WWTP, x = sc.LOI_i, color = WWTP)) +
  theme_minimal() +
  labs(title ='LOI_i', subtitle = 'Estimativa Intervalar da Média') +
  theme(legend.position = 'none', 
        axis.title = element_blank(),
         title = element_text(face = 'bold')) +
  okcolors::scale_color_okcolors()


# regressoes ------------------------------------------------------------------------------------------------------
forms <- 
  c(dmi.all = DM_i ~ VM + LOI_i + C + H + N + S + Al + Ca + Fe + P + Si,
    dmi.sel = DM_i ~ LOI_i + S + Al,
    d90i.all = D90_i ~ VM + LOI_i + C + H + N + S + Al + Ca + Fe + P + Si,
    d90i.sel = D90_i ~ LOI_i + S + Al)


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
    paste0("../data/results/dewatering.regression.", name, ".xlsx")
  )
})


