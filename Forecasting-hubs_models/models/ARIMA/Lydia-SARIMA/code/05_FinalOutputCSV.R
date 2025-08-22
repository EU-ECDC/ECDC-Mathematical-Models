final_output <- function(monday_date,run_COVID_cases,run_COVID_deaths, run_COVID_hosps, plot_results) {
  
  if (weekdays(monday_date) != "Monday") {
    print("Warning: Ensure that the date aligns with the Monday corresponding to the week in which the submission window ends.")
  }
  
  
  source("Forecasting-hubs_models/models/ARIMA/Lydia-SARIMA/code/04_OutputCSV.R")
  Lydia_SARIMA <- data.frame()
  if (run_COVID_cases){
    Lydia_SARIMA <- rbind(Lydia_SARIMA, create_output(cases, monday_date, 'case'))
  }
  
  if (run_COVID_deaths){
    Lydia_SARIMA <- rbind(Lydia_SARIMA, create_output(deaths, monday_date, 'death'))
    
    
  }
  
  if (run_COVID_hosps){
    Lydia_SARIMA <- rbind(Lydia_SARIMA, create_output(hosps, monday_date, 'hosp'))
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
  
  
  write.csv(Lydia_SARIMA, paste0("Forecasting-hubs_models/model_output/COVID/", monday_date+2,"-ECDC-SARIMA2.csv"), row.names=FALSE)
  
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
        
        # Prepare for plot
        forecast = x %>%
          rename(target_date = target_end_date,
                 quantiles = output_type_id) %>%
          mutate(target_date = ymd(target_date),
                 quantiles = as.double(quantiles)) %>%
          select(location, target_date, quantiles, value)
        data = df_data %>%
          mutate(date=ymd(truth_date)) %>%
          select(location, date, value)
        
        # Plot the figure
        fig = plot_data_with_quantiles(data, forecast)
        
        print(fig)
        # Save the figure
        filename = file.path(here(), paste0("Forecasting-hubs_models/model_output/figures/", current_date+2 ,"-LydiaSARIMA_",target0,".jpg"))
        ggsave(filename, width = 40, height = 20, units = "cm")
      }
    }
  }
  
}