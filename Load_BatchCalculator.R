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
BatchCalcFile<-'BC_BatchCalculator_Skeena_18Jy2023_ModelsRevised_30Aug2023update_26Sept2023.xlsm'
WetPlotFnSheets<- excel_sheets(file.path(DataDir,paste0(BatchCalcFile)))
#Define sheets to read
WESPinSheets<-c('F','OF','S')
#Read in the Batch Calculator sheets
WESPin<-lapply(1:3, function(x) {
  read_excel(file.path(DataDir,paste0(BatchCalcFile)),
             sheet = WESPinSheets[x],
             col_names=TRUE, col_types=c('text'))
})

#Clean up Batch Calculator Data sheets so reduced to question and data
WESPclean<-lapply(1:3, function(x) {
  cnames<-c(paste0(WESPinSheets[x],"_Question"),c(paste0('X',(1:(nSites)))))
  as.data.frame(WESPin[x]) %>% dplyr::select(cnames)
})

#List of sites for indexing in clean scripts
WetList<-c(paste0('X',(1:(ncol(WESPclean[[1]])-1))))


