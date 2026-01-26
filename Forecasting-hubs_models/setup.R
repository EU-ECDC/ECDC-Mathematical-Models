# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
### Big section: Higher level ##########
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# ---- |-Subsection: More details ----


# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
### Load libraries ##########
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# rules applied: stick to the essential set of packages (to reduce dependencies and avoid masking issues)
# additional special-purpose libraries should be loaded in the script that uses them
start_time <- Sys.time()
library(devtools) # since this is needed to source this script remotely, needs to check masking behaviour
library( caTools ) #for the function runmean
#library( limSolve ) #for solving constrained linear least squares
#library( sparsevar ) #for computing the spectral radius
#library( glmc )
library( mgcv) # for splines
library( forecast ) # forecast
library(gamlss)
library( pracma )
library(magrittr) # better pipes
library(tidyverse) 
library(scales)
library(ggpubr)
library(lubridate)
library(fitdistrplus)
library(readxl)
library(purrr)
library(tidybayes)
library(bayesplot)
library(patchwork) # nice multi-facet plotting
library(viridis)
library(wrapr) # in wavefeature #
library(summarytools)
library(zoo)
library(here)
library(dagitty)
library(ISOweek)
library(fst) # fast loading and writing of.fst files
library(tictoc)
library( scoringutils )
library(crayon) # coloured output of messages
library(Hmisc) # very useful describe funcion
# remasking
select <- dplyr::select
filter <- dplyr::filter
mutate <- dplyr::mutate
date <- lubridate::date
intersect <- base::intersect
setdiff <- base::setdiff
union <- base::union
expand <- tidyr::expand
map <- purrr::map
discard <- purrr::discard
col_factor <- readr::col_factor
combine <- gridExtra::combine
area <- patchwork::area
#view <- summarytools::view
# keeping only select functions from tidy_log 

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
### Other Options ##########
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Reset R's most annoying default options
options(stringsAsFactors = FALSE, 
        scipen = 999, 
        dplyr.summarise.inform = FALSE,
        tibble.print_min=4)


# very end: timing
end_time <- Sys.time()
cat("Run time setup01.R :", round(end_time - start_time,2) , "sec")
