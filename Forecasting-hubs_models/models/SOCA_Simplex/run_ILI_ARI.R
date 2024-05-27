# This function
# - runs the simplex_compute.R function which outputs the forecasts, 
# - find optimal parameters from the past 4 weeks, 
# - prepares the forecast data structure for submission, and 
# - saves .csv and .jpg figures with the forecasts

run_ILI_ARI = function(E_vec, 
                       transform_vec, 
                       df_all, 
                       df_train, 
                       dates_to_forecast_from,
                       country_list,
                       save_files,
                       target){
  
    # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    ### ILIs & ARIs: Define parameters and perform simplex forecast ########
    # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    df_out = simplex_compute(df_train, dates_to_forecast_from, E_vec, country_list, transform_vec, target)
    
    
    # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    ### ILIs & ARIs: Find optimal E and transform_type for each country ########
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
    ### ILIs & ARIs: Prepare data for submission ########
    # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    # This part gathers 4-week forecasts from the last known data point
    df_forecasts = data.frame()
    missing_countries = unique(df_out_filtered$location)
    for (date_forecast in rev(dates_to_forecast_from)){ # Loop for every week we do forecasts for, starting with most recent
      # Filtered dataframe where we select only current date_forecast as well as best/optimal E and transform_type
      df_tmp = df_out_filtered %>% 
        merge(optimal_pars) %>%
        filter(E == best_E,
               transform_type == best_transform_type,
               location %in% missing_countries) %>%
        filter(origin_date == date_forecast)
      
      df_forecasts = bind_rows(df_forecasts, df_tmp)
      
      # This part makes sure that in the next itration of the for loop we add forecasts of those countries that don't have their submissions added to df_forecast (see few lines above)
      # In other words, we make sure to take only forecasts from most recent reported data value (and not forecasts from earlier weeks)
      missing_countries = relcomp(unique(df_out_filtered$location),unique(df_forecasts$location))
      if (isempty(missing_countries)){
        break
      }
    }
    
    # Add median value to the output dataframe (currently we only have quantiles)
    df_forecasts_mean_values = df_forecasts %>% 
      filter(output_type_id==0.5) %>%
      mutate(output_type = "median",
             output_type_id = "")
    
    df_submission = df_forecasts %>% 
      mutate(output_type_id = as.character(output_type_id)) %>%
      bind_rows(df_forecasts_mean_values) %>% # Add median value to the forecast dataframe
      mutate(origin_date = origin_date+10, # change the definition of the origin date to agree with the date of submission
             target_end_date = target_end_date,
             value = prediction) %>% 
      filter(horizon < 5) %>% # take only horizons up to 4 weeks ahead
      dplyr::select(origin_date, target, target_end_date, horizon, location, output_type, output_type_id, value)
  
  
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ### ILIs & ARIs: Save csv ########
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  if (save_files == T){
    date_submission = current_date + 2
    if (target == "ILI incidence"){
      df_submission %>% 
        filter(origin_date == (current_date+2)) %>% 
        write_csv(file=file.path(here(), paste0("SOCA_Simplex/ILI/",date_submission,"-ECDC-soca_simplex.csv")))
      
    } else if (target == "ARI incidence"){
      df_submission %>% 
        filter(origin_date == (current_date+2)) %>% 
        write_csv(file=file.path(here(), paste0("SOCA_Simplex/ARI/",date_submission,"-ECDC-soca_simplex.csv")))
      
    } else {
      stop("Unclear target!")
    }
  }
  
  
  
  
  
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ### ILIs & ARIs: Plot results and save the figure ########
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # Load the file of the correct target
  if (target == "ILI incidence"){
    x=read_csv(file=file.path(here(), paste0("SOCA_Simplex/ILI/", current_date+2 ,"-ECDC-soca_simplex.csv")),col_types = cols(.default = "c"))
  } else if (target == "ARI incidence"){
    x=read_csv(file=file.path(here(), paste0("SOCA_Simplex/ARI/", current_date+2 ,"-ECDC-soca_simplex.csv")),col_types = cols(.default = "c"))
  } else {
    stop("Wrong target!")
  }
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
  filename = file.path(here(), paste0("Forecasting-hubs_models/model_output/figures/", current_date ,"-ECDC-soca_simplex_",target ,".jpg"))
  ggsave(filename, width = 40, height = 20, units = "cm")
  
  return(0)
}