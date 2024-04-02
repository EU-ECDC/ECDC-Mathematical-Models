# Function to (i) load the libraries and other required functions, and (ii) runs the model + saves the outputs

# useful stuff

# print like this
if (F) pr=paste("Warning: Check day diffs for:",country_i,"\n"); cat(red(pr))


# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
### Libraries and aux functions ########
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

library(devtools)
SourceURL <- "https://raw.githubusercontent.com/european-modelling-hubs/modelling_setup/main/setup.R"
source_url(SourceURL)
# load additional libraries beyond core ones from setup
library(fitdistrplus)
#source("../../../modelling_setup/setup.R")
library(scoringutils)
library(hubVis)
library(data.table)

source("run_ILI_ARI.R")
source("run_COVID_targets.R")
source("estimate_simplex_WIS.R")
source("simplex_compute.R")

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

# source model specific functions
source("function_run_ARI2MA_model.R")
source("function_run_FluForARIMA_model.R")
source("function_run_soca_simplex_model.R")
source("function_run_norrsken_blue_model.R")
source("function_run_norrsken_green_model.R")

current_date = ymd("2024-04-01") # must be a Monday!

# run the models
run_ARI2MA_model(current_date, 
                       run_ILI = T,
                       run_ARI = T,
                       run_COVID_cases = T,
                       run_COVID_hosps = T,
                       run_COVID_deaths = T)
run_FluForARIMA_model(current_date, 
                       run_ILI = T,
                       run_ARI = T,
                       run_COVID_cases = T,
                       run_COVID_hosps = T,
                       run_COVID_deaths = T)
run_soca_simplex_model(current_date, 
                       run_ILI = T,
                       run_ARI = T,
                       run_COVID_cases = T,
                       run_COVID_hosps = T,
                       run_COVID_deaths = T)
run_soca_norrsken_blue_model(current_date, 
                       run_ILI = T,
                       run_ARI = T,
                       run_COVID_cases = T,
                       run_COVID_hosps = T,
                       run_COVID_deaths = T)
run_soca_norrsken_green_model(current_date, 
                       run_ILI = T,
                       run_ARI = T,
                       run_COVID_cases = T,
                       run_COVID_hosps = T,
                       run_COVID_deaths = T)
