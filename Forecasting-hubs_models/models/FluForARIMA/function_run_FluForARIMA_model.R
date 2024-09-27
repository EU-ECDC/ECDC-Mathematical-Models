# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
### ARIMA model for ILI indicators ########
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Sept 2024, Author: Eva&Rok (wrapper) & Lydia (model)

run_FluForARIMA_model = function(current_date, 
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
  
  if (run_ARI){ 
    message("Running FluForARIMA")
    # ---- 1. set up ----
    message('loading data')
    source("Forecasting-hubs_models/models/FluForARIMA/code/01_SetUp.R")
    source("Forecasting-hubs_models/models/FluForARIMA/code/02_DataPreparation.R")
    
    # ---- 2. models ----
    message("running for ILI")
    source("Forecasting-hubs_models/models/FluForARIMA/code/03_Lydia_FluForARIMA.R")
    
    # ---- 3. output ----
    source("Forecasting-hubs_models/models/FluForARIMA/code/04_OutputCSV.R")
    create_output(cases, current_date)
    message("completed, output stored")
  } else {
    message("not running FluForARIMA - no ILI requested")
  }
  
  return(0)
}