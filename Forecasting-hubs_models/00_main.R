# Function to (i) load the libraries and other required functions, and (ii) runs the model + saves the outputs
# --warning-- Currently, this script does not yet work for ILI/ARI (paths need to be updated)

# useful stuff

# print like this
if (F) {pr=paste("Warning: Check day diffs for:",country_i,"\n"); cat(red(pr))}


# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
### Libraries and aux functions ########
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

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



# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
### Source & run the models  ########
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ARIMA models
source("Forecasting-hubs_models/models/ARI2MA/function_run_ARI2MA_model.R")
run_ARI2MA_model(current_date,
                 run_ILI = run_ILI,
                 run_ARI = run_ARI,
                 run_COVID_cases = run_COVID_cases,
                 run_COVID_hosps = run_COVID_hosps,
                 run_COVID_deaths = run_COVID_deaths)

source("Forecasting-hubs_models/models/FluForARIMA/function_run_FluForARIMA_model.R")
run_FluForARIMA_model(current_date,
                      run_ILI = run_ILI,
                      run_ARI = run_ARI,
                      run_COVID_cases = run_COVID_cases,
                      run_COVID_hosps = run_COVID_hosps,
                      run_COVID_deaths = run_COVID_deaths)

source("Forecasting-hubs_models/models/Lydia-SARIMA/function_run_LydiaSARIMA.R")
run_LydiaSARIMA_model(current_date, 
                      run_ILI = run_ILI,
                      run_ARI = run_ARI,
                      run_COVID_cases = run_COVID_cases,
                      run_COVID_hosps = run_COVID_hosps,
                      run_COVID_deaths = run_COVID_deaths)

### TEMPORARY SOLUTION
# merge ILI and ARI forecasts for new respicast hub
ILI <- paste0('Forecasting-hubs_models/model_output/ILI/' , current_date+2 ,'-ECDC-FluForARIMA.csv')
ARI <- paste0('Forecasting-hubs_models/model_output/ARI/' , current_date+2 ,'-ECDC-ARI2MA.csv')

syndromic_indicators <- bind_rows(read_csv(ILI), read_csv(ARI)) 
syndromic_indicators %<>%
  mutate(output_type_id = ifelse(is.na(output_type_id), '', as.character(output_type_id)))
write_csv(syndromic_indicators,paste0('Forecasting-hubs_models/model_output/Syndromic_indicators/', current_date+2,'-ECDC-SARIMA.csv'))

## SOCA Simplex
source("Forecasting-hubs_models/models/SOCA_Simplex/function_run_soca_simplex_model.R")
run_soca_simplex_model(current_date, 
                       run_ILI = run_ILI,
                       run_ARI = run_ARI,
                       run_COVID_cases = run_COVID_cases,
                       run_COVID_hosps = run_COVID_hosps,
                       run_COVID_deaths = run_COVID_deaths)

### TEMPORARY SOLUTION
# merge ILI and ARI forecasts for new respicast hub
ILI <- paste0('Forecasting-hubs_models/model_output/ILI/' , current_date+2 ,'-ECDC-soca_simplex.csv')
ARI <- paste0('Forecasting-hubs_models/model_output/ARI/' , current_date+2 ,'-ECDC-soca_simplex.csv')

syndromic_indicators <- bind_rows(read_csv(ILI), read_csv(ARI)) 
syndromic_indicators %<>%
  mutate(output_type_id = ifelse(is.na(output_type_id), '', as.character(output_type_id)))
write_csv(syndromic_indicators,paste0('Forecasting-hubs_models/model_output/Syndromic_indicators/', current_date+2,'-ECDC-soca_simplex.csv'))

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




