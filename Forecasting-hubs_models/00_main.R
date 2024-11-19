# Function to (i) load the libraries and other required functions, and (ii) runs the model + saves the outputs

# useful stuff

# print like this
if (F) {pr=paste("Warning: Check day diffs for:",country_i,"\n"); cat(red(pr))}


# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
### Libraries and aux functions ########
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Install missing libraries
required_libraries = c("arrow", "bayesplot", "caTools", "crayon", "dagitty", "data.table", 
                       "DBI", "devtools", "dplyr", "dtplyr", "EcdcColors", "EnvStats", 
                       "fitdistrplus", "forcats", "forecast", "fst", "gamlss", "gamlss.data", 
                       "gamlss.dist", "ggplot2", "ggpubr", "ggrepel", "glmc", "here", 
                       "Hmisc", "hubVis", "ISOweek", "KeyboardSimulator", "limSolve", 
                       "lubridate", "magrittr", "MASS", "mgcv", "nlme", "odbc", "pacman", 
                       "patchwork", "pracma", "purrr", "readr", "readxl", "scales", 
                       "scoringutils", "sparsevar", "stringr", "summarytools", "survival", 
                       "tibble", "tictoc", "tidybayes", "tidyr", "tidyverse", "usethis", 
                       "viridis", "viridisLite", "wrapr", "zoo")
installed_packages = rownames(installed.packages())
missing_packages = setdiff(required_libraries, installed_packages)

if (length(missing_packages)>0){
  install.packages(missing_packages, dependencies = TRUE)
}


library(devtools)
source("Forecasting-hubs_models/setup.R")
# load additional libraries beyond core ones from setup
library(fitdistrplus)
#source("../../../modelling_setup/setup.R")
library(scoringutils)
library(hubVis)
library(data.table)
library(lubridate)
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
### Settings  ########
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# set the date as the previous Monday to today (if today is Monday, use today)
today <- Sys.Date()
# Find the previous Monday
previous_monday <- today - lubridate::wday(today, week_start = 1) + 1 
current_date = previous_monday


# indicators to run
run_ILI = T
run_ARI = T
run_COVID_cases = F #cases not part of RespiCast
run_COVID_hosps = T
run_COVID_deaths = F #deaths not part of RespiCast

# Define if you want to plot and save results (forecasts) - used for 'eye checking' of the output
plot_results = F


# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
### Source & run the models  ########
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ARIMA models
source("Forecasting-hubs_models/models/ARIMA/run_ARIMA_models.R")
run_ARIMA_models(current_date, 
                        current_date, 
                        run_ILI = run_ILI,
                        run_ARI = run_ARI,
                        run_COVID_cases = run_COVID_cases,
                        run_COVID_hosps = run_COVID_hosps,
                        run_COVID_deaths = run_COVID_deaths,
                        plot_results = plot_results)

## SOCA Simplex
source("Forecasting-hubs_models/models/SOCA_Simplex/function_run_soca_simplex_model.R")
run_soca_simplex_model(current_date, 
                       run_ILI = run_ILI,
                       run_ARI = run_ARI,
                       run_COVID_cases = run_COVID_cases,
                       run_COVID_hosps = run_COVID_hosps,
                       run_COVID_deaths = run_COVID_deaths,
                       plot_results = plot_results)


#norrsken models
#source("function_run_norrsken_blue_model.R")
# run_norrsken_blue_model(current_date, 
#                  run_ILI = run_ILI,
#                  run_ARI = run_ARI,
#                  run_COVID_cases = run_COVID_cases,
#                  run_COVID_hosps = run_COVID_hosps,
#                  run_COVID_deaths = run_COVID_deaths)
# source("function_run_norrsken_green_model.R")
# run_norrsken_green_model(current_date, 
#                  run_ILI = run_ILI,
#                  run_ARI = run_ARI,
#                  run_COVID_cases = run_COVID_cases,
#                  run_COVID_hosps = run_COVID_hosps,
#                  run_COVID_deaths = run_COVID_deaths)




