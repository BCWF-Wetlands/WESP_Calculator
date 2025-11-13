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

#Read in loaded Survey 123 data
#WFormS<-read_excel(file.path(dataOutDir,paste('WFormIn.xlsx',sep='')),
WFormS<-read_excel(file.path(dataOutDir,paste('wesp_FormIn.xlsx',sep='')),
                                      col_names=TRUE, col_types=c('text')) %>%
  dplyr::select(Wetland_Co,
                starts_with('S')) %>%
  mutate(across(everything(), as.character)) %>%
  #drop duplicate rows
  distinct(Wetland_Co, .keep_all = TRUE)

WForm_Wetland_Co<-WFormS %>%
  dplyr::select(Wetland_Co)

#Make list of variables that require parsing
#S1 S1_3
ParseVars<-c('S1','S2','S3','S4','S5','S6')
#Number of sub-categories for each variable
#NparseVars<-c(10,5,9,8,8,4)
NparseVars<-c(10,5,9,9,8,4)

#Function to split a Form variable that has multiple entries into
#separate variables
SplitFn1 <- function(i,df) {
  df2<-lapply(1:NparseVars[i], function(j) {
    FormVName<-paste0(ParseVars[i],"_",j)
    df %>%
      mutate(!!FormVName := case_when(
        #is.element(j, VpN) ~ 1,
        is.element(j, VpartsN) ~ 1,
        TRUE ~ 0)) %>%
      dplyr::select(!!rlang::sym(FormVName))
      #dplyr::select(Wetland_Co,!!rlang::sym(FormVName))
  })
  do.call(cbind, df2)
}
#Loop through each Variable to split out and call the function
#that splits it into separate variables
df3<-lapply(1:length(ParseVars), function(x) {
  df1<-WFormS %>%
    rowwise() %>%
    mutate(Vparts=(strsplit(!!rlang::sym(ParseVars[x]), ","))) %>%
    mutate(VpartsN=list(parse_number(Vparts))) %>%
    #dplyr::select(Wetland_Co,(ParseVars[x]),Vparts,VpartsN)
    dplyr::select((ParseVars[x]),Vparts,VpartsN)
  #SplitFn1(x,df1$VpartsN)
  SplitFn1(x,df1)
  #return(df1)
})
#Data Check
df3tt<-df3[[1]]
#df4<-df3 %>%
#  dplyr::select(-c)

#Combine generated form sub-variables with original data.frame
WFormS2.1<-cbind(WForm_Wetland_Co,do.call(cbind, df3))
WFormS2 <- dplyr::mutate(WFormS,WFormS2.1) %>%
  mutate(across(everything(), as.character))

WFormS2Check<-WFormS2 %>%
  dplyr::select(Wetland_Co,c(paste0('S5_',(1:12))))

WFormS2Check<-WFormS2 %>%
  dplyr::select(Wetland_Co,starts_with('S6'))

#Split out form binary variables that are contained in 1 variable
ParseVars<-c('S1_11','S1_12','S1_13','S1_14','S2_6','S2_7','S2_8','S3_10','S3_11','S3_12',
             'S4_10','S4_11','S4_12','S5_9','S5_10','S5_11','S5_12','S6_3','S6_4')

WFormS3<-WFormS2 %>%
  mutate(across(all_of(ParseVars), parse_number)) %>%
  mutate(across(everything(), as.character)) %>%
  dplyr::select(Wetland_Co,
                starts_with('S1_'),starts_with('S2_'),
                starts_with('S3_'),starts_with('S4_'),
                starts_with('S5_'),starts_with('S6_')) %>%
  mutate(S1_15=0) %>%
  mutate(S1_16=0) %>%
  mutate(S2_8=0) %>%
  mutate(S2_9=0) %>%
  mutate(S2_10=0) %>%
  mutate(S3_13=0) %>%
  mutate(S3_14=0) %>%
  mutate(S4_13=0) %>%
  mutate(S4_14=0) %>%
  mutate(S5_13=0) %>%
  mutate(S5_14=0) %>%
  mutate(S6_5=0) %>%
  mutate(S6_6=0)
WFormS3[is.na(WFormS3)] <- '0'

StressCols<-colnames(WFormS3)

WFormS3Check<-WFormS3 %>%
  dplyr::select(Wetland_Co,c(paste0('S5_',(1:12))))

WriteXLS(WFormS3,file.path(dataOutDir,paste('clean_S.xlsx',sep='')),
         row.names=FALSE,col.names=TRUE,AllText=TRUE)

