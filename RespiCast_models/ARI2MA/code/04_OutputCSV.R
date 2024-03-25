create_output <- function(indicator, monday_date){
  
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
  
  write.csv(Lydia_ARI2MA, paste0("./data-processed/", monday_date + 2,"-ECDC-ARI2MA.csv"), 
            row.names=FALSE)
}
