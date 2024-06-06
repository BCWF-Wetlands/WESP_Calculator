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

file_123<-'WESP_22_23_Reordered Survey123 (03.19)_rowFix.xlsx'
WetPlotFnDataIn<-read_xlsx(file.path(DataDir,file_123),sheet=2,
                           col_names=TRUE, col_types=c('text')) %>%
  dplyr::filter(region==EcoP) %>%
  dplyr::rename(Wetland_Co=Wetland_ID)

SWetList<-c(paste0('X',(1:(nrow(WetPlotFnDataIn)))))

WriteXLS(WetPlotFnDataIn,file.path(dataOutDir,paste('wesp_FormIn.xlsx',sep='')),
         row.names=FALSE,col.names=TRUE,AllText=TRUE)

#Data Check
#Check fo repeat entries for same site
Duplicate_Wetland_Co<-data.frame(Duplicates=WetPlotFnDataIn[duplicated(WetPlotFnDataIn$Wetland_Co),]$Wetland_Co)

#Missing fields check
WetPlotFnDataIn_F_S<-WetPlotFnDataIn %>%
  dplyr::select(Wetland_Co,starts_with(c('F','S'))) %>%
  dplyr::select(-c('F46_a','F46_b','FID','surveyors',"Sec_Lnd_CO","Sec_Dist","SAR observed"))

nQuestions<-ncol(WetPlotFnDataIn_F_S)-1

MissingL<-lapply(2:(ncol(WetPlotFnDataIn_F_S)-1), function(y) {
  #Index through questions and identify those that are blank or NA
  df<-is.na(WetPlotFnDataIn_F_S[y])
  return(df)
  })
MissingLL.1 <- as.data.frame(do.call(cbind, MissingL))

#Clean up the file for export
MissingLL<-cbind(data.frame(Wetland_Co=WetPlotFnDataIn_F_S$Wetland_Co),MissingLL.1) %>%
  mutate(across(.fns = ~replace(., . ==  'TRUE' , 'missing'))) %>%
  mutate(across(.fns = ~replace(., . ==  'FALSE' , ' ')))

miss_duplicate<-list(Duplicate_Wetland_Co,MissingLL)
WriteXLS(miss_duplicate,file.path(dataOutDir,paste('wesp_miss_duplicate.xlsx',sep='')),
         row.names=FALSE,col.names=TRUE,AllText=TRUE,
         SheetNames=c('Duplicates','Missing Entry'))
