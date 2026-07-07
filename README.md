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
primary_care_nearest_neighbour/

├── app.R
├── global.R
├── server.R
├── ui.R
├── create_neighbour_data.R
│
├── www/
│   ├── hisw.css
│   ├── HISW_Logo_RGB_Negative.png
│   ├── methodology.html
│   └── data_sources.html
│
├── sample_data/
│   ├── df_practice_data_SAMPLE.csv
│   ├── df_pcn_data_SAMPLE.csv
│   ├── df_top10_practices_SAMPLE.csv
│   └── df_top10_pcn_SAMPLE.csv
│
├── links.txt
├── README.md
├── CONTRIBUTING.md
├── LICENSE
└── .gitignore
```

### Files

| File | Purpose |
|--------|----------|
| `create_neighbour_data.R` | Creates all analytical datasets and neighbour tables |
| `app.R` | Application entry point |
| `global.R` | Loads packages, data and helper objects |
| `ui.R` | User interface definition |
| `server.R` | Server-side application logic |
| `links.txt` | Download locations for all source datasets |
| `www/` | Static web assets and documentation |
| `sample_data/` | Example outputs for demonstration and testing |

### Excluded Content

The following items are intentionally excluded from the repository:

- Raw source datasets
- Downloaded NHS publications
- Census extracts
- IMD datasets
- Generated `.RObj` files
- Large derived analytical datasets

These can all be recreated using the scripts provided in this repository.