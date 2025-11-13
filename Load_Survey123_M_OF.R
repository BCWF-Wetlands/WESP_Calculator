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


file_123<-'ManualOF_GD (Form_1_0).xls'
sheet_pos<-1
cTypes<-c(rep("text",2),'date',rep('text',117))
cTypes<-c("text")

WetPlotMOFDataIn<-read_xls(file.path(DataDir,file_123),sheet=sheet_pos,
                           col_names=TRUE, col_types=cTypes) %>%
  dplyr::rename(WTLND_ID=Wtlnd_C)

WriteXLS(WetPlotMOFDataIn,file.path(dataOutDir,paste('WetPlotMOFDataIn.xlsx',sep='')),
         row.names=FALSE,col.names=TRUE,AllText=TRUE)
