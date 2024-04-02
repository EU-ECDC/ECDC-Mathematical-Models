create_output <- function(indicator, monday_date){
  
  if (length(indicator) == length(cases)) {
    if (all.equal(indicator, cases)) {
      N_countries <- length(unique(data_cases$location_name))
      countries <- unique(data_cases$location)
      ind <- "case"
    }
  } else if (length(indicator) == length(deaths)) {
    if(all.equal(indicator, deaths)) {
      N_countries <- length(unique(data_deaths$location_name))
      countries <- unique(data_deaths$location)
      ind <- "death"
    }
  } else if (length(indicator) == length(hosps)) {
    if(all.equal(indicator, hosps)) {
      N_countries <- length(unique(data_hosps$location_name))
      countries <- unique(data_hosps$location)
      ind <- "hosp"
    }
  }
  
  
  n <- length(indicator)
  Lydia_SARIMA <- data.frame(forecast_date = date(n),
                             target = character(n),
                             target_end_date = date(n),
                             location = character(n),
                             type = character(n),
                             quantile = numeric(n),
                             value = numeric(n))
  
  Lydia_SARIMA$forecast_date <- rep(monday_date, N_rows_per_country*N_countries)
  Lydia_SARIMA$forecast_date <- as.Date(Lydia_SARIMA$forecast_date)
  
  Lydia_SARIMA$target <- rep(rep(c(paste("0 wk ahead inc", ind), paste("1 wk ahead inc", ind), paste("2 wk ahead inc", ind), paste("3 wk ahead inc", ind)),
                                 each = N_quantiles), N_countries)
  
  for (i in 1:n){
    Lydia_SARIMA$target_end_date[i] <- ifelse(Lydia_SARIMA$target[i] == paste("0 wk ahead inc", ind), Lydia_SARIMA$forecast_date[i] - days(2),
                                              ifelse(Lydia_SARIMA$target[i] == paste("1 wk ahead inc", ind), Lydia_SARIMA$forecast_date[i] - days(2) + days(7),
                                                     ifelse(Lydia_SARIMA$target[i] == paste("2 wk ahead inc", ind), Lydia_SARIMA$forecast_date[i] - days(2) + days(14),
                                                            ifelse(Lydia_SARIMA$target[i] == paste("3 wk ahead inc", ind), Lydia_SARIMA$forecast_date[i] - days(2) + days(21)))))
  }
  
  Lydia_SARIMA$location <- rep(countries, each = N_rows_per_country)
  
  Lydia_SARIMA$type <- rep(c("point", rep("quantile", 23)), N_weeks_ahead*N_indicators*N_countries)
  
  Lydia_SARIMA$quantile <- rep(c(NA, 0.01, 0.025, seq(0.05, 0.95, by = 0.05), 0.975, 0.99), 
                               N_weeks_ahead*N_indicators*N_countries)
  
  
  Lydia_SARIMA$value <- ifelse(indicator < 0, 0, indicator)
  Lydia_SARIMA$value <- round(Lydia_SARIMA$value, 0)
  
  return(Lydia_SARIMA)
}