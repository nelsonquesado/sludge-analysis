# Sewage Sludge Drying–Grinding Statistical Analysis

R code supporting the manuscript:

> **Exploring a drying-grinding system for pulverized sewage sludge production**

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
