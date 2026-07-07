# Nearest Neighbour Comparison Tool

## Overview

The Nearest Neighbour Comparison Tool provides benchmarking for:

- GP Practices
- Primary Care Networks (PCNs)

The tool identifies organisations with similar characteristics using a
multivariate nearest-neighbour approach based on demographic,
socioeconomic, clinical, workforce and financial indicators.

## Why nearest neighbours?

Traditional benchmarking often compares organisations based on geography.

This approach instead compares organisations with similar populations and
operating environments to support fairer and more meaningful comparison.

## Data Sources

### Population and Demography

- Census 2021
- GP Registration Data

### Deprivation

- English Indices of Deprivation 2025

### Clinical

- Quality and Outcomes Framework

### Workforce

- General Practice Workforce
- PCN Workforce

### Finance

- NHS Payments to General Practice

### Geography

- ONS Postcode Directory
- ODS Reference Data

## Analytical Pipeline

### Step 1 – Data Ingestion

Raw source datasets are imported and validated.

### Step 2 – Geographic Attribution

LSOA-level indicators are attributed to organisations using registered
patient populations.

### Step 3 – Feature Engineering

Examples include:

- Population-weighted ethnicity
- Population-weighted deprivation
- Population density
- Age distribution statistics
- Workforce metrics
- Financial indicators

### Step 4 – Dataset Assembly

Separate datasets are produced for:

- Practices
- PCNs

### Step 5 – Standardisation

Variables are standardised before matching.

### Step 6 – Correlation Reduction

Variables with:

|r| ≥ 0.975

are removed iteratively.

### Step 7 – Distance Calculation

Euclidean distance is calculated between all organisations.

### Step 8 – Neighbour Selection

The ten closest organisations are retained.

Neighbour sets are produced for:

- National
- NHS Region
- ICB

## Repository Structure

```text
/
├── create_neighbour_data.R
├── app.R
├── global.R
├── server.R
├── ui.R
├── data/
├── www/
└── README.md