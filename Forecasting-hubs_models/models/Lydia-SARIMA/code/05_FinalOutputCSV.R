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
  
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ### Plot results and save the figure ########
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # Dataframe with results [format like the upload to GitHub]
  for (target0 in c("case","hosp","death")){
    x = Lydia_ARI2MA %>% filter(grepl(target0,target))

    # Make sure 'value' is double
    x$value = as.double(x$value)
    
    # Prepare the dataframe to be used in the 'plot_step_ahead_model_output' function below
    plot_mod_log = x %>% 
      mutate(model_id="log",
             output_type_id = as.numeric(output_type_id)) %>% 
      rename(target_date=target_end_date) %>% 
      filter(output_type != "median")
    
    # Plot the figure
    fig = plot_step_ahead_model_output(plot_mod_log, # Forecasts
                                       df_train %>% mutate(time_idx=date) %>% filter(date>ymd("2024-01-01")), # Reported data
                                       facet=c("location"), facet_scales = "free",
                                       #intervals = c(0.95),
                                       interactive=F)
    
    print(fig)
    # Save the figure
    filename = file.path(here(), paste0("figures/", current_date ,"-LydiaSARIMA_",target0,".jpg"))
    ggsave(filename, width = 40, height = 20, units = "cm")
  }
  
}