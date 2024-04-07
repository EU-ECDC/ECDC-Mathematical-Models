# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
### Simplex model for ILI/ARI  ########
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# This function:
# - loads and cleans the data for the relevant indicators, 
# - defines defines the relevant parameters, and 
# - calls the run_X.R function


run_soca_simplex_model = function(current_date, 
                                  save_files = T, # Variable to state if the output files are saved. Default is TRUE
                                  run_ILI = T, # Variables to define if the SOCA simplex method us run for each individual indicator. This is mostly used for debugging
                                  run_ARI = T,
                                  run_COVID_cases = T,
                                  run_COVID_hosps = T,
                                  run_COVID_deaths = T
                                  ){
  
  # current_date = Monday of the submission week
  if ( weekdays(current_date) != "Monday"){
    stop("The input date is NOT a Monday. Please provide Monday of the submission week.")
  }
  

  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ### ILIs & ARIs: Load and clean data ########
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  
  
  countries_EU = c( "Austria", "Croatia", "Denmark", "France", "Greece", 
                    "Ireland", "Latvia", "Romania", "Spain", "Belgium", 
                    "Bulgaria",  "Cyprus", "Czechia", "Estonia", "Finland",  
                    "Germany", "Hungary", "Iceland", "Italy", "Liechtenstein", 
                    "Lithuania", "Luxembourg", "Malta","Netherlands", "Norway", 
                    "Poland", "Portugal", "Slovakia", "Slovenia", "Sweden" ) 
  
  # Load data
  df_all_ILI = read.csv("https://raw.githubusercontent.com/european-modelling-hubs/flu-forecast-hub/main/target-data/latest-ILI_incidence.csv") %>%
    rename(date = truth_date)
  
  # Filter and clean the data
  df_train_ILI <- df_all_ILI %>% 
    filter((date<"2019-12-01" & date>"2015-10-01") | (date>"2022-10-01")) %>% # exclude covid years
    arrange(location, date) %>%
    group_by(location) %>%
    mutate(value = ifelse(value==0, 1e-3, value)) %>%
    mutate(value_diff = c(NA, diff(value))) %>%
    mutate(value_log = log10(value)) %>%
    mutate(value_log_diff = c(NA, diff(value_log))) %>%
    ungroup()
  
  # Load data
  df_all_ARI = read.csv("https://raw.githubusercontent.com/european-modelling-hubs/ari-forecast-hub/main/target-data/latest-ARI_incidence.csv") %>%
    rename(date = truth_date)
  
  # Filter and clean the data
  df_train_ARI <- df_all_ARI %>% 
    filter((date<"2019-12-01" & date>"2015-10-01") | (date>"2022-10-01")) %>% # exclude covid years
    arrange(location, date) %>%
    group_by(location) %>%
    mutate(value = ifelse(value==0, 1e-3, value)) %>%
    mutate(value_diff = c(NA, diff(value))) %>%
    mutate(value_log = log10(value)) %>%
    mutate(value_log_diff = c(NA, diff(value_log))) %>%
    ungroup()
  
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ### ILIs & ARIs: Run for ILI and ARI ########
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  
  # Run the method for both indicators
  for (target in c("ILI incidence","ARI incidence")){
    
    # Check if we skip this target
    if (target == "ILI incidence"){
      if (run_ILI == F){
        message(paste0("Skipping ", target))
        next
      }
    }
    if (target == "ARI incidence"){
      if (run_ARI == F){
        message(paste0("Skipping ", target))
        next
      }
    }
    message(paste0("#### ---- Running for ", target))
    
    # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    ### ILIs & ARIs: Define parameters and perform simplex forecast ########
    # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # params
    E_vec = seq(2,8) # The length of the most recent pattern that we compare it to historical data
    transform_vec = c("weekly","delta-weekly","log-weekly","delta-log-weekly") # data type that we use in the simplex function
    # NOTE:
    # weekly = reported data
    # delta-weekly = the incremental change between week i and i+1
    # log-weekly = log10( reported data )
    # delta-log-weekly = the incremental change of log10(reported data) between week i and i+1
    
    # Select the ILI or ARI data; 
    # df_all = all available data, used to evaluate past forecasts to estimate optimal E and transform_vec
    # df_train = data up to the forecasting date, ignoring pandemic years - aka using this time filter: filter((date<"2019-12-01" & date>"2015-10-01") | (date>"2022-10-01")) 
    if (target == "ILI incidence"){
      df_all = df_all_ILI 
      df_train = df_train_ILI
    } else if (target == "ARI incidence"){
      df_all = df_all_ARI
      df_train = df_train_ARI
    } else {
      stop("Unclear target!")
    }
    
    # Forecast dates: forecast for every week in the last 5 weeks - this is used to estimate optimal E and transform_vec
    dates_to_forecast_from = (current_date-8) + c(-28,-21,-14,-7,0)
    
    # Country list to forecast - select all countries with available data
    country_list = df_all$location %>% unique()
    
    tryCatch( # Add tryCatch to make sure that you can still run for other targets in case one target has an error
      {
        # This function runs the soca simplex, optimises it for optimal value of E and transform_vec, and saves the forecasts + figures
        run_ILI_ARI(E_vec, 
                    transform_vec, 
                    df_all, 
                    df_train, 
                    dates_to_forecast_from,
                    country_list,
                    save_files,
                    target)
      },
      error = function(cond) {
        message(paste0("Soca simplex was not able to run for ", target))
        # Return value in case of error
        message(cond)
      }
    )
    
    message(paste0("#### ---- Finished for ", target))
  }
  
  
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ### COVID-19: Load and clean data ########
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  
  
  countries_EU = c( "Austria", "Croatia", "Denmark", "France", "Greece", 
                    "Ireland", "Latvia", "Romania", "Spain", "Belgium", 
                    "Bulgaria",  "Cyprus", "Czechia", "Estonia", "Finland",  
                    "Germany", "Hungary", "Iceland", "Italy", "Liechtenstein", 
                    "Lithuania", "Luxembourg", "Malta","Netherlands", "Norway", 
                    "Poland", "Portugal", "Slovakia", "Slovenia", "Sweden" ) 
  
  # Load data
  path_data_cases = "https://raw.githubusercontent.com/european-modelling-hubs/covid19-forecast-hub-europe/main/data-truth/ECDC/truth_ECDC-Incident%20Cases.csv"
  path_data_deaths = "https://raw.githubusercontent.com/european-modelling-hubs/covid19-forecast-hub-europe/main/data-truth/ECDC/truncated_ECDC-Incident%20Deaths.csv"
  path_data_hosps = "https://raw.githubusercontent.com/european-modelling-hubs/covid19-forecast-hub-europe/main/data-truth/OWID/truncated_OWID-Incident%20Hospitalizations.csv"
  
  
  df_all_cases = read.csv(path_data_cases) %>%
    dplyr::select(location,date,value) 
  
  df_all_deaths = read.csv(path_data_deaths) %>%
    dplyr::select(location,date,value)
  
  df_all_hosps = read.csv(path_data_hosps) %>%
    dplyr::select(location,date,value)
  
  # Filter and clean the data 
  df_train_cases = df_all_cases %>%
    filter(!is.na(value)) %>%
    arrange(location, date) %>%
    group_by(location) %>%
    mutate(value = ifelse(value==0, 1e-3, value)) %>%
    mutate(value_diff = c(NA, diff(value))) %>%
    mutate(value_log = log10(value)) %>%
    mutate(value_log_diff = c(NA, diff(value_log))) %>%
    ungroup()
  
  df_train_deaths = df_all_deaths %>%
    filter(!is.na(value)) %>%
    arrange(location, date) %>%
    group_by(location) %>%
    mutate(value = ifelse(value==0, 1e-3, value)) %>%
    mutate(value_diff = c(NA, diff(value))) %>%
    mutate(value_log = log10(value)) %>%
    mutate(value_log_diff = c(NA, diff(value_log))) %>%
    ungroup()
  
  df_train_hosps = df_all_hosps %>%
    filter(!is.na(value)) %>%
    arrange(location, date) %>%
    group_by(location) %>%
    mutate(value = ifelse(value==0, 1e-3, value)) %>%
    mutate(value_diff = c(NA, diff(value))) %>%
    mutate(value_log = log10(value)) %>%
    mutate(value_log_diff = c(NA, diff(value_log))) %>%
    ungroup()
  
  
  
  
  
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ### COVID-19: Run for all targets ########
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  
  time_start = Sys.time()
  for (target in c("case", "death", "hosp")){
    message(paste0("#### ---- Running for ", target))
    
    # Check if we skip this target
    if (target == "case"){
      if (run_COVID_cases == F){
        message(paste0("Skipping ", target))
        next
      }
    }
    if (target == "hosp"){
      if (run_COVID_hosps == F){
        message(paste0("Skipping ", target))
        next
      }
    }
    if (target == "death"){
      if (run_COVID_deaths == F){
        message(paste0("Skipping ", target))
        next
      }
    }
    
    # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    ### COVID-19: Define parameters and perform simplex forecast ########
    # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # params
    E_vec = seq(2,8) # The length of the most recent pattern that we compare it to historical data
    transform_vec = c("weekly","delta-weekly","log-weekly","delta-log-weekly") # data type that we use in the simplex function
    # NOTE:
    # weekly = reported data
    # delta-weekly = the incremental change between week i and i+1
    # log-weekly = log10( reported data )
    # delta-log-weekly = the incremental change of log10(reported data) between week i and i+1
    
    # Select the case/hosp/death; 
    # df_all = all available data, used to evaluate past forecasts to estimate optimal E and transform_vec
    # df_train = data up to the forecasting date
    if (target == "case"){
      df_all = df_all_cases
      df_train = df_train_cases
    } else if (target == "death"){
      df_all = df_all_deaths
      df_train = df_train_deaths
    } else if (target == "hosp"){
      df_all = df_all_hosps
      df_train = df_train_hosps
    } else {
      stop("Unclear target!")
    }
    
    # Forecast dates: forecast for every week in the last 5 weeks - this is used to estimate optimal E and transform_vec
    dates_to_forecast_from = (current_date-9) + c(-28,-21,-14,-7,0)
    
    # Country list to forecast - select all countries with available data
    country_list = df_all %>% pull(location) %>% unique()
    

    tryCatch( # Add tryCatch to make sure that you can still run for other targets in case one target has an error
      {
        # This function runs the soca simplex, optimises it for optimal value of E and transform_vec, and saves the forecasts + figures
        run_COVID_targets(E_vec,
                          transform_vec,
                          df_all,
                          df_train,
                          dates_to_forecast_from,
                          country_list,
                          save_files,
                          target)
      },
      error = function(cond) {
        message(paste0("Soca simplex was not able to run for ", target))
        # Choose a return value in case of error
        message(cond)
      }
    )
    message(paste0("#### ---- Finished for ", target))
  }
  
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ### COVID-19: Merge all three target files together ########
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # Additonally: Plot results and save the figure
  
  date_submission = current_date
  
  df = data.frame()
  for (target in c("case","death","hosp")){
    # Load the file of one target
    x=read_csv(file=paste0("COVID-19/", current_date ,"-ECDC-soca_simplex_",target ,".csv"),col_types = cols(.default = "c"))
    # Make sure 'value' is double
    x$value = as.double(x$value)
    
    #Bind all targets into one dataframe
    df = bind_rows(df, x)
  }
  
  # Save the dataframe with all targets in one file
  df %>% 
    filter(forecast_date == current_date) %>% 
    write_csv(file=paste0("COVID-19/",date_submission,"-ECDC-soca_simplex.csv"))
  
  
  
  return(0)
}

