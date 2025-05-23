# ---- Load Data ----
#data <- read_csv("data/data.csv")
#View(data)
# data_cases <- read.csv("https://raw.githubusercontent.com/european-modelling-hubs/covid19-forecast-hub-europe/main/data-truth/ECDC/truncated_ECDC-Incident%20Cases.csv")
# data_deaths <- read.csv("https://raw.githubusercontent.com/european-modelling-hubs/covid19-forecast-hub-europe/main/data-truth/ECDC/truncated_ECDC-Incident%20Deaths.csv")
# data_hosps <- read.csv("https://raw.githubusercontent.com/european-modelling-hubs/RespiCast-Covid19/refs/heads/main/target-data/ERVISS/latest-hospital_admissions.csv")

# data <- read.csv("https://raw.githubusercontent.com/EU-ECDC/Respiratory_viruses_weekly_data/refs/heads/main/data/nonSentinelSeverity.csv") %>%
#   filter(age == "total") %>%
#   select(-age, -survtype, -pathogentype)

data_cases <- read.csv("https://raw.githubusercontent.com/european-modelling-hubs/covid19-forecast-hub-europe/main/data-truth/ECDC/truncated_ECDC-Incident%20Cases.csv")
data_deaths <- read.csv("https://raw.githubusercontent.com/european-modelling-hubs/covid19-forecast-hub-europe/main/data-truth/ECDC/truncated_ECDC-Incident%20Deaths.csv")
data_hosps <- read.csv("https://raw.githubusercontent.com/european-modelling-hubs/RespiCast-Covid19/refs/heads/main/target-data/latest-hospital_admissions.csv")
  

options(scipen=99)

