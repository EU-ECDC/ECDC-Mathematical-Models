# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
### Script to run all ARIMA models for all indicators ########
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Oct 2024, Author: Rok

run_ARIMA_models = function(current_date, 
                                   save_files = T, 
                                   run_ILI = T,
                                   run_ARI = T,
                                   run_COVID_cases = T,
                                   run_COVID_hosps = T,
                                   run_COVID_deaths = T,
                                   plot_results = T){
  
  # ARI forecasts
  source("Forecasting-hubs_models/models/ARIMA/ARI2MA/function_run_ARI2MA_model.R")
  run_ARI2MA_model(current_date,
                   run_ILI = run_ILI,
                   run_ARI = run_ARI,
                   run_COVID_cases = run_COVID_cases,
                   run_COVID_hosps = run_COVID_hosps,
                   run_COVID_deaths = run_COVID_deaths,
                   plot_results = plot_results)
  
  # ILI forecasts
  source("Forecasting-hubs_models/models/ARIMA/FluForARIMA/function_run_FluForARIMA_model.R")
  run_FluForARIMA_model(current_date,
                        run_ILI = run_ILI,
                        run_ARI = run_ARI,
                        run_COVID_cases = run_COVID_cases,
                        run_COVID_hosps = run_COVID_hosps,
                        run_COVID_deaths = run_COVID_deaths,
                        plot_results = plot_results)
  
  
  # Merge ILI and ARI forecasts 
  ILI <- paste0('Forecasting-hubs_models/model_output/Syndromic_indicators/ILI/' , current_date+2 ,'-ECDC-FluForARIMA.csv')
  ARI <- paste0('Forecasting-hubs_models/model_output/Syndromic_indicators/ARI/' , current_date+2 ,'-ECDC-ARI2MA.csv')
  
  syndromic_indicators <- bind_rows(read_csv(ILI), read_csv(ARI)) 
  syndromic_indicators %<>%
    mutate(output_type_id = ifelse(is.na(output_type_id), '', as.character(output_type_id)))
  write_csv(syndromic_indicators,paste0('Forecasting-hubs_models/model_output/Syndromic_indicators/', current_date+2,'-ECDC-SARIMA.csv'))
  
  
  # COVID-19 indicators
  source("Forecasting-hubs_models/models/ARIMA/Lydia-SARIMA/function_run_LydiaSARIMA.R")
  run_LydiaSARIMA_model(current_date, 
                        run_ILI = run_ILI,
                        run_ARI = run_ARI,
                        run_COVID_cases = run_COVID_cases,
                        run_COVID_hosps = run_COVID_hosps,
                        run_COVID_deaths = run_COVID_deaths,
                        plot_results = plot_results)
  
  
  return(0)
}
