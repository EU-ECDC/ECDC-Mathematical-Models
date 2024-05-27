# ECDC models submitted to forecasting hubs
Here you will find a collection of mathematical models developed by the ECDC Mathematical Modelling team for the various forecasting hubs. 

## Running all forecasting models
`main.R` in this folder will run all models for all currently active hubs. Output will be stored in `📁model_output` and is ready for submission via the appropriate github repositories.

## Overview of forecasting models
### SARIMA
 A simple ARIMA model with seasonality

 **Sumbitting to**: COVID19 hub

### ARI2MA
An ARIMA model with seasonality and with sqrt transformed data

**Sumbitting to**: RespiCast - ARI

### FluForARIMA
A simple ARIMA model with seasonality. 

**Sumbitting to**: RespiCast - ILI

### SOCA Simplex
Using historical data patterns with highest similarity to current data to foreast the future values

**Sumbitting to**: RespiCast - ILI, RespiCast - ARI, COVID19 hub

## European modelling hubs - status and links
- Respicast - ILI ([Forecasts](https://respicast.ecdc.europa.eu/forecasts/?disease=1) - [Submissions](https://github.com/european-modelling-hubs/flu-forecast-hub)) - Season over

- Respicast - ARI ([Forecasts](https://respicast.ecdc.europa.eu/forecasts/?disease=2) - [Submissions](https://github.com/european-modelling-hubs/ari-forecast-hub)) - Season over

- COVID-19 hub ([Forecasts](https://covid19forecasthub.eu/visualisation.html) - [Submissions](https://github.com/european-modelling-hubs/covid19-forecast-hub-europe)) - active