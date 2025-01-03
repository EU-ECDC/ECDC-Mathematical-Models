create_output <- function(indicator, monday_date, plot_results){
  
  whichday <- weekdays(monday_date)
  
  if(whichday != "Monday") {
    print("Warning: the date should be the Monday of the week that the submission window ends.")
  }
  
  n <- length(indicator)
  Lydia_FluForARIMA <- data.frame(origin_date = date(n),
                                  target = character(n),
                                  target_end_date = date(n),
                                  horizon = character(n),
                                  location = character(n),
                                  output_type = character(n),
                                  output_type_id = numeric(n),
                                  value = numeric(n))
  
  Lydia_FluForARIMA$origin_date <- rep(monday_date+2, N_rows_per_country*N_countries)
  Lydia_FluForARIMA$origin_date <- as.Date(Lydia_FluForARIMA$origin_date)
  
  Lydia_FluForARIMA$target <- "ILI incidence"
  
  Lydia_FluForARIMA$horizon <- rep(rep(c(1, 2, 3, 4),
                                       each = N_quantiles), N_countries)
  
  for (i in 1:n){
    Lydia_FluForARIMA$target_end_date[i] <- ifelse(Lydia_FluForARIMA$horizon[i] == 1, Lydia_FluForARIMA$origin_date[i] - days(3),
                                                   ifelse(Lydia_FluForARIMA$horizon[i] == 2, Lydia_FluForARIMA$origin_date[i] +  - days(3) + days(7),
                                                          ifelse(Lydia_FluForARIMA$horizon[i] == 3, Lydia_FluForARIMA$origin_date[i]  - days(3) + days(14),
                                                                 ifelse(Lydia_FluForARIMA$horizon[i] == 4, Lydia_FluForARIMA$origin_date[i]  - days(3) + days(21)))))
  }
  
  Lydia_FluForARIMA$location <- rep(unique(data_cases$location), each = N_rows_per_country)
  
  Lydia_FluForARIMA$output_type <- rep(c("median", rep("quantile", 23)), N_weeks_ahead*N_indicators*N_countries)
  Lydia_FluForARIMA$output_type <- as.character(Lydia_FluForARIMA$output_type)
  
  
  Lydia_FluForARIMA$output_type_id <- rep(c("", 0.01, 0.025, seq(0.05, 0.95, by = 0.05), 0.975, 0.99), 
                                          N_weeks_ahead*N_indicators*N_countries)
  
  Lydia_FluForARIMA$output_type_id <- as.character(Lydia_FluForARIMA$output_type_id)
  
  
  Lydia_FluForARIMA$value <- ifelse(indicator < 0, 0, indicator)
  
  write.csv(Lydia_FluForARIMA, paste0("Forecasting-hubs_models/model_output/Syndromic_indicators/ILI/", monday_date+2,"-ECDC-FluForARIMA.csv"), 
            row.names=FALSE)
  
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ### Plot results and save the figure ########
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  if (plot_results == TRUE){
    # Dataframe with results [format like the upload to GitHub]
    
    x = Lydia_FluForARIMA
    
    # Make sure 'value' is double
    x$value = as.double(x$value)
    
    # Prepare for plot
    forecast = x %>%
      rename(target_date = target_end_date,
             quantiles = output_type_id) %>%
      mutate(target_date = ymd(target_date),
             quantiles = as.double(quantiles)) %>%
      select(location, target_date, quantiles, value)
    data = data_cases %>%
      mutate(date=ymd(truth_date)) %>%
      select(location, date, value)
    
    
    # Plot the figure
    fig = plot_data_with_quantiles(data, forecast)
    
    print(fig)
    # Save the figure
    filename = file.path(here(), paste0("Forecasting-hubs_models/model_output/figures/", current_date ,"-FluForARIMA_ILI.jpg"))
    ggsave(filename, width = 40, height = 20, units = "cm")
  }
  
}