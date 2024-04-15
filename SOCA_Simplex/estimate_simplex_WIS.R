estimate_simplex_WIS = function(df_out=NULL, 
                                df_all=NULL,
                                E_optimal = NULL,
                                transform_type_optimal = NULL,
                                which_method = "simplex",
                                indicator = NULL){
  
  if (which_method == "simplex"){
  truth_data = df_all %>%
    rename(target_end_date = date,
           true_value = value) %>%
    dplyr::select(location, target_end_date, true_value)

  full_data <- merge(df_out %>% filter(E==E_optimal,transform_type==transform_type_optimal) %>% rename("quantile" = "output_type_id"), 
                     truth_data, by = c("target_end_date", "location"), all.x = TRUE)
  
  # remove rows related to median and where true data is null
  full_data <- full_data[full_data$output_type != "median", ]
  #full_data <- full_data[complete.cases(full_data$true_value), ]
  
  # compute scoring metrics
  forecast_scores <- set_forecast_unit(
    full_data,
    c("origin_date", "target", "target_end_date", "horizon", "location", "model")
  ) %>%
    check_forecasts() %>%
    score(metrics=c("ae_median", "interval_score"))
  
  # summarize scores
  summ_scores <- forecast_scores %>%
    summarise_scores()
  
  
  
  
  
  } else if (which_method %in% c("ensemble", "baseline")){
    # Read the truth data
    
    
    if (which_method == "ensemble"){
      method_name = "hubEnsemble"
    } else if (which_method == "baseline"){
      method_name = "quantileBaseline"
    } else {
      stop("Wrong method name")
    }
     
    if (indicator == "ILI"){
      subfolders <- c("ERVISS", "FluID")
    } else if (indicator == "ARI") {
      subfolders <- c("ERVISS")
    } else {
      stop("Wrong indicator name")
    } 
    
    
    
    truth_data <- data.frame()
    for (subfolder in subfolders) {
      if (indicator == "ILI"){
        truth_data_temp <- read.csv(paste0("https://raw.githubusercontent.com/european-modelling-hubs/flu-forecast-hub/main", "/target-data/", subfolder, "/latest-ILI_incidence.csv"), header = TRUE)  
      } else if (indicator == "ARI") {
        truth_data_temp <- read.csv(paste0("https://raw.githubusercontent.com/european-modelling-hubs/ARI-forecast-hub/main", "/target-data/", subfolder, "/latest-ARI_incidence.csv"), header = TRUE)  
      } else {
        stop("Wrong indicator name")
      }
      
      truth_data <- rbind(truth_data, truth_data_temp)
    }
    
    # rename truth columns 
    truth_data <- truth_data %>% 
      rename("target_end_date" = "truth_date",
             "true_value" = "value")
    truth_data <- truth_data[, !names(truth_data) %in% "year_week"]
    truth_data$target_end_date <- as.Date(truth_data$target_end_date, format = "%Y-%m-%d")
    
    
    
    df_forecasts = NULL
    if (indicator == "ILI"){
      dates_hub = read.csv("https://raw.githubusercontent.com/european-modelling-hubs/flu-forecast-hub/main/supporting-files/forecasting_weeks.csv") %>%
        filter(is_latest=="False") %>% pull(origin_date) %>% unique() %>% sort()
    } else if (indicator == "ARI") {
      dates_hub = read.csv("https://raw.githubusercontent.com/european-modelling-hubs/ARI-forecast-hub/main/supporting-files/forecasting_weeks.csv") %>%
        filter(is_latest=="False") %>% pull(origin_date) %>% unique() %>% sort()
    } else {
      stop("Wrong indicator name")
    }
    
    
    for (date_hub in dates_hub){

      if (indicator == "ILI"){
        df <- read.csv(paste0("https://raw.githubusercontent.com/european-modelling-hubs/flu-forecast-hub/main/model-output/respicast-", method_name, "/",date_hub,"-respicast-", method_name, ".csv"))
      } else if (indicator == "ARI") {
        df <- read.csv(paste0("https://raw.githubusercontent.com/european-modelling-hubs/ARI-forecast-hub/main/model-output/respicast-", method_name, "/",date_hub,"-respicast-", method_name, ".csv"))
      } else {
        stop("Wrong indicator name")
      }

      df_forecasts = bind_rows(df_forecasts,df)
    }
    df_forecasts$model_id = which_method
    
    # rename model output columns 
    model_outputs <- df_forecasts %>% 
      rename("quantile" = "output_type_id",
             "prediction" = "value",
             "model" = "model_id")
    
    # join model output and truth (left join)
    model_outputs$target_end_date = as.Date(model_outputs$target_end_date)
    truth_data$target_end_date = as.Date(truth_data$target_end_date)
    full_data <- merge(model_outputs, truth_data, by = c("target_end_date", "location"), all.x = TRUE)
    
    # remove rows related to median and where true data is null
    full_data <- full_data[full_data$output_type != "median", ]
    full_data <- full_data[complete.cases(full_data$true_value), ]
    
    # compute scoring metrics
    forecast_scores <- set_forecast_unit(
      full_data,
      c("origin_date", "target", "target_end_date", "horizon", "location", "model")
    ) %>%
      check_forecasts() %>%
      score(metrics=c("ae_median", "interval_score"))
    
    # summarize scores
    summ_scores <- forecast_scores %>%
      summarise_scores()

  } else {
    stop("Unclear which method to compute WIS of")
  }
  
  return(summ_scores)
  
}