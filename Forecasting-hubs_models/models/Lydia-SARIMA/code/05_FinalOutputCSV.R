final_output <- function(monday_date,run_COVID_cases,run_COVID_deaths, run_COVID_hosps) {
  
  if (weekdays(monday_date) != "Monday") {
    print("Warning: Ensure that the date aligns with the Monday corresponding to the week in which the submission window ends.")
  }
  
  
  source("Forecasting-hubs_models/models/Lydia-SARIMA/code/04_OutputCSV.R")
  Lydia_SARIMA <- data.frame()
  if (run_COVID_cases){
    Lydia_SARIMA <- rbind(Lydia_SARIMA, create_output(cases, monday_date))
  }
  
  if (run_COVID_deaths){
    Lydia_SARIMA <- rbind(Lydia_SARIMA, create_output(deaths, monday_date))
  }
  
  if (run_COVID_hosps){
    Lydia_SARIMA <- rbind(Lydia_SARIMA, create_output(hosps, monday_date))
  }

  write.csv(Lydia_SARIMA, paste0("Forecasting-hubs_models/model_output/COVID/", monday_date,"-Lydia-SARIMA.csv"), row.names=FALSE)
}