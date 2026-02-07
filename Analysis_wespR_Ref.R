# Copyright 2020 Province of British Columbia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

#Prepare for and install wespr
Sys.unsetenv("GITHUB_PAT")
#library(devtools)
#install.packages("devtools")
#devtools::install_github("BCWF-Wetlands/wespr", force=TRUE)
#find.package(wespr, lib.loc, quiet = TRUE)
#Read Packages
library(wespr)
library(stringr)
library(dplyr)
library(readr)

#Set up the environment for processing the field and office files
SiteType<-'Ref'
EcoP<-'SI' #Set the EcoProvince name.

###########
#Set up directory structure - different directory for single or reference
DataDir <- file.path('data')
dataOutDir <- file.path(OutDir,'data',paste0(EcoP,'_BaseRef'))
dir.create(file.path(dataOutDir), showWarnings = FALSE)
DateTimeStamp <- format(Sys.time(), format="%d_%B_%Y_%H_%M") #Set Date

#wesp data from 'Clean_Collate_F_S_OF.R'
wesp_file <- "/Users/dmorgan/Sync/_dev/Water/WESP_Calculator/out/data/SI_BaseRef/wesp_F_S.csv"
wesp_data <- load_wesp_data(wesp_file)
site <- as.wesp_site(wesp_data)
site <- as.wesp_site(wesp_data)
calc_indicators(site)
calculate_multi_site(wesp_data)
calculate_jenks_score(wesp_data, out_dir = dataOutDir,  out_name = paste0(EcoP,'_',DateTimeStamp,"_wesp_scores.csv"))
