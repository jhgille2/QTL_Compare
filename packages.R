# Install pacman if it does not already exist
if(!require(pacman)){
  install.packages(pacman)
}

# Use pacman to load/install packages
pacman::p_load(conflicted, 
               dotenv, 
               targets, 
               tarchetypes, 
               tidyverse, 
               rvest, 
               rmarkdown, 
               Hmisc, 
               pbapply, 
               here, 
               readxl)

# Conflict preferences
conflict_prefer("filter", "dplyr")