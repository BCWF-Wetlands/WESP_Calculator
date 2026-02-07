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

#Generic script for reading in unprocessed wesp data
###########
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
#Set the EcoProvince name.
EcoP<-'SI'
#Single or Reference site
#enter the layer name desired at the prompt
#Set the Survey 123 file name, it needs to be in the 'data' directory
# the survey 123 file can be a single site or reference sites
file_123in<-readline(prompt='Survey 123 file location and name (without extension) e.g. ./data/field_survey123_edited_04.14.2025: ')
file_123<-paste0(file_123in,'.xls')
#file_123<-'combinedfield_survey123_01.09.2026.xls'
Office_file_loc_in<-readline(prompt='Office question file location and name (without extension) e.g. ../WESP_OF/out/data/GD_Base/OF_Answers.data:  ')
Office_file_loc<-paste0(Office_file_loc_in,'.xlsx')

###########
#Set up directory structure - different directory for single or reference
DataDir <- file.path('data')
dataOutDir <- ifelse(SiteType=='Single',file.path(OutDir,'data',paste0(EcoP,'_BaseSingle')),dataOutDir <- file.path(OutDir,'data',paste0(EcoP,'_BaseRef')))
dir.create(file.path(dataOutDir), showWarnings = FALSE)
#Set Date
DateTimeStamp <- format(Sys.time(), format="%d_%B_%Y_%H_%M")

field_data<-file_123
#field_check<-read_xls(field_data) %>% dplyr::filter(region=='SI')
office_data<-Office_file_loc
#office_check<-read_xlsx(office_data)

#This fails...
ww <- combine_rawdata(
  field_data <-  field_data ,
  office_data <- office_data,
  EcoP = EcoP,
  write_subfiles = TRUE, #field and stressor
  out_dir <- dataOutDir,
  overwrite = TRUE
)

write.csv(ww, fs::path(paste0(dataOutDir,"/",EcoP,"_wetFlat_",DateTimeStamp,".csv")), row.names=FALSE)
#indata <- fs::path("out/data/wetFlat_20250428.csv")


indataC<-read_csv(file.path(dataOutDir,'wesp.csv'))
indata <- fs::path("out/data/SI_BaseRef/wesp.csv")
check_indata(indata)

wesp_file <- system.file("/Users/dmorgan/Sync/_dev/Water/WESP_Calculator/out/data/SI_BaseRef/wesp.csv", package = "wespr")

wesp_file <- system.file("input_data/reference_multisite.csv", package = "wespr")


wesp_file <- "/Users/dmorgan/Sync/_dev/Water/WESP_Calculator/data/Example/reference_multisite.csv"
wesp_dataT <- load_wesp_data(wesp_file)
siteT <- as.wesp_site(wesp_dataT)

wesp_file <- "/Users/dmorgan/Sync/_dev/Water/WESP_Calculator/out/data/SI_BaseRef/wesp.csv"
wesp_data <- load_wesp_data(wesp_file)
site <- as.wesp_site(wesp_data)


#siteCheck <- wespr::as.wesp_site(wesp_data, site = 1)

site <- as.wesp_site(wesp_data)
calc_indicators(site)
calculate_multi_site(wesp_data)

calculate_jenks_score(wesp_data, out_dir = dataOutDir,  out_name = paste0(EcoP,'_',DateTimeStamp,"_wesp_scores.csv"))
