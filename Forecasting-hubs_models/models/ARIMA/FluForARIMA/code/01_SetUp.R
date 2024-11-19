# ---- Load Data ----
data_cases <- read.csv("https://raw.githubusercontent.com/european-modelling-hubs/RespiCast-SyndromicIndicators/refs/heads/main/target-data/latest-ILI_incidence.csv")

data_cases <- data_cases[order(data_cases$location, data_cases$truth_date),]


options(scipen=99)

unique(data_cases$location)
