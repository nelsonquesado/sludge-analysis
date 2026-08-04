# Sewage Sludge Drying–Grinding Statistical Analysis

R code supporting the manuscript:

> **Exploring a drying-grinding system for pulverized sewage sludge production**
> 
> Ayumi Schober, Andrea Narvaez Torres, Juan Pablo Segovia-Gutiérrez, Nelson de Oliveira Quesado Filho, Lukas Thomae-Pohl, Matthias Rapf, Florian Drunsel, Natalie Germann

## Abstract

Pulverized sewage sludge (PSS) is required for emerging thermochemical phosphorus-recovery routes, but its production in integrated drying-grinding systems is limited by sludge agglomeration, adhesion, and resistance to fragmentation during drying. Understanding how sludge attributes contribute to final product quality is therefore essential for designing drying-grinding systems that can process heterogeneous sewage sludge streams. Four municipal sewage sludges were processed in a pilot-scale thin-film dryer, and an exploratory statistical workflow was applied to a dataset of 24 observations, combining system mapping, Spearman correlation, PCA-based variable reduction, DAG construction, and SEM path analysis. All sludges reached high final dry matter contents above 95% and particle size below 2,378.41 µm. The non-stabilized KA-4 sludge, with the highest initial organic content (LOI = 75.0–76.3%), showed the strongest tack response (SW = 18.06 mJ), the highest average torque during processing (44.0 Nm), and the largest final particle size (2,254.55 µm), suggesting enhanced agglomeration. Correlation and PCA indicated that particle size and organic content correlate well (r_s = 0.72, p < 0.001), consistent with a potential contribution of organic matter to agglomeration. Despite poor global model fit, exploratory SEM paths were consistent with plausible roles of POF in final particle-size evolution (β = 0.706, p < 0.001) and of initial dry matter content in final drying performance (β = 0.796, p < 0.001). The proposed exploratory statistical framework provides insights into the mechanisms governing PSS formation, but current findings are hypothesis-generating and intended to guide future confirmatory studies.


## Browse the code

The complete R source code is available in the [GitHub repository](https://github.com/USERNAME/REPOSITORY).

## Overview

This repository contains the exploratory statistical analyses used to investigate relationships between sewage-sludge properties and the performance of a pilot-scale thin-film drying-grinding process.

The study evaluates four municipal sewage sludges processed under fixed operating conditions. The analyses examine associations among:

* organic and inorganic sludge composition;
* initial dry matter and particle size;
* rheological and tack-test properties;
* final dry matter, organic content, and particle size.

The dataset contains 24 process observations, while several sludge-level properties are repeated within each sludge source.

## Analyses

The R scripts implement:

* data cleaning and variable transformation;
* descriptive plots and interval estimates;
* Spearman rank-correlation analysis;
* principal component analysis;
* exploratory variable reduction;
* ordinary least-squares regression;
* univariate and multivariate normality assessment;
* exploratory path analysis using structural equation modelling;
* maximum-likelihood estimation with the `MLM` estimator.

Pull-off force is converted to its absolute magnitude so that larger values represent stronger resistance during plate detachment. Numeric variables are standardized before the structural equation model is estimated.

## Scripts

* [`1. dewatering.process.R`](1.%20dewatering.process.R) analyses organic composition, inorganic composition, and initial sludge properties.
* [`2. drying.process.R`](2.%20drying.process.R) analyses rheological and tack-test properties, final product attributes, and their regression relationships.
* [`3. dag.R`](3.%20dag.R) estimates the exploratory structural equation model linking sludge composition, initial properties, pull-off force, and drying-grinding outcomes.

Some alternative model specifications are retained as commented code to document the model-development process and estimation limitations.

## Requirements

The analysis was developed in R and uses the following packages:

```r
tidyverse
readxl
ggcorrplot
correlation
ggbiplot
okcolors
writexl
rstudioapi
dagitty
lmtest
MVN
lavaan
```

Install the required packages before running the scripts.

## Running the analysis

Place the input workbook in the expected data directory and update its filename in the scripts when necessary. The current scripts reference:

```text
20260609_Data_Sensitivity.xlsx
```

Open each script in RStudio and run them in numerical order:

```text
1. dewatering.process.R
2. drying.process.R
3. dag.R
```

The scripts use the location of the active RStudio document to define the working directory. Statistical tables are exported as Excel files to the configured results directory.

## Data considerations

Wastewater treatment plants are represented by anonymized identifiers from `KA-1` to `KA-4`.

The analyses should be interpreted cautiously because:

* the sample contains only 24 observations;
* several explanatory variables are repeated within sludge source;
* the number of candidate variables is large relative to the sample size;
* wastewater-treatment and dewatering practices may act as unmeasured confounders;
* the final structural equation model does not provide adequate global fit.

## Funding

This work was supported by the European Union’s Horizon 2020 research and innovation programme under grant agreement No. 958267, **FlashPhos**.
