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
figsOutDir <- file.path(OutDir,'figures')
SpatialDir <- file.path('data','spatial')
DataDir <- file.path('data')
spatialOutDir <- file.path(OutDir,'spatial')

SyncDir <- file.path('/Users/darkbabine/Sync')
dir.create(file.path(OutDir), showWarnings = FALSE)
dir.create(file.path(dataOutDir), showWarnings = FALSE)
dir.create(file.path(spatialOutDir), showWarnings = FALSE)
dir.create(DataDir, showWarnings = FALSE)
dir.create("tmp", showWarnings = FALSE)


