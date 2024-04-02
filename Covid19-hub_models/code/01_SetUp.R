# ---- Load libraries ----
library(readr)
library(dplyr)
library(tidyverse)
library(forecast)
library(countrycode)
library(zoo) # to handle missing values

# ---- Load Data ----
#data <- read_csv("data/data.csv")
#View(data)
data_cases <- read.csv("https://raw.githubusercontent.com/european-modelling-hubs/covid19-forecast-hub-europe/main/data-truth/ECDC/truncated_ECDC-Incident%20Cases.csv")
data_deaths <- read.csv("https://raw.githubusercontent.com/european-modelling-hubs/covid19-forecast-hub-europe/main/data-truth/ECDC/truncated_ECDC-Incident%20Deaths.csv")
data_hosps <- read.csv("https://raw.githubusercontent.com/european-modelling-hubs/covid19-forecast-hub-europe/main/data-truth/OWID/truncated_OWID-Incident%20Hospitalizations.csv")

options(scipen=99)

