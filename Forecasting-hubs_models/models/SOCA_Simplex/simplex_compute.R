# This function estimates the forecasts by using the SOCA Simplex method described in the README file of the sub-repository

simplex_compute = function(df_train, # historical data to use for forecast
                           dates_to_forecast_from, # dates to forecast on
                           E_vec, # vector of pattern length to use
                           country_list, # countries to forecast
                           transform_vec, # data type to use for forecasting
                           target # target of the output, eg ARI or hosp (COVID-19)
                           ){
  
  df_sol_all = NULL
  df_comparison_all = NULL
  
  for (transform_type in transform_vec){ # A loop for every data type

    # Given the transform_type, create a new column with the data type to use
    if (transform_type == "weekly"){
      df_train$value_used = df_train$value
      
    } else if (transform_type == "delta-weekly") {
      df_train$value_used = df_train$value_diff
      
    } else if (transform_type == "log-weekly") {
      df_train$value_used = df_train$value_log
      
    } else if (transform_type == "delta-log-weekly") {
      df_train$value_used = df_train$value_log_diff
      
    } else {
      stop("Wrong data transformation type")
    }
    
    df_sol = NULL
    E_count = 0
    for (E in E_vec){ # E is a length of the pattern to use: e.g., E=3 means that we use the 3 most recent data points as our pattern
      E_count = E_count + 1
      
      # Forecast
      df_comparison = NULL
      for (country in country_list){ # for every country
        # data of the current country that we use for forecasting
        df_forecast_country = df_train %>% filter(location == country)
        
        # In case there are no data for this country, go to the next country
        if (nrow(df_forecast_country) == 0){
          message(paste0("No data frame for ", country))
          next
        }
        
        for (date_forecast in dates_to_forecast_from){ # For every forecast date (we forecast more dates, current + those in the past which are used to obtain optimal E and transform_vec)
          date_forecast = as.Date(date_forecast)
          
          # In case there are more than one reorted value for this week, ignore and go to the next iteration (aka avoiding bugs in the data)
          ind = which(df_forecast_country$date==date_forecast)
          if (length(ind)!=1){
            next
          }
          
          # Obtain current date (aka date of report) and the pattern of the last E values
          date_current <- df_forecast_country$date[ind]
          vec_current <- df_forecast_country$value_used[(ind-E+1):ind]
          
          # If any of the values in the pattern are NA, ignore and go to the next iteration
          if (any(is.na(vec_current))){
            message(paste0("No data (vec_current) for ", country))
            next
          }
          
          # Select the training data, aka the country data before the current week
          df_train_country = df_train %>% filter(location == country, date!=date_forecast)
          df_final <- NULL
          # For loop that goes over all past dates, takes a pattern of length E and compares it to the current pattern
          for (k in (E+1):(nrow(df_train_country)-E)){
            # A pattern of length E from the past
            val = df_train_country$value_used[(k-E+1):k] 
            
            # Compute the error: the difference between 'current' pattern and 'past' pattern
            # TODO: think about changing the 'err' measure, currently it is L2-norm
            err = sqrt( mean((val-vec_current)**2) )
            
            # For a given past date (pattern), save the next time points which might/will be used as a base for forecasts
            df <- df_train_country[k,]
            df$err <- err
            df$forecast_1 <- df_train_country$value_used[k+1]
            df$forecast_2 <- df_train_country$value_used[k+2]
            df$forecast_3 <- df_train_country$value_used[k+3]
            df$forecast_4 <- df_train_country$value_used[k+4]
            df$forecast_5 <- df_train_country$value_used[k+5]
            
            # Making a new dataframe with all the info from the past dates
            df_final <- bind_rows(df_final, df)
          }
          
          # Take only those 'dates' with the smallest error
          # In the current implementation, take E+1 values
          simplex = df_final %>% arrange(err) %>% head(n=E+1)
          
          # When error=0 (aka, the current and past patterns are the same), use small but non-zero value
          # This is to avoid numerical issues in the algorithm below
          simplex$err[simplex$err==0] = 1e-3
          weights = (1/simplex$err) # Define weight as 1/error
          weights = weights / sum(weights) # normalize the weights to sum to 1
          
          # Save the current 'simplex' variable for potential later use as we will make changes to the 'simplex' variable
          t =  simplex
          
          # Transform back to 'normal'(=weekly) units
          if (transform_type == "weekly"){
            # Already in correct units (weekly)
            
          } else if (transform_type == "delta-weekly") {
            simplex$forecast_1 = simplex$forecast_1 + df_forecast_country$value[ind]
            simplex$forecast_2 = simplex$forecast_2 + df_forecast_country$value[ind]
            simplex$forecast_3 = simplex$forecast_3 + df_forecast_country$value[ind]
            simplex$forecast_4 = simplex$forecast_4 + df_forecast_country$value[ind]
            simplex$forecast_5 = simplex$forecast_5 + df_forecast_country$value[ind]
            
          } else if (transform_type == "log-weekly") {
            simplex$forecast_1 = 10^simplex$forecast_1
            simplex$forecast_2 = 10^simplex$forecast_2
            simplex$forecast_3 = 10^simplex$forecast_3
            simplex$forecast_4 = 10^simplex$forecast_4
            simplex$forecast_5 = 10^simplex$forecast_5
            
          } else if (transform_type == "delta-log-weekly") {
            simplex$forecast_1 = 10^(simplex$forecast_1 + df_forecast_country$value_log[ind])
            simplex$forecast_2 = 10^(simplex$forecast_2 + df_forecast_country$value_log[ind])
            simplex$forecast_3 = 10^(simplex$forecast_3 + df_forecast_country$value_log[ind])
            simplex$forecast_4 = 10^(simplex$forecast_4 + df_forecast_country$value_log[ind])
            simplex$forecast_5 = 10^(simplex$forecast_5 + df_forecast_country$value_log[ind])
            
          } else {
            stop("Wrong data transformation type")
          }
          
          # A for loop for all possible horizons (currently 1:5, could be longer/shorter)
          for (tau in 1:5){
            # Take the tau-week forecast (aka take the correct column from simplex dataframe) + weights of the different forecasts (rows)
            df_dist=data.frame(value = (simplex%>%pull(paste0("forecast_",tau))), weight = weights)
            
            # Create a list of forecast values with proportions of each forecast being proportional to the weight
            my_vector=with(df_dist, rep(value, round(weight*1e4)))
            # Delete all NA values
            my_vector = my_vector[!is.na(my_vector)] # TODO: think how to deal with NAs
            # Put 0 or negative values to NA
            my_vector[my_vector<=0] = NA # TODO: try finding a distribution which allows using 0 values
            
            # Skip if all values of distribution are NA or if only one value exists (aka, we cannot estimate the distribution from one value)
            if ( length(unique(my_vector[!is.na(my_vector)]))<2 ) {
              
            } else {
              # Quantiles where we need value at: this is defined within the Hub procedure
              quantile_vec = c(0.01, 0.025, seq(0.05, 0.95, by = 0.05), 0.975, 0.99) 
              
              # Estimate quantiles given the simplex using weighted distribution
              # random_values: random values from a given distribution with the mean and sd from the values in simplex dataframe
              random_values = rlnorm(1e4, meanlog = mean(log(my_vector), na.rm = T), sdlog = sd(log(my_vector), na.rm = T))
              
              
              # Example of using poisson distribution
              # random_values = rpois(1e4, lambda = mean(my_vector, na.rm = T))
              #
              # Example of using Negative binomial
              # m = mean(my_vector, na.rm=T)
              # s = sd(my_vector, na.rm=T)
              # random_values = rnbinom(1e4, size=(m^2/(s^2-m)), prob = m/s^2 )
              
              # Take/obtain required quantiles from the random_values distribution to be used in the hub submission
              quants = quantile(random_values, probs = quantile_vec, names = FALSE)
              
              # Create a new dataframe with all the needed columns
              df = data.frame(location = country,
                              output_type = "quantile",
                              output_type_id = quantile_vec, 
                              prediction = quants,
                              target_end_date = ymd(date_current) + 7*tau,
                              horizon = tau,
                              origin_date = ymd(date_current),
                              target = target,
                              model = "simplex")
              
              df_comparison = bind_rows(df_comparison, df)
            }
            
          }
        }
      }
      
      # Checks to make sure we do not have NA or NaN in our data
      if (any(is.na(df_comparison$prediction))) {
        message("df_comparison na")
        browser()
      }
      if (any(is.nan(df_comparison$prediction))) {
        message("df_comparison nan")
        browser()
      }
      
      # Save also E and transform_type 
      df_comparison$E = E
      df_comparison$transform_type = transform_type
      df_comparison_all <- bind_rows(df_comparison_all, df_comparison)
      
    }
    
  }
  
  return(df_comparison_all)
}
