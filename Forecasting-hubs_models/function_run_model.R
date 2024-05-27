# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
### [name] model for ILI/ARI/covid indicators ########
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Skeleton code for a wrapper function to use in 00_main.R. 
# replace this section with a short summary/extra info
# make sure to replace every [name] with the actual name of the model
# required: function run_[name]_model (matching function call in 00_main.R), 
#           taking the parameters listed below. This function should store model 
#           output in the right format (see hub specifications) in the folder 
#           "Forecasting-hubs_models/model_output/[target]/"
# optional, but suggested: progress messages, preview figures of the forecasts 
#                         (store in model_output/figures), a readme with an 
#                         explanation of how the model works (theory & code)
# 
# 
# Date, Author: 


run_[name]_model = function(current_date, 
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
  
  message("running [name]") 
  ###################################
  ## loading data
  ###################################
  # insert code to load & format data
  
  
  ###################################
  ## run the model
  ###################################
  if (run_ILI){
    message("running for ILI")
    #insert code to run for ILI
  } else {
    message("skipping ILI")
  }
  
  if (run_ARI){
    message("running for ARI")
    #insert code to run for ARI
  } else {
    message("skipping ARI")
  }
  
  if (run_COVID_cases){
    message("running for COVID_cases")
    #insert code to run COVID_cases
  } else {
    message("skipping COVID_cases")
  }
  
  if (run_COVID_hosps){
    message("running for COVID_hosp")
    #insert code to run COVID_hosp
  } else {
    message("skipping COVID_hosp")
  }
  
  if (run_COVID_deaths){
    message("running for COVID_deaths")
    #insert code to run COVID_deaths
  } else {
    message("skipping COVID_deaths")
  }
  
  ###################################
  ## store output
  ###################################
  # insert code to store output in correct folder with correct file name
  message("completed, output stored")
  return(0)
}