# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
### ARIMA model for covid indicators ########
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# May 2024, Author: Eva (wrapper) & Lydia (model)

run_LydiaSARIMA_model = function(current_date, 
                                 save_files = T, 
                                 run_ILI = T,
                                 run_ARI = T,
                                 run_COVID_cases = T,
                                 run_COVID_hosps = T,
                                 run_COVID_deaths = T,
                                 plot_results = T
){
  
  # check: current_date = Monday of the submission week
  if ( weekdays(current_date) != "Monday"){
    stop("The input date is NOT a Monday. Please provide Monday of the submission week.")
  }
  
  if (run_COVID_cases | run_COVID_deaths | run_COVID_hosps ){ 
    message("#### Running LydiaSARIMA for covid indicators ####")
    # ---- 1. set up ----
    message('Loading data')
    source("Forecasting-hubs_models/models/ARIMA/Lydia-SARIMA/code/01_SetUp.R")
    source("Forecasting-hubs_models/models/ARIMA/Lydia-SARIMA/code/02_DataPreparation.R")
    
    # ---- 2. models ----
    if (run_COVID_cases) {
      message("---Running for cases")
      source("Forecasting-hubs_models/models/ARIMA/Lydia-SARIMA/code/03a_SARIMAcases.R")
    } else {
      message("---Skipping cases")
    }
    if (run_COVID_deaths) {
      message("---Running for deaths")
      source("Forecasting-hubs_models/models/ARIMA/Lydia-SARIMA/code/03b_SARIMAdeaths.R")
    } else {
      message("---Skipping deaths")
    }
    if (run_COVID_hosps) {
      message("---Running for hosp")
      source("Forecasting-hubs_models/models/ARIMA/Lydia-SARIMA/code/03c_SARIMAhosps.R")
    } else {
      message("---Skipping hosp")
    }
    
    # ---- 3. output ----
    source("Forecasting-hubs_models/models/ARIMA/Lydia-SARIMA/code/05_FinalOutputCSV.R")
    final_output(current_date,run_COVID_cases,run_COVID_deaths, run_COVID_hosps, plot_results)
    message("completed, output stored")
  } else {
    message("not running LydiaSARIMA - no COVID targets requested")
  }
  
  return(0)
}