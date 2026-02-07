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

#file_123<-'WESP_22_23_Reordered Survey123 (03.19)_rowFix-3.xlsx'
#file_123<-'fix1_S123_acd367755e4e416babe7e5cb6af9e5b3_gdb_tocsv.xls'
sheet_pos<-1
cTypes<-c(rep("text",2),'date',rep('text',108))
cTypes<-c('date',rep('text',108))

WetPlotFnDataIn<-read_xls(file.path(DataDir,file_123),sheet=sheet_pos,
                          col_names=TRUE, col_types=cTypes, range=cell_cols("C:DG")) %>%
  dplyr::filter(region==EcoP) %>%
  mutate(date=format(as.POSIXct(datetime,format='%m/%d/%Y %H:%M:%S'),format='%m/%d/%Y')) %>%
  dplyr::rename(Wetland_Co=Wetland_ID) %>%
  mutate(across(where(is.character), ~str_trim(.))) %>%
  #mutate_all(na_if,"")
  #mutate_if(is.character, ~ifelse("",NA,.))
  mutate(across(where(is.character), ~na_if(., "")))


SWetList<-c(paste0('X',(1:(nrow(WetPlotFnDataIn)))))

WriteXLS(WetPlotFnDataIn,file.path(dataOutDir,paste('wesp_FormIn.xlsx',sep='')),
         row.names=FALSE,col.names=TRUE,AllText=TRUE)

#Data Check
#Check fo repeat entries for same site
Duplicate_Wetland_Co<-data.frame(Duplicates=WetPlotFnDataIn[duplicated(WetPlotFnDataIn$Wetland_Co),]$Wetland_Co)

#Missing fields check
WetPlotFnDataIn_F_S<-WetPlotFnDataIn %>%
  dplyr::select(Wetland_Co,starts_with(c('F','S'))) %>%
  #dplyr::select(-c('F46_a','F46_b','FID','surveyors',"Sec_Lnd_CO","Sec_Dist","SAR observed"))
  dplyr::select(-c('surveyors'))

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
