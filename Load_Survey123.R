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

#Read the Survey 123 file from the data directory
WetPlotFnDataIn<-read_excel(file.path(DataDir,BCWFfile),
                            col_names=TRUE, col_types=c('text')) %>%
  dplyr::filter(Region==EcoP) %>%
  dplyr::select(-c(ObjectID,GlobalID,Region,Date,DateIn,Investigators,
                   CreationDate,Creator,EditDate,Editor,x,y))

#Data Check
InCheck<-WetPlotFnDataIn %>%
  dplyr::select(Wetland_Co,
                starts_with('S')) %>%
  dplyr::filter(Wetland_Co=='ESI-8804')

WriteXLS(WetPlotFnDataIn,file.path(dataOutDir,paste('WFormIn.xlsx',sep='')),
         row.names=FALSE,col.names=TRUE,AllText=TRUE)

#List of sites for indexing in clean scripts
SWetList<-c(paste0('X',(1:(nrow(WetPlotFnDataIn)))))

