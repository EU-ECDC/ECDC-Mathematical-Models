final_output <- function(monday_date,run_COVID_cases,run_COVID_deaths, run_COVID_hosps, plot_results) {
  
  if (weekdays(monday_date) != "Monday") {
    print("Warning: Ensure that the date aligns with the Monday corresponding to the week in which the submission window ends.")
  }
  
  
  source("Forecasting-hubs_models/models/ARIMA/Lydia-SARIMA/code/04_OutputCSV.R")
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
  
  #update dataframe for new submission format (RespiCast Covid-19 hub)
  Lydia_SARIMA <- Lydia_SARIMA %>%
    separate(target, into='horizon',extra='drop') %>% #extract horizon from old target string
    mutate(origin_date = forecast_date + 2, #monday -> wednesday
           target = 'hospital admissions',
           target_end_date = target_end_date + 1, #Saturday -> Sunday',
           output_type = ifelse(type == 'point','median','quantile'),
           output_type_id = ifelse(is.na(quantile),'', quantile),
           horizon = as.numeric(horizon) + 1
    ) %>%
    select(origin_date, target,target_end_date,horizon,location,output_type,output_type_id,value)
  
  
  write.csv(Lydia_SARIMA, paste0("Forecasting-hubs_models/model_output/COVID/", monday_date+2,"-ECDC-SARIMA.csv"), row.names=FALSE)
  
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ### Plot results and save the figure ########
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  if (plot_results == TRUE){
    # Dataframe with results [format like the upload to GitHub]
    for (target0 in c("case","hosp","death")){
      x = Lydia_SARIMA %>% filter(grepl(target0,target))
      
      if (nrow(x) > 0){
        # Make sure 'value' is double
        x$value = as.double(x$value)
        
        # Prepare the dataframe to be used in the 'plot_step_ahead_model_output' function below
        plot_mod_log = x %>% 
          mutate(model_id="log",
                 target_date=target_end_date)
        
        # Reported data - prepare for plotting
        if (target0 == "case"){
          df_data = data_cases
        } else if (target0 == "hosp") {
          df_data = data_hosps
        } else if (target0 == "death") {
          df_data = data_deaths
        } else {
          message("Plotting function: Wrong target name")
        }
        # Plot the figure
        fig = plot_step_ahead_model_output( as_tibble(plot_mod_log), # Forecasts
                                            df_data %>% mutate(time_idx=truth_date ) %>% filter(time_idx > ymd("2024-01-01")), # Reported data
                                            facet=c("location"), facet_scales = "free",
                                            #intervals = c(0.95),
                                            interactive=F)
        
        print(fig)
        # Save the figure
        filename = file.path(here(), paste0("Forecasting-hubs_models/model_output/figures/", current_date+2 ,"-LydiaSARIMA_",target0,".jpg"))
        ggsave(filename, width = 40, height = 20, units = "cm")
      }
    }
  }
  
}