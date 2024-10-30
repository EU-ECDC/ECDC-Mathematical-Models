create_output <- function(indicator, monday_date, plot_results){
  
  whichday <- weekdays(monday_date)
  
  if(whichday != "Monday") {
    print("Warning: the date should be the Monday of the week that the submission window ends")
  }
  
  n <- length(indicator)
  Lydia_ARI2MA <- data.frame(origin_date = date(n),
                             target = character(n),
                             target_end_date = date(n),
                             horizon = character(n),
                             location = character(n),
                             output_type = character(n),
                             output_type_id = numeric(n),
                             value = numeric(n))
  
  Lydia_ARI2MA$origin_date <- rep(monday_date + 2, N_rows_per_country*N_countries)
  Lydia_ARI2MA$origin_date <- as.Date(Lydia_ARI2MA$origin_date)
  
  Lydia_ARI2MA$target <- "ARI incidence"
  
  Lydia_ARI2MA$horizon <- rep(rep(c(1, 2, 3, 4),
                                  each = N_quantiles), N_countries)
  
  for (i in 1:n){
    Lydia_ARI2MA$target_end_date[i] <- ifelse(Lydia_ARI2MA$horizon[i] == 1, Lydia_ARI2MA$origin_date[i] - days(3),
                                              ifelse(Lydia_ARI2MA$horizon[i] == 2, Lydia_ARI2MA$origin_date[i] +  - days(3) + days(7),
                                                     ifelse(Lydia_ARI2MA$horizon[i] == 3, Lydia_ARI2MA$origin_date[i]  - days(3) + days(14),
                                                            ifelse(Lydia_ARI2MA$horizon[i] == 4, Lydia_ARI2MA$origin_date[i]  - days(3) + days(21)))))
  }
  
  Lydia_ARI2MA$location <- rep(unique(data_cases$location), each = N_rows_per_country)
  
  Lydia_ARI2MA$output_type <- rep(c("median", rep("quantile", 23)), N_weeks_ahead*N_indicators*N_countries)
  Lydia_ARI2MA$output_type <- as.character(Lydia_ARI2MA$output_type)
  
  
  Lydia_ARI2MA$output_type_id <- rep(c("", 0.01, 0.025, seq(0.05, 0.95, by = 0.05), 0.975, 0.99), 
                                     N_weeks_ahead*N_indicators*N_countries)
  
  Lydia_ARI2MA$output_type_id <- as.character(Lydia_ARI2MA$output_type_id)
  
  
  Lydia_ARI2MA$value <- ifelse(indicator < 0, 0, indicator)
  
  write.csv(Lydia_ARI2MA, paste0("Forecasting-hubs_models/model_output/Syndromic_indicators/ARI/", monday_date + 2,"-ECDC-ARI2MA.csv"), 
            row.names=FALSE)
  
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ### Plot results and save the figure ########
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  if (plot_results == TRUE){
    # Dataframe with results [format like the upload to GitHub]
    x = Lydia_ARI2MA
    
    # Make sure 'value' is double
    x$value = as.double(x$value)
    
    # Prepare the dataframe to be used in the 'plot_step_ahead_model_output' function below
    plot_mod_log = x %>% 
      mutate(model_id="log",
             output_type_id = as.numeric(output_type_id)) %>% 
      rename(target_date=target_end_date) %>% 
      filter(output_type != "median")
    
    # Reported data - prepare for plotting
    df_data = data_cases %>% 
      rename(date = truth_date) # correct column names
    
    # Plot the figure
    fig = plot_step_ahead_model_output(plot_mod_log, # Forecasts
                                       df_data %>% mutate(time_idx=date) %>% filter(date>ymd("2024-01-01")), # Reported data
                                       facet=c("location"), facet_scales = "free",
                                       #intervals = c(0.95),
                                       interactive=F)
    
    print(fig)
    # Save the figure
    filename = file.path(here(), paste0("Forecasting-hubs_models/model_output/figures/", current_date ,"-ARI2MA_ARI.jpg"))
    ggsave(filename, width = 40, height = 20, units = "cm")
  }
  
}
