library(sf)
library(dplyr)
library(readr)
library(tidyr)
library(WriteXLS)
library(readxl)
library(stringr)
library(gtools)
library(tidyverse)


OutDir <- 'out'
dataOutDir <- file.path(OutDir,'data')
DataDir <- file.path('data')

wesprDir <- file.path('/Users/dmorgan/Sync/_dev/Water/WESP_Calculator/data')
dir.create(file.path(OutDir), showWarnings = FALSE)
dir.create(file.path(dataOutDir), showWarnings = FALSE)
dir.create(DataDir, showWarnings = FALSE)
dir.create("tmp", showWarnings = FALSE)


