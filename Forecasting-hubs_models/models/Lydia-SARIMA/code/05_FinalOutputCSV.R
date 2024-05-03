final_output <- function(monday_date) {
  
  if (weekdays(monday_date) != "Monday") {
    print("Warning: Ensure that the date aligns with the Monday corresponding to the week in which the submission window ends.")
  }
  
  
  source("code/04_OutputCSV.R")
  
  Lydia_SARIMA_cases <- create_output(cases, monday_date)
  Lydia_SARIMA_deaths <- create_output(deaths, monday_date)
  Lydia_SARIMA_hosps <- create_output(hosps, monday_date)
  
  Lydia_SARIMA <- rbind(Lydia_SARIMA_cases, Lydia_SARIMA_deaths, Lydia_SARIMA_hosps) 
  write.csv(Lydia_SARIMA, paste0("./data-processed/", monday_date,"-Lydia-SARIMA.csv"), row.names=FALSE)
}