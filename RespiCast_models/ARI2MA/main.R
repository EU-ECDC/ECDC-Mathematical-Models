# ---- 1. set up ----
source("code/01_SetUp.R")
source("code/02_DataPreparation.R")

# ---- 2. models ----
source("code/03_Lydia_ARI2MA.R")

# ---- 3. output ----
source("code/04_OutputCSV.R")
create_output(indicator = cases, monday_date = Sys.Date()-1)
