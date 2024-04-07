# SOCA Simplex Method for Epidemiological Projections

## Description
The SOCA (Similarity-based One-Step-ahead Component Analysis) Simplex method is used for projections of epidemiological targets such as COVID-19 cases, hospitalizations, or deaths, or ILI/ARI consultation rates.  However, the method but can be extended to basically any other disease indicator as the model is disease agnostic.

The method uses historical data patterns with the highest similarity to current data to forecast future values.
The functions within this 'sub-repository' are utilized for submitting forecasts for the European Respiratory Forecast Hub (RespiCast) - the main output of the package are the .csv files of the forecasts in the appropriate file structure for the Forecast Hub submission. 
The relevant 'RespiCast' repositories are: [ARI Forecast Hub](https://github.com/european-modelling-hubs/ari-forecast-hub), [ILI Forecast Hub](https://github.com/european-modelling-hubs/flu-forecast-hub), [COVID-19 Forecast Hub](https://github.com/european-modelling-hubs/covid19-forecast-hub-europe)

## Method Overview
The SOCA Simplex method follows these steps:
1. Takes 'm' latest data points.
2. Finds 'n' closest neighbors from all historical data using L2-norm.
3. Uses the next data time point from each historical data point.
4. Fits a log-normal distribution using data from step 3.
5. Uses the log-normal distribution to estimate the quantiles/distribution.
6. Iterates steps 3-5 using two data points ahead for estimations of horizon 2, three data points ahead for horizons 3, etc.
7. Finds optimal values of 'n' and 'm' for a given country, using past 4 weeks of forecasts.

## Requirements
- Standard ECDC modelling team packages found on their repository (https://github.com/european-modelling-hubs/modelling_setup/tree/main)
- 'Scoringutils' and 'hubVis' packages

## Usage
Within the `00_main.R` script, define the variable `current_date` which date of when forecasts are performed. Then run the `00_main.R` script. Of note:
1. Call to the `00_main.R` script loads the required libraries, auxiliary functions, and defines the date of when forecasts are performed.
2. The `00_main.R` script calls the `run_soca_simplex_model.R` script which in turn runs the SOCA Simplex method separately for ILI/ARI indicators (run_ILI_ARI.R) and for COVID-19 indicators (run_COVID_targets.R). This is due to different output structure requirements.
3. The actual SOCA simplex method to estimate forecasts is run within the `simplex_compute.R` function.
4. The output file structure is following the RespiCast requirements: [ARI Forecast Hub submission format](https://github.com/european-modelling-hubs/ari-forecast-hub/wiki/Submission-format), [ILI Forecast Hub submission format](https://github.com/european-modelling-hubs/flu-forecast-hub/wiki/Submission-format), [COVID-19 Forecast Hub submission format](https://github.com/european-modelling-hubs/covid19-forecast-hub-europe/wiki/Submission-format)

## Output
After the code has executed, the resulting 4-week forecasts for all indicators are found in their corresponding folders. Additionally, figures showing the forecasts are stored in the 'figures' folder. These figures allow for visual inspection of the forecasting to quickly identify any outliers and strange forecasts.

