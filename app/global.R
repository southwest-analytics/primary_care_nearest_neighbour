## ╔═════════════════════════════════════════════╗
## ║ Global: Data loading + preprocessing engine ║
## ╚═════════════════════════════════════════════╝

# 0. Load libaries and declare functions ----
# ═══════════════════════════════════════════
library(tidyverse)
library(sf)
library(leaflet)
library(DT)
library(shinyjs)
library(ini)
library(flextable)
library(ggiraph)

ini_file_sections <- read.ini("nearest_neighbour_app.ini")

# 1. Load dataset ----
# ════════════════════

# • 1.1. Load detailed data ----
# ──────────────────────────────
df_practice_data <- read.csv(ini_file_sections$filenames$practice_data_filename)
df_pcn_data <- read.csv(ini_file_sections$filenames$pcn_data_filename)

# • 1.2. Load top 10 matches data ----
# ────────────────────────────────────
df_practice_neighbours <- read.csv(ini_file_sections$filenames$practice_top10_filename)
df_pcn_neighbours <- read.csv(ini_file_sections$filenames$pcn_top10_filename)

# • 1.3. Load metadata ----
# ─────────────────────────
df_practice_metadata <- read.csv(ini_file_sections$filenames$practice_metadata_filename)
df_pcn_metadata <- read.csv(ini_file_sections$filenames$pcn_metadata_filename)

# Variable groups are the same for practice and PCN level
var_groups <- levels(as.factor(df_practice_metadata$GROUP))

# 2. Standardise schema ----
# ══════════════════════════

# • 2.1. Detailed data files ----
# ───────────────────────────────

df_practice_clean <- df_practice_data %>%
  rename(
    ORG_CODE  = PRACTICE_CODE,
    ORG_NAME  = PRACTICE_NAME,
    ORG_POSTCODE = PRACTICE_POSTCODE,
    LATITUDE  = LAT,
    LONGITUDE = LNG
  ) %>%
  mutate(LEVEL = "Practice")

df_pcn_clean <- df_pcn_data %>%
  rename(
    ORG_CODE  = PCN_CODE,
    ORG_NAME  = PCN_NAME,
    ORG_POSTCODE = PCN_POSTCODE,
    LATITUDE  = LAT,
    LONGITUDE = LNG
  ) %>%
  mutate(LEVEL = "PCN")

# ## Combine for convenience (optional but useful)
# df_all <- bind_rows(df_practice_clean, df_pcn_clean)

# • 2.2. Variable names ----
# ──────────────────────────
var_practice <- df_practice_metadata %>% filter(!(TYPE %in% c("FCT", "GEO"))) %>% pull(FIELD_NAME)
var_pcn <- df_pcn_metadata %>% filter(!(TYPE %in% c("FCT", "GEO"))) %>% pull(FIELD_NAME)

# • 2.3. Variable groups ----
# ───────────────────────────
# Variable groups are the same for practice and PCN levels
var_groups <- levels(as.factor(df_practice_metadata$GROUP))

# • 2.4. NHS England region list ----
# ───────────────────────────────────
# NHS England regions are the same for practice and PCN levels
var_regions <- df_practice_clean %>% 
  distinct(NHSER_CODE, NHSER_NAME) %>%
  mutate(LABEL = sprintf("[%s] - %s", NHSER_CODE, NHSER_NAME)) %>%
  select(LABEL, NHSER_CODE) %>%
  deframe()

# 4. Core Helper functions ----
# ═════════════════════════════

# • 4.1. Get dataset by level ----
# ────────────────────────────────

fnGetData <- function(level) {
  if (level == "Practice") {
    df_practice_clean
  } else {
    df_pcn_clean
  }
}

# • 4.2. Get nearest neighbours ----
# ──────────────────────────────────

fnGetNearestNeighbours <- function(org_code, level, type = "ALL") {
  df_nn <- if (level == "Practice") {
    df_practice_neighbours
  } else {
    df_pcn_neighbours
  }
  
  df_nn %>% 
    filter(
      ORIG == org_code,
      TYPE == type
    ) %>%
    arrange(DISTANCE) %>%
    pull(DEST)
}

# • 4.3. Get comparison dataset ----
# ──────────────────────────────────

fnGetComparisonData <- function(org_code, level, type, var) {
  df <- fnGetData(level)
  nearest_neighbours <- fnGetNearestNeighbours(org_code, level, type)
  
  df %>%
    select(ORG_CODE, ORG_NAME, VALUE = all_of(var)) %>%
    mutate(
      GROUP = case_when(
        ORG_CODE == org_code             ~ "Origin",
        ORG_CODE %in% nearest_neighbours ~ "Neighbour",
        TRUE                             ~ "National"
      )
    ) %>%
    filter(GROUP != "National" | TRUE)  ## keep full dataset for boxplot
}

# • 4.4. Quick summary for insight ----
# ─────────────────────────────────────

fnGetPerformanceSummary <- function(org_code, level, type, var) {
  df <- fnGetComparisonData(org_code, level, type, var)
  
  origin_val <- df %>%
    filter(GROUP == "Origin") %>%
    pull(VALUE)
  
  neighbours <- df %>%
    filter(GROUP == "Neighbour") %>%
    pull(VALUE)
  
  lower <- sum(neighbours < origin_val, na.rm = TRUE)
  higher  <- sum(neighbours > origin_val, na.rm = TRUE)
  
  list(
    higher = higher,
    lower  = lower,
    total  = length(neighbours)
  )
}


# Example function calls
# fnGetComparisonData(org_code = "L83066", level = "Practice", type = "ALL", var = "QOF_ACHV_AF006")
# fnGetPerformanceSummary(org_code = "L83066", level = "Practice", type = "ALL", var = "QOF_ACHV_AF006")
