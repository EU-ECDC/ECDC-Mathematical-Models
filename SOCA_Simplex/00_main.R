# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
### MAIN script for the SOCA simplex method ########
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Function implementing the SOCA (Similarity-based One-Step-ahead Component Analysis) Simplex method for epidemiological projections. 
# This method utilizes historical data patterns with the highest similarity to current data to forecast future values of COVID-19 cases, hospitalizations, deaths, or ILI/ARI consultation rates. The method follows a series of steps including selecting recent data points, finding closest neighbors, fitting a log-normal distribution, and estimating quantiles/distribution for forecasting. 
# The 00_main.R function (i) loads the libraries and other required functions, and (ii) runs the model + saves the outputs
# The sub-functions used are:
# - run_soca_simplex_model.R which (i) loads and cleans the data for the relevant indicators, (ii) defines defines the relevant parameters, and (iii) calls the run_X.R function
# - run_ILI_ARI.R and run_COVID_targets.R which (i) run the simplex_compute.R function which outputs the forecasts, (ii) find optimal parameters from the past 4 weeks, (iii) prepares the forecast data structure for submission, and (iv) save .csv and .jpg figures with the forecasts
# - simplex_compute.R which actually estimates the forecasts by using the method described in the README file of the sub-repository

# February 2024, Author: Rok Grah, ECDC Mathematical Modelling Team

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
### Libraries and aux functions ########
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Load standard ECDC used packages and libraries
library(fitdistrplus)
library(devtools)
SourceURL <- "https://raw.githubusercontent.com/european-modelling-hubs/modelling_setup/main/setup.R"
source_url(SourceURL)
#source("../../../modelling_setup/setup.R")

# Load other support packages
library(scoringutils)
library(hubVis)
library(data.table)

# Source relevant functions
source("run_ILI_ARI.R")
source("run_COVID_targets.R")
source("estimate_simplex_WIS.R")
source("simplex_compute.R")
source("function_run_soca_simplex_model.R")

# Function that returns values from a that are not in b - used in for variable 'missing_countries' in run_ILI_ARI.R and run_COVID_targets.R
relcomp <- function(a, b) {
  
  comp <- vector()
  
  for (i in a) {
    if (i %in% a && !(i %in% b)) {
      comp <- append(comp, i)
    }
  }
  
  return(comp)
}


# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
### Define the relevant parameter ########
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

current_date = ymd("2024-03-25")


# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
### Run the SOCA Simplex method ########
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

run_soca_simplex_model(current_date)


# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
### Script finished ########
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
message("The simplex method script has finished")


