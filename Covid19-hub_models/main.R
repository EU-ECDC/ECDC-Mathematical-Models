# ---- 1. set up ----
source("code/01_SetUp.R")
source("code/02_DataPreparation.R")

# ---- 2. models ----
source("code/03a_SARIMAcases.R")
source("code/03b_SARIMAdeaths.R")
source("code/03c_SARIMAhosps.R")

# ---- 3. output ----
source("code/05_FinalOutputCSV.R")
final_output(Sys.Date())
