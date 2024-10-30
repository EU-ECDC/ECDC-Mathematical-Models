arima_models_bycountry_deaths <- lapply(ts_bycountry_deaths, # iterate over all countries
                                        function(y)
                                          summary(auto.arima(y, 
                                                             seasonal = TRUE, 
                                                             approximation = FALSE, 
                                                             trace = FALSE, 
                                                             stepwise = FALSE)
                                          )
)


#for point forecasts
arima_forecasts_bycountry_deaths <- lapply(arima_models_bycountry_deaths, 
                                           function(model) 
                                             forecast(model, 
                                                      h = 4, 
                                                      level = 0.95)
                                           
)


for (country in 1:N_countries_deaths) {
  
  for (i in 1:N) {
    sim_arima_deaths[i,] <- simulate(arima_models_bycountry_deaths[[country]], nsim = 4)
  }
  quant_deaths[[country]] <- apply(sim_arima_deaths, 2, function(x){ quantile(x, quants) })
  df_deaths[[country]] <- rbind(arima_forecasts_bycountry_deaths[[country]]$mean, quant_deaths[[country]])
}

deaths <- vector()
for (country in 1:N_countries_deaths){
  deaths <- c(deaths, as.vector(df_deaths[[country]]))
}

