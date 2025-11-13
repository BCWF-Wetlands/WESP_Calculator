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

#Read sampling spreadsheet sheets
WetPlotFnSheets<- excel_sheets(file.path(DataDir,paste0(BatchCalcFile)))

#Define sheets to read
WESPinSheets<-c('F','OF','S')
BWetList<-(1:numSites)

#Read in the Batch Calculator sheets
WESPin<-lapply(1:3, function(x) {
  dfin<-read_excel(file.path(DataDir,paste0(BatchCalcFile)),
             sheet = WESPinSheets[x],
             col_names=TRUE, col_types=c('text'))
  #Drop un-needed columns
  df<-dfin %>%
    dplyr::select(!any_of(c('Indicator','Description','Condition Choices','Severe','Medium','Mild')))
  #drop the calculating column - it's a repeat of a column held in data
  #df<-df[-2]
  #Rename the columns so they have clean 1:100 names
  colnames(df)<-c(paste0(WESPinSheets[x],'_Question'),1:100)
  return(df)
})

#Read in Paul's Wetland_Co look up table so can assign consistent IDs
#This is needed to combine 2020 and 2021 survey 123 data
SiteID_xtab<-read_excel(file.path(DataDir,'SiteID_xtab_2023.xlsx'),
                        skip=1,
                        col_names=c('Batch_ID','Wetland_Co'))
#If need to add sites
#Batch_ID_max<-max(SiteID_xtab$Batch_ID)wetName<-WetPlotFnSheets$Wetland_Co

wetNameBF<-SiteID_xtab$Wetland_Co
#Clean up Batch Calculator Data sheets so reduced to question and data
WESPclean<-lapply(1:3, function(x) {
  cnames<-c(paste0(WESPinSheets[x],"_Question"),as.character(c(paste0((1:(numSites))))))
  Question<-paste0(WESPinSheets[x],"_Question")
  df<-as.data.frame(WESPin[[x]]) %>% dplyr::select(all_of(cnames)) %>%
  dplyr::filter(!(str_detect(!!sym(Question), "^Drop"))) #drop the 'Drop#' columns
  return(df)
})

#List of sites for indexing in clean scripts
#BWetList<-c(paste0('X',(1:(ncol(WESPclean[[1]])-1))))
