# Function to (i) load the libraries and other required functions, and (ii) runs the model + saves the outputs
# --warning-- Currently, this script does not yet work (paths need to be updated)

# useful stuff

# print like this
if (F) {pr=paste("Warning: Check day diffs for:",country_i,"\n"); cat(red(pr))}


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

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
### Settings  ########
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

current_date = ymd("2024-04-29") # must be a Monday!

# indicators to run
run_ILI = F # RespiCast season over
run_ARI = F # RespiCast season over
run_COVID_cases = T
run_COVID_hosps = T
run_COVID_deaths = T



# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
### Source & run the models  ########
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
## SOCA Simplex
source("models/SOCA_Simplex/function_run_soca_simplex_model.R")
run_soca_simplex_model(current_date, 
                       run_ILI = run_ILI,
                       run_ARI = run_ARI,
                       run_COVID_cases = run_COVID_cases,
                       run_COVID_hosps = run_COVID_hosps,
                       run_COVID_deaths = run_COVID_deaths)

# # ARIMA models
# source("models/ARI2MA/function_run_ARI2MA_model.R")
# run_ARI2MA_model(current_date, 
#                  run_ILI = run_ILI,
#                  run_ARI = run_ARI,
#                  run_COVID_cases = run_COVID_cases,
#                  run_COVID_hosps = run_COVID_hosps,
#                  run_COVID_deaths = run_COVID_deaths)

# source("models/FluForARIMA/function_run_FluForARIMA_model.R")
# run_FluForARIMA_model(current_date, 
#                  run_ILI = run_ILI,
#                  run_ARI = run_ARI,
#                  run_COVID_cases = run_COVID_cases,
#                  run_COVID_hosps = run_COVID_hosps,
#                  run_COVID_deaths = run_COVID_deaths)

#source("models/Lydia-SARIMA/function_run_LydiaSARIMA.R")
# run_LydiaSARIMA_model(current_date, 
#                  run_ILI = run_ILI,
#                  run_ARI = run_ARI,
#                  run_COVID_cases = run_COVID_cases,
#                  run_COVID_hosps = run_COVID_hosps,
#                  run_COVID_deaths = run_COVID_deaths)
#norrsken models
#source("function_run_norrsken_blue_model.R")
# run_norrsken_blue_model(current_date, 
#                  run_ILI = run_ILI,
#                  run_ARI = run_ARI,
#                  run_COVID_cases = run_COVID_cases,
#                  run_COVID_hosps = run_COVID_hosps,
#                  run_COVID_deaths = run_COVID_deaths)
# source("function_run_norrsken_green_model.R")
# run_norrsken_green_model(current_date, 
#                  run_ILI = run_ILI,
#                  run_ARI = run_ARI,
#                  run_COVID_cases = run_COVID_cases,
#                  run_COVID_hosps = run_COVID_hosps,
#                  run_COVID_deaths = run_COVID_deaths)




