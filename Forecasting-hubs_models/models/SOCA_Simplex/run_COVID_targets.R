# This function
# - runs the simplex_compute.R function which outputs the forecasts, 
# - find optimal parameters from the past 4 weeks, 
# - prepares the forecast data structure for submission, and 
# - saves .csv and .jpg figures with the forecasts

run_COVID_targets = function(E_vec, 
                             transform_vec, 
                             df_all, 
                             df_train, 
                             dates_to_forecast_from,
                             country_list,
                             save_files,
                             target,
                             plot_results){
  
  
  df_out = simplex_compute(df_train, dates_to_forecast_from, E_vec, country_list, transform_vec, target)
  
  
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ### COVID-19: Find optimal E and transform_type for each country ########
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  
  # For evert E and transform_type compute WIS
  df_test_impact_variable = data.frame()
  for (E in E_vec){
    for (transform_type in transform_vec){
      
      summ_scores_simplex = estimate_simplex_WIS(df_out=df_out, 
                                                 df_all=df_all, 
                                                 E_optimal = E, 
                                                 transform_type_optimal = transform_type, 
                                                 which_method = "simplex")
      summ_scores_simplex$E = E
      summ_scores_simplex$transform_type = transform_type
      
      df_test_impact_variable = bind_rows(df_test_impact_variable, summ_scores_simplex)
    }
  }
  
  
  
  
  # Get optimal E and transform_type for each country (aka, find minimal WIS)
  optimal_pars = df_test_impact_variable %>% 
    as.data.table() %>% 
    summarise_scores(by=c("origin_date","target","location","model","E","transform_type"), relative_skill = F) %>%
    group_by(target, location, model) %>%
    summarise(min_WIS = min(interval_score),
              best_E = E[interval_score == min_WIS],
              best_transform_type = transform_type[interval_score == min_WIS]) %>%
    ungroup()
  
  # Filter out the forecasts where ratio of 99 percentile and median value is >100
  # This is done because sometimes (rarely) our forecasts are really wide due to issues of how we define uncertainty.
  # Fix this by ignoring forecasts where 99 percentile value is >100x larger than the median one
  df_out_filtered = df_out %>% 
    group_by(location,target_end_date,horizon, target, model, E, transform_type, origin_date) %>%
    mutate(rat = max(prediction) / prediction[output_type_id==0.5]) %>%
    ungroup() %>%
    arrange(rat) %>% 
    merge(optimal_pars) %>%
    filter(E == best_E,
           transform_type == best_transform_type,
           rat < 100) %>%
    dplyr::select(-rat, min_WIS, best_E, best_transform_type)
  
  
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ### COVID-19: Prepare data for submission ########
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  
  # This part gathers 4-week forecasts from the last known data point
  df_forecasts = data.frame()
  missing_countries = unique(df_out_filtered$location)
  for (date_forecast in rev(dates_to_forecast_from)){ # Loop for every week we do forecasts for, starting with most recent
    # Filtered dataframe where we select only current date_forecast as well as best/optimal E and transform_type
    df_tmp = df_out_filtered %>% merge(optimal_pars) %>%
      filter(E == best_E,
             transform_type == best_transform_type,
             location %in% missing_countries) %>%
      filter(origin_date == date_forecast)
    
    df_forecasts = bind_rows(df_forecasts, df_tmp)
    
    # This part makes sure that in the next itration of the for loop we add forecasts of those countries that don't have their submissions added to df_forecast (see few lines above)
    # In other words, we make sure to take only forecasts from most recent reported data value (and not forecasts from earlier weeks)
    missing_countries = relcomp(unique(df_out_filtered$location),unique(df_forecasts$location)) # Function that returns which countries do not have forecasts made from date_forecast
    if (isempty(missing_countries)){
      break
    }
  }
  
  # Add median value to the output dataframe (currently we only have quantiles)
  df_forecasts_mean_values = df_forecasts %>% 
    filter(output_type_id==0.5) %>%
    mutate(output_type = "point",
           output_type_id = "")
  
  df_submission = df_forecasts %>% 
    mutate(output_type_id = as.character(output_type_id)) %>%
    bind_rows(df_forecasts_mean_values) %>% # Add median value to the forecast dataframe
    mutate(horizon = as.integer( difftime(target_end_date, (current_date-8), units = "weeks") ),
           origin_date = current_date+2, # change the definition of the origin date to agree with the date of submission
           target = ifelse(target == "hosp","hospital admissions",
                           ifelse(target == "case", "cases","deaths")),
           target_end_date = target_end_date,
           output_type = ifelse(output_type == "point","median","quantile"),
           #quantile = as.double(output_type_id),
           value = as.integer(prediction)) %>% 
    filter(horizon < 5,
           horizon > -2) %>% # take only horizons between -1 and 4 
    dplyr::select(origin_date,target,target_end_date,horizon,location,output_type,output_type_id,value) 
  
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ### COVID-19: Save csv ########
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  date_submission = current_date + 2
  if (save_files == T){
    df_submission %>% 
      write_csv(file=file.path(here(), paste0("Forecasting-hubs_models/model_output/COVID/",date_submission,"-ECDC-soca_simplex_", target,".csv")))
    
  }
  
  
  
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ### COVID-19: Plot results and save the figure ########
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # Additonally: Plot results and save the figure
  if (plot_results == T){
    # Load the file of one target
    x=read_csv(file=file.path(here(), paste0("Forecasting-hubs_models/model_output/COVID/", date_submission ,"-ECDC-soca_simplex_",target ,".csv")),col_types = cols(.default = "c"))
    # Make sure 'value' is double
    x$value = as.double(x$value)
    
    # Prepare for plot
    forecast = x %>%
      rename(target_date = target_end_date,
             quantiles = output_type_id) %>%
      mutate(target_date = ymd(target_date),
             quantiles = as.double(quantiles)) %>%
      select(location, target_date, quantiles, value)
    data = df_train %>%
      mutate(date=ymd(date)) %>%
      select(location, date, value)
      
    
    # Plot the figure
    fig = plot_data_with_quantiles(data, forecast)
    
    print(fig)
    # Save the figure
    filename = file.path(here(), paste0("Forecasting-hubs_models/model_output/figures/", date_submission ,"-ECDC-soca_simplex_",target ,".jpg"))
    ggsave(filename, width = 40, height = 20, units = "cm")
  }
  
  return(0)
}
