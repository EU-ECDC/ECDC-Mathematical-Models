# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
### norrsken_blue model for ILI/ARI/covid indicators ########
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# November 2023, Author: Rene

run_norrsken_blue_model = function(current_date, 
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
  
  
  # Load data
  
  
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ### ILIs & ARIs: Define parameters and perform simplex forecast ########
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  
  return(0)
}