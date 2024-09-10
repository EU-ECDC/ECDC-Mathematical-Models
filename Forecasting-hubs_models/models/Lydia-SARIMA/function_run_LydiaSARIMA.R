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
                                   run_COVID_deaths = T
){
 
  # check: current_date = Monday of the submission week
  if ( weekdays(current_date) != "Monday"){
    stop("The input date is NOT a Monday. Please provide Monday of the submission week.")
  }
  
  if (run_COVID_cases | run_COVID_deaths | run_COVID_hosps ){ 
    message("Running LydiaSARIMA")
    # ---- 1. set up ----
    message('loading data')
    source("Forecasting-hubs_models/models/Lydia-SARIMA/code/01_SetUp.R")
    source("Forecasting-hubs_models/models/Lydia-SARIMA/code/02_DataPreparation.R")
    
    # ---- 2. models ----
    if (run_COVID_cases) {
      message("running for cases")
      source("Forecasting-hubs_models/models/Lydia-SARIMA/code/03a_SARIMAcases.R")
    } else {
      message("skipping cases")
    }
    if (run_COVID_deaths) {
      message("running for deaths")
      source("Forecasting-hubs_models/models/Lydia-SARIMA/code/03b_SARIMAdeaths.R")
    } else {
      message("skipping deaths")
    }
    if (run_COVID_hosps) {
      message("running for hosp")
      source("Forecasting-hubs_models/models/Lydia-SARIMA/code/03c_SARIMAhosps.R")
    } else {
      message("skipping hosp")
    }
    
    # ---- 3. output ----
    source("Forecasting-hubs_models/models/Lydia-SARIMA/code/05_FinalOutputCSV.R")
    final_output(current_date,run_COVID_cases,run_COVID_deaths, run_COVID_hosps)
    message("completed, output stored")
  } else {
    message("not running LydiaSARIMA - no COVID targets requested")
  }
  
  return(0)
}