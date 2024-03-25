
arima_models_bycountry_cases <- lapply(sqrt(ts_bycountry_cases), # iterate over all countries
                                       function(y)
                                         summary(auto.arima(y, 
                                                            seasonal = TRUE, 
                                                            approximation = FALSE, 
                                                            trace = FALSE, 
                                                            stepwise = FALSE)
                                         )
)


#for point forecasts
arima_forecasts_bycountry_cases <- lapply(arima_models_bycountry_cases, 
                                          function(model) 
                                            forecast(model, 
                                                     h = 4, 
                                                     level = 0.95)
                                          
)



for (country in 1:N_countries) {
  
  for (i in 1:N) {
    sim_arima_cases[i,] <- simulate(arima_models_bycountry_cases[[country]], nsim = 4)
  }
  quant_cases[[country]] <- apply(sim_arima_cases^2, 2, function(x){ quantile(x, quants) })
  df_cases[[country]] <- rbind((arima_forecasts_bycountry_cases[[country]]$mean)^2, quant_cases[[country]])
}

cases <- vector()
for (country in 1:N_countries){
  cases <- c(cases, as.vector(df_cases[[country]]))
}

#matplot(t(sim_arima), type = "l")

