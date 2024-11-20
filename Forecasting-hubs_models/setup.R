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
library( limSolve ) #for solving constrained linear least squares
library( sparsevar ) #for computing the spectral radius
library( glmc )
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
library( "EcdcColors" )
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

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
### Settings for plotting ##########
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ECDC Font
if ("Tahoma" %in% extrafont::fonts()) {
  FONT <- "Tahoma"
  suppressMessages(extrafont::loadfonts(device = "win"))
} else if (Sys.info()["sysname"] == "Windows") {
  suppressMessages(extrafont::font_import(pattern = 'tahoma', prompt = FALSE))
  suppressMessages(extrafont::loadfonts(device = "win"))
  FONT <- "Tahoma"
} else {
  FONT <- NULL
}

# Theme 
.plottheme <- ggplot2::theme(axis.text = ggplot2::element_text(size = 8, family = FONT),
                             axis.title = ggplot2::element_text(size = 9, family = FONT),
                             axis.line = ggplot2::element_line(colour = "black"),
                             axis.line.x = ggplot2::element_blank(),
                             # --- Setting the background
                             panel.grid.major = ggplot2::element_blank(),
                             panel.grid.minor = ggplot2::element_blank(),
                             panel.background = ggplot2::element_blank(),
                             # --- Setting the legend
                             legend.position = "right",
                             legend.title = ggplot2::element_blank(),
                             legend.text = ggplot2::element_text(size = 8, family = FONT),
                             legend.key.width = ggplot2::unit(0.8, "cm"),
                             legend.key.size = ggplot2::unit(0.4, "cm"))

# overriding function defaults
geom_interval <- function(...) ggdist::geom_interval(...,alpha=0.4)
geom_lineribbon <- function(...) ggdist::geom_lineribbon(...,alpha=0.4)
geom_ribbon <- function(...) ggplot2::geom_ribbon(...,alpha=0.4)
ggplot <- function(...) ggplot2::ggplot(...) + scale_color_brewer(palette="Dark2")
mean_qi <- function(...) ggdist::mean_qi(...,.width=0.80)



# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
### Medium-complex functions ##########
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
countries <- c("Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czechia", 
               "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", 
               "Hungary", "Iceland", "Ireland", "Italy", "Latvia", "Liechtenstein", 
               "Lithuania", "Luxembourg", "Malta", "Netherlands", "Norway", 
               "Poland", "Portugal", "Romania", "Slovakia", "Slovenia", "Spain", 
               "Sweden",
               # non EU/EEA
               "Switzerland","England","Norther Ireland","Scotland")
countries_short <- c("AT", "BE", "BG", "HR", "CY", "CZ", 
                     "DK", "EE", "FI", "FR", "DE", "GR", 
                     "HU", "IS", "IE", "IT", "LV", "LI", 
                     "LT", "LU", "MT", "NL", "NO", 
                     "PL", "PT", "RO", "SK", "SI", "ES", 
                     "SE",
                     # non EU/EEA
                     "CH","GB-ENG","GB-NIR","GB-SCT")


# very end: timing
end_time <- Sys.time()
cat("Run time setup01.R :", round(end_time - start_time,2) , "sec")
