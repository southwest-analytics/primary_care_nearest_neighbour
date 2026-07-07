# 0. Load libaries and declare functions ----
# ═══════════════════════════════════════════
library(tidyverse)
library(readxl)
library(sf)
library(spaa)

#oddir <- "E:/OneDrive - Health Innovation South West"
oddir <- "C:/Users/richard.blackwell/OneDrive - Health Innovation South West"

setwd(paste0(oddir, "/Workspace/primary_care_nearest_neighbour"))

# • 0.1. File locations ----
# ──────────────────────────

# • • 0.1.1. Census data ----
filTS021Ethnicity <- paste0(oddir, "/Workspace/nearest_neighbour_data/census/census2021-ts021-lsoa.csv")

# • • 0.1.2. GP registration data ----
# LSOA level
filLSOAPersons <- paste0(oddir, "/Workspace/nearest_neighbour_data/gp_reg/gp-reg-pat-prac-lsoa-all.csv")
# Single year of age
filSYOAFemales <- paste0(oddir, "/Workspace/nearest_neighbour_data/gp_reg/gp-reg-pat-prac-sing-age-female.csv")
filSYOAMales <- paste0(oddir, "/Workspace/nearest_neighbour_data/gp_reg/gp-reg-pat-prac-sing-age-male.csv")
# Organisation mapping
filOrgMap <- paste0(oddir, "/Workspace/nearest_neighbour_data/gp_reg/gp-reg-pat-prac-map.csv")

# • • 0.1.3. Indices of Multiple Deprivation (IMD) data ----
filIMDDomains <- paste0(oddir, "/Workspace/nearest_neighbour_data/imd/File_7_IoD2025_All_Ranks_Scores_Deciles_Population_Denominators.csv")
filIMDIndicators <- paste0(oddir, "/Workspace/nearest_neighbour_data/imd/File_8_IoD2025_Underlying_Indicators.xlsx")
shtIMDIncome <- "IoD25 Income Domain"
shtIMDEmployment <- "IoD25 Employment Domain"
shtIMDEducation <- "IoD25 Education Domain"
shtIMDHealth <- "IoD25 Health Domain"
shtIMDCrime <- "IoD25 Crime Domain"
shtIMDBarriers <- "IoD25 Barriers Domain"
shtIMDEnvironment <- "IoD25 Living Env Domain"

# • • 0.1.4. Lookups ----
filPostcodeLU <- paste0(oddir, "/Workspace/nearest_neighbour_data/lookups/ONSPD_FEB_2026_UK.csv")
filICBRegionLU <- paste0(oddir, "/Workspace/nearest_neighbour_data/lookups/Sub_ICB_Locations_to_Integrated_Care_Boards_to_NHS_England_(Region)_(2024)_Lookup_in_EN.csv")

# • • 0.1.5. Organisations ----
# NO LONGER NEEDED AS WE WILL USE GP registration data organisation mapping as the master index
# filPractices <- paste0(oddir, "/Workspace/nearest_neighbour_data/org/epraccur.csv")
# filPCNs <- paste0(oddir, "/Workspace/nearest_neighbour_data/org/epcn.csv")
# filPCNMembers <- paste0(oddir, "/Workspace/nearest_neighbour_data/org/epcncorepartnerdetails.csv")

# • • 0.1.6. Payments ----
filPracticePayments <- paste0(oddir, "/Workspace/nearest_neighbour_data/payments/nhspaymentsgp-24-25-prac-csv.csv")
filPCNPayments <- paste0(oddir, "/Workspace/nearest_neighbour_data/payments/nhspaymentsgp-24-25-pcn-csv.csv")

# • • 0.1.7. Quality and Outcomes Framework (QOF) ----
filQOFPrevalence <- paste0(oddir, "/Workspace/nearest_neighbour_data/qof/PREVALENCE_2425.csv")
filQOFAchievementEast <- paste0(oddir, "/Workspace/nearest_neighbour_data/qof/ACHIEVEMENT_EAST_OF_ENGLAND_2425.csv")
filQOFAchievementLondon <- paste0(oddir, "/Workspace/nearest_neighbour_data/qof/ACHIEVEMENT_LONDON_2425.csv")
filQOFAchievementMidlands <- paste0(oddir, "/Workspace/nearest_neighbour_data/qof/ACHIEVEMENT_MIDLANDS_2425.csv")
filQOFAchievementNorthEast <- paste0(oddir, "/Workspace/nearest_neighbour_data/qof/ACHIEVEMENT_NORTH_EAST_AND_YORKSHIRE_2425.csv")
filQOFAchievementNorthWest <- paste0(oddir, "/Workspace/nearest_neighbour_data/qof/ACHIEVEMENT_NORTH_WEST_2425.csv")
filQOFAchievementSouthEast <- paste0(oddir, "/Workspace/nearest_neighbour_data/qof/ACHIEVEMENT_SOUTH_EAST_2425.csv")
filQOFAchievementSouthWest <- paste0(oddir, "/Workspace/nearest_neighbour_data/qof/ACHIEVEMENT_SOUTH_WEST_2425.csv")
filQOFIndicators <- paste0(oddir, "/Workspace/nearest_neighbour_data/qof/MAPPING_INDICATORS_2425.csv")
filQOFOrganisations <- paste0(oddir, "/Workspace/nearest_neighbour_data/qof/MAPPING_NHS_GEOGRAPHIES_2425.csv")
# Not used
# paste0(oddir, "/Workspace/nearest_neighbour_data/qof/ORGANISATION_REFERENCE_2425.csv"
# paste0(oddir, "/Workspace/nearest_neighbour_data/qof/PRACTICE_VALIDATION_OUTCOMES_2425.csv"

# • • 0.1.8. Workforce ----
filPracticeWorkforce <- paste0(oddir, "/Workspace/nearest_neighbour_data/workforce/3 General Practice – February 2026 Practice Level - High level.csv")
filPCNWorkforce <- paste0(oddir, "/Workspace/nearest_neighbour_data/workforce/1.Primary Care Networks - February 2026 Individual Level.csv")
# paste0(oddir, "/Workspace/nearest_neighbour_data/workforce/0.General Practice Individual-Level CSV. Overall Definitions.xlsx")
# paste0(oddir, "/Workspace/nearest_neighbour_data/workforce/0 General Practice Detailed Practice-Level CSV. Overall Definitions.xlsx")
# paste0(oddir, "/Workspace/nearest_neighbour_data/workforce/0.Primary Care Network Individual-Level CSV overall definitions.xlsx")
# paste0(oddir, "/Workspace/nearest_neighbour_data/workforce/2 General Practice High-level Practice-Level CSV. Overall Definitions.xlsx")
# paste0(oddir, "/Workspace/nearest_neighbour_data/workforce/1 General Practice – February 2026 Practice Level - Detailed.csv")
# paste0(oddir, "/Workspace/nearest_neighbour_data/workforce/1.General Practice – February 2026 Individual Level.csv")

# • • 0.1.9. Geography ----
filLSOABoundaries <- paste0(oddir, "/Workspace/nearest_neighbour_data/lookups/Lower_layer_Super_Output_Areas_December_2021_Boundaries_EW_BGC_V5_-6970154227154374572.gpkg")
filICBBoundaries <- paste0(oddir, "/Workspace/nearest_neighbour_data/lookups/Integrated_Care_Boards_April_2023_EN_BGC_1474172695433165556.gpkg")

# 1. Load data ----
# ═════════════════

# • 1.0. Load master dataset ----
# ───────────────────────────────

# Change of master index, we will use the GP registration file as the master 
# index as this is sufficiently up-to-date to ensure the practices/PCNs are 
# still present. This will be done in section 1.2
# NO LONGER NEEDED: df_practice_master <- read.csv(filOrgMap) %>% distinct(PRACTICE_CODE) %>% rename(ORG_CODE = PRACTICE_CODE)
# NO LONGER NEEDED: df_pcn_master <- read.csv(filOrgMap) %>% distinct(PCN_CODE) %>% dplyr::filter(PCN_CODE!="U") %>% rename(ORG_CODE = PCN_CODE)

# • 1.1. Census data ----
# ───────────────────────

# Select the top level groupings for ethnicity
df_ethnicity <- read.csv(filTS021Ethnicity) %>% 
  select(geography.code,
         Ethnic.group..Total..All.usual.residents,
         Ethnic.group..Asian..Asian.British.or.Asian.Welsh,
         Ethnic.group..Black..Black.British..Black.Welsh..Caribbean.or.African,
         Ethnic.group..Mixed.or.Multiple.ethnic.groups,
         Ethnic.group..White,
         Ethnic.group..Other.ethnic.group) %>%
  rename_with(.fn = ~c("LSOA21CD", "ETHNICITY_POPN", 
                       "ETHNICITY_ASIAN", "ETHNICITY_BLACK", "ETHNICITY_MIXED", "ETHNICITY_WHITE", "ETHNICITY_OTHER"))

# • 1.2. GP registration data ----
# ────────────────────────────────

# • • 1.2.1. Organisation mapping ----
df_org_map <- read.csv(filOrgMap)

# • • 1.2.2. Organisation to geography mapping ----
# Practice and geography data
df_practice_lsoa <- read.csv(filLSOAPersons) %>% 
  # Keep England LSOAs only
  dplyr::filter(grepl("^E", LSOA_CODE) & LSOA_CODE!="EMPTY") %>%
  mutate(PRACTICE_CODE, LSOA21CD = LSOA_CODE, POPN = NUMBER_OF_PATIENTS, .keep = "none")

# PCN and geography data
df_pcn_lsoa <- df_practice_lsoa %>% 
  left_join(df_org_map, by = "PRACTICE_CODE") %>%
  select(PCN_CODE, LSOA21CD, POPN) %>%
  group_by(PCN_CODE, LSOA21CD) %>%
  summarise(POPN = sum(POPN), .groups = "keep") %>%
  ungroup() %>%
  # Discard any non-PCN data (U unmatched)
  dplyr::filter(PCN_CODE!="U")

# • • 1.2.3. Demography data ----
# Practice demography
df_practice_demography <- read.csv(filSYOAFemales) %>%
  mutate(PRACTICE_CODE = ORG_CODE, GENDER = SEX, AGE, POPN = NUMBER_OF_PATIENTS, .keep = "none") %>%
  bind_rows(read.csv(filSYOAMales) %>%
              mutate(PRACTICE_CODE = ORG_CODE, GENDER = SEX, AGE, POPN = NUMBER_OF_PATIENTS, .keep = "none")) %>%
  dplyr::filter(AGE!="ALL") %>%
  mutate(AGE = as.integer(if_else(AGE == "95+", "95", AGE)))

df_practice_demography <- df_practice_demography %>%
  bind_rows(df_practice_demography %>% 
              group_by(PRACTICE_CODE, AGE) %>%
              summarise(POPN = sum(POPN), .groups = "keep") %>%
              ungroup() %>%
              mutate(GENDER = "PERSONS"))
              
# PCN demography
df_pcn_demography <- df_practice_demography %>%
  left_join(df_org_map %>% select(PRACTICE_CODE, PCN_CODE), by = "PRACTICE_CODE") %>%
  dplyr::filter(PCN_CODE!="U") %>%
  group_by(PCN_CODE, GENDER, AGE) %>%
  summarise(POPN = sum(POPN), .groups = "keep") %>%
  ungroup()

# • 1.3. Indices of Multiple Deprivation (IMD) data ----
# ──────────────────────────────────────────────────────
# Domains
imd_domain_names <- c("IMD", "INCOME", "EMPLOYMENT", "EDUCATION", "HEALTH", "CRIME", "BARRIERS", "ENVIRONMENT",
                      "INCOME_IDACI", "INCOME_IDAOPI", "EDUCATION_CYP", "EDUCATION_ADULT", 
                      "BARRIERS_GEOGRAPHICAL", "BARRIERS_WIDER", "ENVIRONMENT_INDOOR", "ENVIRONMENT_OUTDOOR")

df_imd_domain <- read.csv(filIMDDomains) %>% 
  # # Select scores for matching and deciles for display
  # select(1, seq(5, 50, 3), seq(7, 52, 3)) %>%
  # rename_with(.fn = ~c("LSOA21CD", paste0(imd_domain_names, "_SCORE"), paste0(imd_domain_names, "_DECILE")))
  # Select scores only as we will create deciles for practices and PCNs
  select(1, seq(5, 50, 3)) %>%
  rename_with(.fn = ~c("LSOA21CD", paste0(imd_domain_names, "_SCORE")))

# Underlying indicators
df_imd_indicators <- readxl::read_excel(path = filIMDIndicators, sheet = shtIMDIncome) %>% 
  select(1, 5:7) %>%
  rename_with(.fn = ~c("LSOA21CD", "INCOME_NUMERATOR", "IDACI_NUMERATOR", "IDAOPI_NUMERATOR")) %>%
  left_join(
    readxl::read_excel(path = filIMDIndicators, sheet = shtIMDEmployment) %>% 
      select(1, 5) %>%
      rename_with(.fn = ~c("LSOA21CD", "EMPLOYMENT_NUMERATOR")),
    by = "LSOA21CD") %>%
  left_join(
    readxl::read_excel(path = filIMDIndicators, sheet = shtIMDEducation) %>% 
      select(1, 5:6) %>%
      rename_with(.fn = ~c("LSOA21CD", "EDUCATION_ADULT_LANGUAGE_PROFICIENCY", "EDUCATION_CYP_HIGHER_EDUCATION_ENTRY")),
    by = "LSOA21CD") %>% 
  left_join(
    readxl::read_excel(path = filIMDIndicators, sheet = shtIMDHealth) %>% 
      select(1, 5:8) %>%
      rename_with(.fn = ~c("LSOA21CD", "HEALTH_ACUTE_MORBIDITY", "HEALTH_ILLNESS_AND_DISABILITY_RATIO", "HEALTH_MENTAL_HEALTH", "HEALTH_YLL")),
    by = "LSOA21CD") %>% 
  left_join(
    readxl::read_excel(path = filIMDIndicators, sheet = shtIMDCrime) %>% 
      select(1, 5:12) %>%
      rename_with(.fn = ~c("LSOA21CD", "CRIME_VIOLENCE_WITH_INJURY", "CRIME_VIOLENCE_WITHOUT_INJURY", "CRIME_STALKING_HARASSMENT",
                           "CRIME_BURGLARY", "CRIME_THEFT", "CRIME_CRIMINAL_DAMAGE", "CRIME_PUBLIC_ORDER", "CRIME_ASB")),
    by = "LSOA21CD") %>% 
  left_join(
    readxl::read_excel(path = filIMDIndicators, sheet = shtIMDBarriers) %>% 
      select(1, 5:14) %>%
      rename_with(.fn = ~c("LSOA21CD", "BARRIERS_CONNECTIVITY", 
                           "BARRIERS_OWNER_OCCUPIER_AFFORDABILITY", "BARRIERS_PRIVATE_RENTAL_AFFORDABILITY", "BARRIERS_HOUSING_AFFORDABILITY",
                           "BARRIERS_DIGITAL_CONNECTIVITY", "BARRIERS_CORE_HOMELESSNESS", "BARRIERS_PATIENT_TO_GP", "BARRIERS_HOMELESSNESS_RATE",
                           "BARRIERS_OVERCROWDING_ROOMS", "BARRIERS_OVERCROWDING_BEDROOMS")),
    by = "LSOA21CD") %>% 
  left_join(
    readxl::read_excel(path = filIMDIndicators, sheet = shtIMDEnvironment) %>% 
      select(1, 5:14) %>%
      rename_with(.fn = ~c("LSOA21CD", "ENVIRONMENT_POOR_HOUSING", "ENVIRONMENT_ENERGY_PERFORMANCE", "ENVIRONMENT_LACK_OF_OUTDOOR_SPACE",  
                           "ENVIRONMENT_NOISE_POLLUTION", "ENVIRONMENT_TRAFFIC_CASUALITIES", "ENVIRONMENT_SUPLHUR_DIOXIDE", "ENVIRONMENT_NITROGEN_DIOXIDE", 
                           "ENVIRONMENT_BENZENE", "ENVIRONMENT_PARTICULATES", "ENVIRONMENT_AIR_QUALITY")),
    by = "LSOA21CD") %>%
  # Replace suppressed values NA with zeros
  mutate(across(everything(), ~replace_na(.x, 0)))

# • 1.4. Lookups ----
# ───────────────────

# Postcodes
df_pcode_lu <- read.csv(filPostcodeLU) %>% 
  select(3, 51, 49, 12, 13, 42, 43) %>%
  rename_with(.fn = ~c("PCODE", "LSOA21CD", "ICB23CD", "EASTING", "NORTHING", "LAT", "LNG"))

# SIBL to ICB to Region
df_sicbl_lu <- read.csv(filICBRegionLU) %>% 
  distinct(SICBL24CD, SICBL24CDH, SICBL24NM,
           ICB24CD, ICB24CDH, ICB24NM, 
           NHSER24CD, NHSER24CDH, NHSER24NM)

# • 1.5. Organisations ----
# ─────────────────────────

# Most of this is no longer needed as we will use GP registration data 
# organisation mapping as the master index, but we still need the ePCN data
# as this contains the postcode of the PCN.
#
filPCNs <- paste0(oddir, "/Workspace/nearest_neighbour_data/org/epcn.csv")
# filPractices <- paste0(oddir, "/Workspace/nearest_neighbour_data/org/epraccur.csv")
# filPCNMembers <- paste0(oddir, "/Workspace/nearest_neighbour_data/org/epcncorepartnerdetails.csv")

# PCN details
df_pcn <- read.csv(filPCNs, header = FALSE) %>%
  select(1, 12, 6) %>%
  rename_with(.fn = ~c("PCN_CODE", "PCN_POSTCODE", "CLOSE_DATE")) %>%
  dplyr::filter(is.na(CLOSE_DATE)) %>%
  select(-CLOSE_DATE)

# # Practice details
# df_practice <- read.csv(filPractices, header = FALSE) %>% 
#   select(1:2, 10, 3:4, 13, 26) %>% 
#   rename_with(.fn = ~c("PRACTICE_CODE", "PRACTICE_NAME", "POSTCODE", "NHSER_CODE", "ICB_CODE", "STATUS", "ROLE_ID")) %>%
#   dplyr::filter(STATUS=="ACTIVE" & ROLE_ID=="RO76") %>%
#   select(-c(STATUS, ROLE_ID))
# # NB: ROLE_ID == "RO76" GP Practice
#   
# # PCN member details
# df_pcn_member <- read.csv(filPCNMembers, header = FALSE) %>% 
#   select(5, 1:3, 10) %>%
#   rename_with(.fn = ~c("PCN_CODE", "PRACTICE_CODE", "PRACTICE_NAME", "SICB_CODE", "END_DATE")) %>%
#   dplyr::filter(is.na(END_DATE)) %>%
#   select(-END_DATE) %>%
#   left_join(df_sicbl_lu, by = c("SICB_CODE" = "SICBL24CDH")) %>% 
#   mutate(PCN_CODE, PRACTICE_CODE, NHSER_CODE = NHSER24CDH, ICB_CODE = ICB24CDH, .keep = "none")

# • 1.6. Payments ----
# ────────────────────
filPracticePayments <- paste0(oddir, "/Workspace/nearest_neighbour_data/payments/nhspaymentsgp-24-25-prac-csv.csv")
filPCNPayments <- paste0(oddir, "/Workspace/nearest_neighbour_data/payments/nhspaymentsgp-24-25-pcn-csv.csv")

# Practice payments
df_practice_payments <- read.csv(filPracticePayments) %>% 
  select(7, 18:19, 62) %>% 
  rename_with(.fn = ~c("PRACTICE_CODE", "LIST_SIZE", "WEIGHTED_LIST_SIZE", "TOTAL_PAYMENTS")) %>%
  mutate(MEAN_PAYMENTS = TOTAL_PAYMENTS / LIST_SIZE,
         MEAN_WEIGHTED_PAYMENTS = TOTAL_PAYMENTS / WEIGHTED_LIST_SIZE)

# PCN payments
df_pcn_payments <- read.csv(filPCNPayments) %>% 
  select(3, 5:7) %>% 
  rename_with(.fn = ~c("PCN_CODE", "LIST_SIZE", "WEIGHTED_LIST_SIZE", "TOTAL_PAYMENTS")) %>%
  mutate(MEAN_PAYMENTS = TOTAL_PAYMENTS / LIST_SIZE,
         MEAN_WEIGHTED_PAYMENTS = TOTAL_PAYMENTS / WEIGHTED_LIST_SIZE)

# • 1.7. Quality and Outcomes Framework (QOF) ----
# ────────────────────────────────────────────────

# Prevalence
df_qof_prevalence <- read.csv(filQOFPrevalence) %>% 
  select(1, 2, 3, 5) %>%
  rename_with(.fn = ~c("PRACTICE_CODE", "REGISTER", "NUMERATOR", "DENOMINATOR")) %>%
  mutate(PREVALENCE = NUMERATOR / DENOMINATOR)

# Achievement
df_qof_achievement <- read.csv(filQOFAchievementEast) %>% 
  select(4:7) %>%
  rename_with(.fn = ~c("PRACTICE_CODE", "INDICATOR_CODE", "MEASURE", "VALUE")) %>%
  dplyr::filter(MEASURE %in% c("NUMERATOR", "DENOMINATOR", "PCAS")) %>%
  pivot_wider(names_from = "MEASURE", values_from = "VALUE") %>%
  bind_rows(read.csv(filQOFAchievementLondon) %>% 
              select(4:7) %>%
              rename_with(.fn = ~c("PRACTICE_CODE", "INDICATOR_CODE", "MEASURE", "VALUE")) %>%
              dplyr::filter(MEASURE %in% c("NUMERATOR", "DENOMINATOR", "PCAS")) %>%
              pivot_wider(names_from = "MEASURE", values_from = "VALUE")) %>%
  bind_rows(read.csv(filQOFAchievementMidlands) %>% 
              select(4:7) %>%
              rename_with(.fn = ~c("PRACTICE_CODE", "INDICATOR_CODE", "MEASURE", "VALUE")) %>%
              dplyr::filter(MEASURE %in% c("NUMERATOR", "DENOMINATOR", "PCAS")) %>%
              pivot_wider(names_from = "MEASURE", values_from = "VALUE")) %>%
  bind_rows(read.csv(filQOFAchievementNorthEast) %>% 
              select(4:7) %>%
              rename_with(.fn = ~c("PRACTICE_CODE", "INDICATOR_CODE", "MEASURE", "VALUE")) %>%
              dplyr::filter(MEASURE %in% c("NUMERATOR", "DENOMINATOR", "PCAS")) %>%
              pivot_wider(names_from = "MEASURE", values_from = "VALUE")) %>%
  bind_rows(read.csv(filQOFAchievementNorthWest) %>% 
              select(4:7) %>%
              rename_with(.fn = ~c("PRACTICE_CODE", "INDICATOR_CODE", "MEASURE", "VALUE")) %>%
              dplyr::filter(MEASURE %in% c("NUMERATOR", "DENOMINATOR", "PCAS")) %>%
              pivot_wider(names_from = "MEASURE", values_from = "VALUE")) %>%
  bind_rows(read.csv(filQOFAchievementSouthEast) %>% 
              select(4:7) %>%
              rename_with(.fn = ~c("PRACTICE_CODE", "INDICATOR_CODE", "MEASURE", "VALUE")) %>%
              dplyr::filter(MEASURE %in% c("NUMERATOR", "DENOMINATOR", "PCAS")) %>%
              pivot_wider(names_from = "MEASURE", values_from = "VALUE")) %>%
  bind_rows(read.csv(filQOFAchievementSouthWest) %>% 
              select(4:7) %>%
              rename_with(.fn = ~c("PRACTICE_CODE", "INDICATOR_CODE", "MEASURE", "VALUE")) %>%
              dplyr::filter(MEASURE %in% c("NUMERATOR", "DENOMINATOR", "PCAS")) %>%
              pivot_wider(names_from = "MEASURE", values_from = "VALUE"))
  
# Indicators
df_qof_indicators <- read.csv(filQOFIndicators) %>% select(1:2, 4:5)

# Organisations
df_qof_org_map <- read.csv(filQOFOrganisations)

# • 1.8. Workforce ----
# ─────────────────────

# Practice workforce
df_practice_workforce <- read.csv(filPracticeWorkforce) %>% 
  select(1, 3, 5:6) %>% 
  rename(PRACTICE_CODE = PRAC_CODE) %>%
  dplyr::filter(MEASURE == "FTE") %>%
  group_by(PRACTICE_CODE, STAFF_GROUP) %>%
  summarise(FTE = sum(VALUE, na.rm = TRUE), .groups = "keep") %>%
  ungroup()

# PCN workforce
df_pcn_workforce <- read.csv(filPCNWorkforce) %>% 
  select(4, 12, 15) %>% 
  group_by(PCN_CODE, STAFF_GROUP) %>%
  summarise(FTE = sum(FTE, na.rm = TRUE), .groups = "keep") %>%
  ungroup()

# • 1.9. Geography ----
# ─────────────────────

# Lower-layer Super Output Area (LSOA) boundaries
sf_lsoa21 <- sf::st_read(filLSOABoundaries) %>%
  sf::st_transform(crs = 4326) %>%
  dplyr::filter(grepl("^E", LSOA21CD)) %>%
  mutate(AREA_SQ_KM = as.numeric(sf::st_area(.)/1e6))

# ICB boundaries 
sf_icb23 <- sf::st_read(filICBBoundaries) %>%
  sf::st_transform(crs = 4326)

# 2. Process data ----
# ════════════════════

list_dataframes <- c("df_practice_master", "df_pcn_master")

# • 2.1. Census data ----
# ───────────────────────

# Create practice weighted ethnicity
df_practice_weighted_ethnicity <- df_practice_lsoa %>%
  left_join(df_ethnicity, by = "LSOA21CD") %>% 
  mutate(across(.cols = 5:9, .fns = function(x){POPN * (x/ETHNICITY_POPN)}, .names = "{.col}_WEIGHTED")) %>% 
  group_by(PRACTICE_CODE) %>%
  summarise(across(.cols = c(2,9:13), .fns = sum)) %>%
  ungroup() %>%
  mutate(across(.cols = 3:7, .fns = function(x){x/POPN}, .names = "{.col}_PCT")) %>% 
  select(1, 8:12)
    
# Create PCN weighted ethnicity
df_pcn_weighted_ethnicity <- df_pcn_lsoa %>%
  left_join(df_ethnicity, by = "LSOA21CD") %>% 
  mutate(across(.cols = 5:9, .fns = function(x){POPN * (x/ETHNICITY_POPN)}, .names = "{.col}_WEIGHTED")) %>% 
  group_by(PCN_CODE) %>%
  summarise(across(.cols = c(2,9:13), .fns = sum)) %>%
  ungroup() %>%
  mutate(across(.cols = 3:7, .fns = function(x){x/POPN}, .names = "{.col}_PCT")) %>% 
  select(1, 8:12)

list_dataframes <- append(list_dataframes, c("df_practice_weighted_ethnicity", "df_pcn_weighted_ethnicity"))

# • 2.2. GP registration data ----
# ────────────────────────────────

stat_names <- c("25%" = "Q1", "50%" = "MEDIAN", "75%" = "Q3")

# Practice master index
df_practice_master <- df_org_map %>% 
  mutate(PRACTICE_CODE, PRACTICE_NAME, PRACTICE_POSTCODE,
         ICB_CODE, ICB_NAME = gsub(" Integrated Care Board", " ICB", ICB_NAME), 
         NHSER_CODE = COMM_REGION_CODE, NHSER_NAME = COMM_REGION_NAME, .keep = "none") %>%
  inner_join(df_pcode_lu, by = c("PRACTICE_POSTCODE" = "PCODE"))

# PCN master index - NOTE this is using an inner join i.e. if we can't find a 
# postcode we can't map the PCN 
df_pcn_master <- df_org_map %>% mutate(PCN_CODE, PCN_NAME, 
                                       ICB_CODE, ICB_NAME = gsub(" Integrated Care Board", " ICB", ICB_NAME), 
                                       NHSER_CODE = COMM_REGION_CODE, NHSER_NAME = COMM_REGION_NAME, .keep = "none") %>%
  distinct(PCN_CODE, PCN_NAME, ICB_CODE, ICB_NAME, NHSER_CODE, NHSER_NAME) %>%
  inner_join(df_pcn, by = "PCN_CODE") %>%
  inner_join(df_pcode_lu, by = c("PCN_POSTCODE" = "PCODE"))

# Population density
df_lsoa_popn_density <- df_practice_lsoa %>%
  group_by(LSOA21CD) %>%
  summarise(POPN = sum(POPN)) %>%
  ungroup() %>%
  left_join(sf_lsoa21 %>% select(LSOA21CD, AREA_SQ_KM) %>% st_drop_geometry(), by = "LSOA21CD") %>%
  mutate(POPN_PER_SQ_KM = POPN / AREA_SQ_KM) %>%
  select(1, 4)

# Practice demography
df_practice_demography <- df_practice_demography %>% 
  group_by(PRACTICE_CODE, GENDER) %>%
  reframe(VALUE = quantile(x = rep(AGE, POPN), probs = c(0.25, 0.5, 0.75))) %>%
  ungroup() %>%
  mutate(STAT = stat_names[names(VALUE)]) %>%
  mutate(STAT = unname(STAT), VALUE = unname(VALUE)) %>% 
  bind_rows(df_practice_demography %>% 
              group_by(PRACTICE_CODE, GENDER) %>%
              summarise(STAT = "POPN", VALUE = sum(POPN), .groups = "keep") %>%
              ungroup()) %>%
  arrange(PRACTICE_CODE, GENDER, STAT) %>%
  pivot_wider(names_from = STAT, values_from = VALUE) %>%
  mutate(IQR = (Q3 - Q1)) %>%
  pivot_wider(names_from = GENDER, values_from = c(Q1, MEDIAN, Q3, IQR, POPN))

# PCN demography
df_pcn_demography <- df_pcn_demography %>% 
  group_by(PCN_CODE, GENDER) %>%
  reframe(VALUE = quantile(x = rep(AGE, POPN), probs = c(0.25, 0.5, 0.75))) %>%
  ungroup() %>%
  mutate(STAT = stat_names[names(VALUE)]) %>%
  mutate(STAT = unname(STAT), VALUE = unname(VALUE)) %>% 
  bind_rows(df_pcn_demography %>% 
              group_by(PCN_CODE, GENDER) %>%
              summarise(STAT = "POPN", VALUE = sum(POPN), .groups = "keep") %>%
              ungroup()) %>%
  arrange(PCN_CODE, GENDER, STAT) %>%
  pivot_wider(names_from = STAT, values_from = VALUE) %>%
  mutate(IQR = (Q3 - Q1)) %>%
  pivot_wider(names_from = GENDER, values_from = c(Q1, MEDIAN, Q3, IQR, POPN))

# Practice population density
df_practice_popn_density <- df_practice_lsoa %>% 
  left_join(df_lsoa_popn_density, by = "LSOA21CD") %>%
  mutate(POPN_PER_SQ_KM_WEIGHTED = POPN * POPN_PER_SQ_KM) %>%
  group_by(PRACTICE_CODE) %>%
  summarise(POPN = sum(POPN),
            POPN_PER_SQ_KM_WEIGHTED = sum(POPN_PER_SQ_KM_WEIGHTED)) %>%
  ungroup() %>%
  mutate(POPN_PER_SQ_KM_WEIGHTED = POPN_PER_SQ_KM_WEIGHTED / POPN) %>%
  select(-POPN)

# PCN population density
df_pcn_popn_density <- df_pcn_lsoa %>% 
  left_join(df_lsoa_popn_density, by = "LSOA21CD") %>%
  mutate(POPN_PER_SQ_KM_WEIGHTED = POPN * POPN_PER_SQ_KM) %>%
  group_by(PCN_CODE) %>%
  summarise(POPN = sum(POPN),
            POPN_PER_SQ_KM_WEIGHTED = sum(POPN_PER_SQ_KM_WEIGHTED)) %>%
  ungroup() %>%
  mutate(POPN_PER_SQ_KM_WEIGHTED = POPN_PER_SQ_KM_WEIGHTED / POPN) %>%
  select(-POPN)

list_dataframes <- append(list_dataframes, 
                          c("df_practice_demography", "df_pcn_demography",
                            "df_practice_popn_density", "df_pcn_popn_density"))

# • 2.3. Indices of Multiple Deprivation (IMD) data ----
# ──────────────────────────────────────────────────────

# Practice IMD domains
df_practice_imd_domain <- df_practice_lsoa %>%
  left_join(df_imd_domain, by = "LSOA21CD") %>%  
  mutate(across(.cols = 4:19, .fns = function(x){x*POPN})) %>% 
  group_by(PRACTICE_CODE) %>% 
  summarise(across(.cols = 2:18, .fns = sum)) %>%
  ungroup() %>% 
  mutate(across(.cols = 3:18, .fns = function(x){x/POPN})) %>% 
  select(-POPN)
colnames(df_practice_imd_domain)[2:17] <- paste0(colnames(df_practice_imd_domain)[2:17], "_WEIGHTED")

# Practice IMD indicators
df_practice_imd_indicators <- df_practice_lsoa %>%
  left_join(df_imd_indicators, by = "LSOA21CD") %>% 
  mutate(across(.cols = 4:41, .fns = function(x){x*POPN})) %>% 
  group_by(PRACTICE_CODE) %>% 
  summarise(across(.cols = 2:40, .fns = sum)) %>%
  ungroup() %>% 
  mutate(across(.cols = 3:40, .fns = function(x){x/POPN})) %>% 
  select(-POPN)
colnames(df_practice_imd_indicators)[2:39] <- paste0(colnames(df_practice_imd_indicators)[2:39], "_WEIGHTED")

# PCN IMD domains
df_pcn_imd_domain <- df_pcn_lsoa %>%
  left_join(df_imd_domain, by = "LSOA21CD") %>%  
  mutate(across(.cols = 4:19, .fns = function(x){x*POPN})) %>% 
  group_by(PCN_CODE) %>% 
  summarise(across(.cols = 2:18, .fns = sum)) %>%
  ungroup() %>% 
  mutate(across(.cols = 3:18, .fns = function(x){x/POPN})) %>% 
  select(-POPN)
colnames(df_pcn_imd_domain)[2:17] <- paste0(colnames(df_pcn_imd_domain)[2:17], "_WEIGHTED")

# PCN IMD indicators
df_pcn_imd_indicators <- df_pcn_lsoa %>%
  left_join(df_imd_indicators, by = "LSOA21CD") %>% 
  mutate(across(.cols = 4:41, .fns = function(x){x*POPN})) %>% 
  group_by(PCN_CODE) %>% 
  summarise(across(.cols = 2:40, .fns = sum)) %>%
  ungroup() %>% 
  mutate(across(.cols = 3:40, .fns = function(x){x/POPN})) %>% 
  select(-POPN)
colnames(df_pcn_imd_indicators)[2:39] <- paste0(colnames(df_pcn_imd_indicators)[2:39], "_WEIGHTED")

list_dataframes <- append(list_dataframes, 
                          c("df_practice_imd_domain", "df_practice_imd_indicators",
                            "df_pcn_imd_domain", "df_pcn_imd_indicators"))

# • 2.4. Lookups ----
# ───────────────────

# No action required

# • 2.5. Organisations ----
# ─────────────────────────

# NO LONGER NEEDED AS WE WILL USE GP registration data organisation mapping as the master index
# # Practice
# df_practice <- df_practice %>% 
#   left_join(df_pcode_lu %>% select(PCODE, LAT, LNG), by = c("POSTCODE" = "PCODE"))
# 
# # PCN
# df_pcn <- df_pcn %>% 
#   left_join(df_pcode_lu %>% select(PCODE, LAT, LNG), by = c("POSTCODE" = "PCODE"))
# 
# list_dataframes <- append(list_dataframes, 
#                           c("df_practice", "df_pcn"))

# • 2.6. Payments ----
# ────────────────────

# No action required

list_dataframes <- append(list_dataframes, 
                          c("df_practice_payments", "df_pcn_payments"))

# • 2.7. Quality and Outcomes Framework (QOF) ----
# ────────────────────────────────────────────────

# Practice QOF Prevalence
df_practice_qof_prevalence <- df_qof_prevalence %>% 
  select(PRACTICE_CODE, REGISTER, PREVALENCE) %>%
  pivot_wider(names_from = REGISTER, values_from = PREVALENCE, names_glue = "QOF_PREV_{REGISTER}")

# PCN QOF Prevalence
df_pcn_qof_prevalence <- df_qof_prevalence %>% 
  left_join(df_qof_org_map %>% 
              mutate(PRACTICE_CODE, PCN_CODE = PCN_ODS_CODE, .keep = "none"), 
            by = "PRACTICE_CODE") %>%
  group_by(PCN_CODE, REGISTER) %>%
  summarise(NUMERATOR = sum(NUMERATOR, na.rm = TRUE),
            DENOMINATOR = sum(DENOMINATOR, na.rm = TRUE),
            .groups = "keep") %>%
  ungroup() %>%
  mutate(PREVALENCE = NUMERATOR/DENOMINATOR) %>%
  select(PCN_CODE, REGISTER, PREVALENCE) %>%
  pivot_wider(names_from = REGISTER, values_from = PREVALENCE, names_glue = "QOF_PREV_{REGISTER}")

# Practice QOF Achievement
df_practice_qof_achievement <- df_qof_achievement %>% 
  mutate(ACHIEVEMENT = NUMERATOR / DENOMINATOR) %>%
  select(PRACTICE_CODE, INDICATOR_CODE, ACHIEVEMENT) %>%
  pivot_wider(names_from = INDICATOR_CODE, values_from = ACHIEVEMENT, names_glue = "QOF_ACHV_{INDICATOR_CODE}")

# PCN QOF Achievement
df_pcn_qof_achievement <- df_qof_achievement %>% 
  left_join(df_qof_org_map %>% 
              mutate(PRACTICE_CODE, PCN_CODE = PCN_ODS_CODE, .keep = "none"), 
            by = "PRACTICE_CODE") %>%
  group_by(PCN_CODE, INDICATOR_CODE) %>%
  summarise(NUMERATOR = sum(NUMERATOR, na.rm = TRUE),
            DENOMINATOR = sum(DENOMINATOR, na.rm = TRUE),
            .groups = "keep") %>%
  ungroup() %>%
  mutate(ACHIEVEMENT = NUMERATOR / DENOMINATOR) %>%
  select(PCN_CODE, INDICATOR_CODE, ACHIEVEMENT) %>%
  pivot_wider(names_from = INDICATOR_CODE, values_from = ACHIEVEMENT, names_glue = "QOF_ACHV_{INDICATOR_CODE}")

# Practice QOF PCA Rate
df_practice_qof_pac_rate <- df_qof_achievement %>% 
  mutate(PCA_RATE = PCAS / (DENOMINATOR + PCAS)) %>%
  select(PRACTICE_CODE, INDICATOR_CODE, PCA_RATE) %>%
  pivot_wider(names_from = INDICATOR_CODE, values_from = PCA_RATE, names_glue = "QOF_PCA_{INDICATOR_CODE}")

# PCN QOF PCA Rate
df_pcn_qof_pac_rate <- df_qof_achievement %>% 
  left_join(df_qof_org_map %>% 
              mutate(PRACTICE_CODE, PCN_CODE = PCN_ODS_CODE, .keep = "none"), 
            by = "PRACTICE_CODE") %>%
  group_by(PCN_CODE, INDICATOR_CODE) %>%
  summarise(PCAS = sum(PCAS, na.rm = TRUE),
            DENOMINATOR = sum(DENOMINATOR, na.rm = TRUE),
            .groups = "keep") %>%
  ungroup() %>%
  mutate(PCA_RATE = PCAS / (DENOMINATOR + PCAS)) %>%
  select(PCN_CODE, INDICATOR_CODE, PCA_RATE) %>%
  pivot_wider(names_from = INDICATOR_CODE, values_from = PCA_RATE, names_glue = "QOF_PCA_{INDICATOR_CODE}")

list_dataframes <- append(list_dataframes, 
                          c("df_practice_qof_prevalence", "df_pcn_qof_prevalence", 
                            "df_practice_qof_achievement", "df_pcn_qof_achievement", 
                            "df_practice_qof_pac_rate", "df_pcn_qof_pac_rate"))

# • 2.8. Workforce ----
# ─────────────────────

level_names <- levels(as.factor(df_practice_workforce$STAFF_GROUP))
levels <- c("ADMIN", "DPC", "GP", "NURSE")
names(levels) <- level_names

# Practice Workforce
df_practice_workforce <- df_practice_workforce %>%
  mutate(STAFF_GROUP = unname(levels[STAFF_GROUP])) %>%
  pivot_wider(names_from = STAFF_GROUP, values_from = FTE, names_glue = "PRACTICE_WORKFORCE_{STAFF_GROUP}")

# PCN Practice Workforce
df_pcn_practice_workforce <- df_practice_workforce %>%
  left_join(df_qof_org_map %>% 
              mutate(PRACTICE_CODE, PCN_CODE = PCN_ODS_CODE, .keep = "none"), 
            by = "PRACTICE_CODE") %>%
  group_by(PCN_CODE) %>%
  summarise(across(.cols = all_of(paste0("PRACTICE_WORKFORCE_", unname(levels))), .fns = sum)) %>%
  ungroup()

# PCN Workforce
level_names <- levels(as.factor(df_pcn_workforce$STAFF_GROUP))
levels <- c("DIR", "ADMIN", "DPC", "GP", "NURSE")
names(levels) <- level_names

df_pcn_workforce <- df_pcn_workforce %>%
  mutate(STAFF_GROUP = unname(levels[STAFF_GROUP])) %>%
  pivot_wider(names_from = STAFF_GROUP, values_from = FTE, names_glue = "PCN_WORKFORCE_{STAFF_GROUP}", values_fill = 0)

list_dataframes <- append(list_dataframes, 
                          c("df_practice_workforce",
                          "df_pcn_practice_workforce", "df_pcn_workforce"))

# • 2.9. Geography ----
# ─────────────────────

# No action required

# 3. Combine data ----
# ════════════════════

# • 3.1. Practice ----
# ────────────────────

# • • 3.1.1. Join ----
df_practice_data <- df_practice_master %>%
  left_join(df_practice_demography, by = "PRACTICE_CODE") %>%
  left_join(df_practice_weighted_ethnicity, by = "PRACTICE_CODE") %>%
  left_join(df_practice_popn_density, by = "PRACTICE_CODE") %>% 
  left_join(df_practice_imd_domain, by = "PRACTICE_CODE") %>% 
  left_join(df_practice_imd_indicators, by = "PRACTICE_CODE") %>% 
  left_join(df_practice_qof_prevalence, by = "PRACTICE_CODE") %>% 
  left_join(df_practice_workforce, by = "PRACTICE_CODE") %>%
  left_join(df_practice_payments, by = "PRACTICE_CODE")

# • • 3.1.2. Deal with NAs by replacing with median values for that ICB ----
columns_with_missing_values <- colnames(df_practice_data)[ apply(df_practice_data, 2, anyNA) ]

df_practice_scaled <- df_practice_data %>% 
  left_join(df_practice_data %>% 
              group_by(ICB_CODE) %>%
              summarise(across(all_of(columns_with_missing_values),
                               .fn = \(x) median(x, na.rm = TRUE), .names = "DEFAULT_{.col}")) %>%
              ungroup(), by = "ICB_CODE") %>%
  mutate(across(any_of(columns_with_missing_values),
    .fns = ~ coalesce(.x, get(paste0("DEFAULT_", cur_column())))
  )) %>%
  select(-all_of(starts_with("DEFAULT_")))

# TEST: colnames(df_practice_scaled)[ apply(df_practice_scaled, 2, anyNA) ]

# • • 3.1.3. Scale ----
df_practice_scaled <- scale(df_practice_scaled %>% select(14:112)) %>% as.data.frame()

# Add in variables not used for matching for original dataframe
df_practice_data <- df_practice_data %>%
left_join(df_practice_qof_achievement, by = "PRACTICE_CODE") %>%
  left_join(df_practice_qof_pac_rate, by = "PRACTICE_CODE")
  
# • 3.2. PCN ----
# ────────────────────

# • • 3.2.1. Join ----
df_pcn_data <- df_pcn_master %>% 
  left_join(df_pcn_demography, by = "PCN_CODE") %>%
  left_join(df_pcn_weighted_ethnicity, by = "PCN_CODE") %>%
  left_join(df_pcn_popn_density, by = "PCN_CODE") %>%
  left_join(df_pcn_imd_domain, by = "PCN_CODE") %>%
  left_join(df_pcn_imd_indicators, by = "PCN_CODE") %>%
  left_join(df_pcn_payments, by = "PCN_CODE") %>%
  left_join(df_pcn_qof_prevalence, by = "PCN_CODE") %>%
  left_join(df_pcn_practice_workforce, by = "PCN_CODE") %>%
  left_join(df_pcn_workforce, by = "PCN_CODE")

# • • 3.2.2. Deal with NAs by replacing with median values for that ICB ----
columns_with_missing_values <- colnames(df_pcn_data)[ apply(df_pcn_data, 2, anyNA) ]

df_pcn_scaled <- df_pcn_data %>% 
  left_join(df_pcn_data %>% 
              group_by(ICB_CODE) %>%
              summarise(across(all_of(columns_with_missing_values),
                               .fn = \(x) median(x, na.rm = TRUE), .names = "DEFAULT_{.col}")) %>%
              ungroup(), by = "ICB_CODE") %>%
  mutate(across(any_of(columns_with_missing_values),
                .fns = ~ coalesce(.x, get(paste0("DEFAULT_", cur_column())))
  )) %>%
  select(-all_of(starts_with("DEFAULT_")))

# TEST: colnames(df_pcn_scaled)[ apply(df_pcn_scaled, 2, anyNA) ]

# • • 3.2.3. Scale ----
df_pcn_scaled <- scale(df_pcn_scaled %>% select(14:123)) %>% as.data.frame()

# Add in variables not used for matching
df_pcn_data <- df_pcn_data %>%
  left_join(df_pcn_qof_achievement, by = "PCN_CODE") %>%
  left_join(df_pcn_qof_pac_rate, by = "PCN_CODE")

# 4. Simplify data for processing ----
# ════════════════════════════════════

# • 4.1. Practice ----
# ────────────────────

# Loop through removing one highly correlated variable at a time until none remain
df_correlated_fields_excluded <- data.frame(exc_field = as.character(), corr_field = as.character(), corr_value = as.numeric())
repeat{
  mat_corr <- cor(df_practice_scaled)
  
  df_high_corr <- as.data.frame(mat_corr) %>% 
    mutate(x = row.names(.), .before = 1) %>%
    remove_rownames() %>% 
    pivot_longer(cols = 2:NCOL(.), names_to = 'y', values_to = 'corr') %>%
    dplyr::filter(x != y & abs(corr)>=0.975) %>% 
    arrange(desc(abs(corr))) %>%
    data.frame()
  
  if(NROW(df_high_corr)==0)
    break
  
  var <- df_high_corr$y[1]
  df_correlated_fields_excluded <- df_correlated_fields_excluded %>% 
    bind_rows(
      data.frame(exc_field = df_high_corr$y[1], 
                 corr_field = df_high_corr$x[1], 
                 corr_value = df_high_corr$corr[1])
    )
  
  df_practice_scaled <- df_practice_scaled %>% select(-all_of(var))
  mat_corr <- cor(df_practice_scaled)
}
df_practice_fields_excluded <- df_correlated_fields_excluded

# • 4.2. PCN ----
# ───────────────

# Loop through removing one highly correlated variable at a time until none remain
df_correlated_fields_excluded <- data.frame(exc_field = as.character(), corr_field = as.character(), corr_value = as.numeric())
repeat{
  mat_corr <- cor(df_pcn_scaled)
  
  df_high_corr <- as.data.frame(mat_corr) %>% 
    mutate(x = row.names(.), .before = 1) %>%
    remove_rownames() %>% 
    pivot_longer(cols = 2:NCOL(.), names_to = 'y', values_to = 'corr') %>%
    dplyr::filter(x != y & abs(corr)>=0.975) %>% 
    arrange(desc(abs(corr))) %>%
    data.frame()
  
  if(NROW(df_high_corr)==0)
    break
  
  var <- df_high_corr$y[1]
  df_correlated_fields_excluded <- df_correlated_fields_excluded %>% 
    bind_rows(
      data.frame(exc_field = df_high_corr$y[1], 
                 corr_field = df_high_corr$x[1], 
                 corr_value = df_high_corr$corr[1])
    )
  
  df_pcn_scaled <- df_pcn_scaled %>% select(-all_of(var))
  mat_corr <- cor(df_pcn_scaled)
}
df_pcn_fields_excluded <- df_correlated_fields_excluded

# 5. Calculate distances ----
# ═══════════════════════════

# • 5.1. Practice ----
# ────────────────────

dist_practice <- dist(df_practice_scaled)

df_practice_distances <- dist2list(dist_practice) %>% 
  filter(col!=row) %>%
  transmute(
    orig = df_practice_data$PRACTICE_CODE[row],
    dest = df_practice_data$PRACTICE_CODE[col],
    distance = value
  )

# • 5.2. PCN ----
# ───────────────

dist_pcn <- dist(df_pcn_scaled)

df_pcn_distances <- dist2list(dist_pcn) %>% 
  filter(col!=row) %>%
  transmute(
    orig = df_pcn_data$PCN_CODE[row],
    dest = df_pcn_data$PCN_CODE[col],
    distance = value
  )

# 6. Save data ----
# ═════════════════

save(file = "data.RObj", list = c("df_practice_data", "df_pcn_data"))
save(file = "distances.RObj", list = c("df_practice_distances", "df_pcn_distances"))

# rm(list=ls())

load("data.RObj")
load("distances.RObj")

df_top10_practices <- df_practice_distances %>% 
  mutate(ORIG = orig, DEST = dest, DISTANCE = distance, .keep = "none") %>%
  left_join(df_practice_data %>% 
              mutate(PRACTICE_CODE, ORIG_ICB_CODE = ICB_CODE, ORIG_NHSER_CODE = NHSER_CODE, .keep = "none"), 
            by = c("ORIG" = "PRACTICE_CODE")) %>%
  left_join(df_practice_data %>% 
              mutate(PRACTICE_CODE, DEST_ICB_CODE = ICB_CODE, DEST_NHSER_CODE = NHSER_CODE, .keep = "none"), 
            by = c("DEST" = "PRACTICE_CODE"))

df_top10_practices <- df_top10_practices %>% 
  arrange(ORIG, DISTANCE) %>%
  group_by(ORIG) %>%
  slice_head(n = 10) %>%
  ungroup() %>%
  mutate(TYPE = "ALL") %>%
  select(ORIG, DEST, DISTANCE, TYPE) %>%
  bind_rows(
    df_top10_practices %>% 
      arrange(ORIG, DISTANCE) %>%
      dplyr::filter(ORIG_NHSER_CODE == DEST_NHSER_CODE) %>%
      group_by(ORIG) %>%
      slice_head(n = 10) %>%
      ungroup() %>%
      mutate(TYPE = "REGION") %>%
      select(ORIG, DEST, DISTANCE, TYPE)
  ) %>%
  bind_rows(
    df_top10_practices %>% 
      arrange(ORIG, DISTANCE) %>%
      dplyr::filter(ORIG_ICB_CODE == DEST_ICB_CODE) %>%
      group_by(ORIG) %>%
      slice_head(n = 10) %>%
      ungroup() %>%
      mutate(TYPE = "ICB") %>%
      select(ORIG, DEST, DISTANCE, TYPE)
  )

df_top10_pcn <- df_pcn_distances %>% 
  mutate(ORIG = orig, DEST = dest, DISTANCE = distance, .keep = "none") %>%
  left_join(df_pcn_data %>% 
              mutate(PCN_CODE, ORIG_ICB_CODE = ICB_CODE, ORIG_NHSER_CODE = NHSER_CODE, .keep = "none"), 
            by = c("ORIG" = "PCN_CODE")) %>%
  left_join(df_pcn_data %>% 
              mutate(PCN_CODE, DEST_ICB_CODE = ICB_CODE, DEST_NHSER_CODE = NHSER_CODE, .keep = "none"), 
            by = c("DEST" = "PCN_CODE"))

df_top10_pcn <- df_top10_pcn %>% 
  arrange(ORIG, DISTANCE) %>%
  group_by(ORIG) %>%
  slice_head(n = 10) %>%
  ungroup() %>%
  mutate(TYPE = "ALL") %>%
  select(ORIG, DEST, DISTANCE, TYPE) %>%
  bind_rows(
    df_top10_pcn %>% 
      arrange(ORIG, DISTANCE) %>%
      dplyr::filter(ORIG_NHSER_CODE == DEST_NHSER_CODE) %>%
      group_by(ORIG) %>%
      slice_head(n = 10) %>%
      ungroup() %>%
      mutate(TYPE = "REGION") %>%
      select(ORIG, DEST, DISTANCE, TYPE)
  ) %>%
  bind_rows(
    df_top10_pcn %>% 
      arrange(ORIG, DISTANCE) %>%
      dplyr::filter(ORIG_ICB_CODE == DEST_ICB_CODE) %>%
      group_by(ORIG) %>%
      slice_head(n = 10) %>%
      ungroup() %>%
      mutate(TYPE = "ICB") %>%
      select(ORIG, DEST, DISTANCE, TYPE)
  )

df_practice_data %>% slice_sample(n = 100) %>% write.csv("df_practice_data_SAMPLE.csv", row.names = FALSE)
df_pcn_data %>% slice_sample(n = 100) %>% write.csv("df_pcn_data_SAMPLE.csv", row.names = FALSE)
df_top10_practices %>% group_by(TYPE) %>% slice_sample(n = 25) %>% write.csv("df_top10_practices_SAMPLE.csv", row.names = FALSE)
df_top10_pcn %>% group_by(TYPE) %>% slice_sample(n = 25) %>% write.csv("df_top10_pcn_SAMPLE.csv", row.names = FALSE)

df_practice_data %>% write.csv("df_practice_data.csv", row.names = FALSE)
df_pcn_data %>% write.csv("df_pcn_data.csv", row.names = FALSE)
df_top10_practices %>% write.csv("df_top10_practices.csv", row.names = FALSE)
df_top10_pcn %>% write.csv("df_top10_pcn.csv", row.names = FALSE)

# df_practice_data %>% names() %>% write.csv("practice_data_fields.csv")
# df_pcn_data %>% names() %>% write.csv("pcn_data_fields.csv")

