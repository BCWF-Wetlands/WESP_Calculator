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
WForm<-read_excel(file.path(dataOutDir,paste('wesp_FormIn.xlsx',sep='')),
                    col_names=TRUE, col_types=c('text')) %>%
                    dplyr::select(Wetland_Co,starts_with('F')) %>%
                    mutate(across(everything(), as.character)) %>%
  #drop duplicate rows
  distinct(Wetland_Co, .keep_all = TRUE)

WForm_Wetland_Co<-WForm %>%
  dplyr::select(Wetland_Co)
#Re-format the Survey123 data

# Except where noted all 0/NA default to lowest case eg VegArea1
#F2_0 NA
#F3_0 NA
#F22_1 No
#F23_1 No
#F27_0 - Ponded6 - F27_6
#F33_0 - WaterUpland6 - F33_6
#F35_0 - InundatedVeg4 - F35_4
#F38_0 - SubmergeAquatic3 - F38_3
#F39_0 - Colour4 - F39_4
#F40_0 - Channel5 - F40_5
#F41_0 - OutflowDrain4 - F40_4
#F42_1 - No
#F43_0 - NA
#F45_0 - ph_Measure3 - F45_3
#F45_1 - NA
#F46_1 - NA
#F46_2 - 0
#F47_0 - GroundInput3 - F47_3
#F48_0 - Beaver3 - F48_3
#F49_1 - No
#F50, F51 and F52 - NA
#F53_0 - DistanceAcross6 - F53_6
#F54_0 - WellProx6 - F54_6
#F55_0 - BurnHistory7 - F55_7
#F56,57,59 - NA
#F58 - SpeciesPres11 and SpeciesPres8=SpeciesPres8, but if blank then NA


#Case 1
# Split F2 into c(F2_A1, F2_A2, F2_B1, F2_B2)
WForm1 <- WForm %>% mutate(
  F2_A1 := case_when(
    F2_0=="A1" ~ 1,
    TRUE ~ 0),
  F2_A2 := case_when(
    F2_0=="A2" ~ 1,
    TRUE ~ 0),
  F2_B1 := case_when(
    F2_0=="B1" ~ 1,
    TRUE ~ 0),
  F2_B2 := case_when(
    #F2_0=="B2" | (F2_A1==0 & F2_A2==0 & F2_B1==0) ~ 1,
    F2_0=="B2" ~ 1,
    TRUE ~ 0)
) #%>%
  #dplyr::select(!(F2_0))
WForm1.check<-WForm1 %>%
  dplyr::select(Wetland_Co,c(F2_0,F2_A1, F2_A2, F2_B1, F2_B2))


#Case 2
# Make list of variables that require parsing
ParseVars<-c('F3_0','F56_0','F57_0','F58_0')
#Number of sub-categories for each variable
NparseVars<-c(8,3,7,11)

#Function to split a Form variable that has multiple entries into
#separate variables
SplitFn1 <- function(i,df) {
  df2<-lapply(1:NparseVars[i], function(j) {
    #FormVName<-paste0(ParseVars[i],"_",j)
    FormVName<-sub('_0',paste0('_',j),ParseVars[i])
    df %>%
      mutate(!!FormVName := case_when(
        #is.element(j, VpN) ~ 1,
        is.element(j, VpartsN) ~ 1,
        TRUE ~ 0)) %>%
      dplyr::select(!!rlang::sym(FormVName))
  })
  do.call(cbind, df2)
}
#Loop through each Variable to split out and call the function
#that splits it into separate variables
df3<-lapply(1:length(ParseVars), function(x) {
  df1<-WForm1 %>%
    rowwise() %>%
    mutate(Vparts=(strsplit(!!rlang::sym(ParseVars[x]), ","))) %>%
    mutate(VpartsN=list(parse_number(Vparts))) %>%
    dplyr::select((ParseVars[x]),Vparts,VpartsN)
  #SplitFn1(x,df1$VpartsN)
  SplitFn1(x,df1)
})
#Combine generated form sub-variables with original data.frame
WForm2 <- cbind(WForm1,(do.call(cbind, df3))) %>%
  replace(is.na(.),0) %>%
 mutate_all(funs(str_replace(.,'N/A','0')))

#WForm2<-do.call(cbind, df3)
#Check parsing
WForm2Check<-WForm2 %>%
  dplyr::select(F3_0, c(paste0('F3_',(1:8))))

#Case 3
# Split out form binary variables that are contained in 1 variable
ParseVars<-c('F4_0','F5_0','F6_0','F7_0','F8_0','F9_0','F10_0','F11_0','F12_0','F13_0',
             'F14_0','F15_0','F16_0','F17_0','F18_0','F19_0','F20_0','F21_0','F24_0','F25_0',
             'F26_0','F27_0','F28_0','F29_0','F30_0','F31_0','F32_0','F33_0','F34_0','F35_0',
             'F36_0','F37_0','F38_0','F39_0','F40_0','F41_0', 'F43_0','F44_0','F45_0','F47_0','F48_0',
             'F50_0','F51_0','F52_0','F53_0','F54_0','F55_0','F59_0')
#Number of sub-categories for each variable
NparseVars<-c(3,5,5,5,3,4,5,5,4,5,
              5,5,5,5,3,6,5,6,5,5,
              5,6,3,6,6,6,6,6,6,4,
              5,6,3,4,5,4,5,4,3,3,3,
              5,3,4,6,6,7,5)

df4<-lapply(1:length(ParseVars), function(x) {
  df1<-WForm2 %>%
    rowwise() %>%
    mutate(VpartsN=parse_number(!!rlang::sym(ParseVars[x]))) %>%
    #mutate(VpartsN=parse_number(ParseVars[x])) %>%
    dplyr::select(ParseVars[x],VpartsN)
  SplitFn1(x,df1)
})
WForm3.1<-cbind(WForm_Wetland_Co,do.call(cbind, df4))
WForm3 <- dplyr::mutate(WForm2,WForm3.1)

WForm3Check<-WForm3 %>%
  dplyr::select(Wetland_Co,F22_1,F23_1,F42_1,F49_1,F4_0, c(paste0('F4_',(1:3))))
  #dplyr::select(Wetland_Co,F41_0, c(paste0('F41_',(1:4))))
#dplyr::select(Wetland_Co,F4_0, c(paste0('F4_',(1:3))))

#Case 4
# Modify y/n to 1/0 and set
WForm4.1<-WForm3 %>%
  mutate(across(c(F22_1,F23_1,F42_1,F49_1), ~ case_when(. == "yes" ~ "1", TRUE ~ "0"))) %>%
  #mutate(F23_1 = F23_0) %>%
  #mutate(F42_1 = F42_0) %>%
  #mutate(F59_1 = F59_0) %>%
  mutate(F2_A0=0) %>%
  mutate(F2_B0=0) %>%
  dplyr::select(-c('FID','F46_a','F46_b')) %>%
  #drop columns to make wespR work - new entry
  dplyr::select(-c('F58_11')) #%>%
  #mutate(F51_3=if_else(F51_0==0,1,F51_3)) %>%
  #mutate(F4_1=if_else((F4_1==0 & F4_2==0 & F4_3==0),1,F4_1)) %>%
  #mutate(F15_1=if_else((F15_1==0 & F15_2==0 & F15_3==0 & F15_4==0 & F15_5==0),1,F15_1)) %>%
  #mutate(F17_1=if_else((F17_1==0 & F17_2==0 & F17_3==0 & F17_4==0 & F17_5==0),1,F17_1))
#mutate(F27_6=if_else((c(paste0('F27_',(1:6)))==0),1,F27_6)) # 6 subcases

WForm4Check<-WForm4.1 %>%
  dplyr::select(Wetland_Co,F22_1,F23_1,F42_1,F49_1,F4_0, c(paste0('F4_',(1:3))),F17_0,, c(paste0('F17_',(1:5))))

#Special default cases, default to a specific (not 1) case
specialCaseMissing<-c('F27','F33','F35','F38','F39','F40','F53','F55')
specialCaseMissingValues<-c(6,6,4,3,4,5,6,7)

#Fill in default or 0 cases - survey 123 data passing 0 instead of populated field
caseMissing<-c('F12','F13','F16','F18','F20','F21','F24','F25','F26','F28','F29','F30','F31','F32','F34',
               'F36','F37','F44','F41','F43','F50','F52','F59')
caseMissingValues<-sapply(1:length(caseMissing), function(j) 1)

MissCase<-c(caseMissing,specialCaseMissing)
MissValue<-c(caseMissingValues,specialCaseMissingValues)

df5<-lapply(1:length(MissCase), function(x) {
  VName0<-paste0(MissCase[x],'_0')
  #VName1<-paste0(caseMissing[x],'_1')
  VNameN<-paste0(MissCase[x],'_',MissValue[[x]])
  WForm4.1 %>%
    mutate(!!VNameN := if_else(!!rlang::sym(VName0)=='0','1',as.character(!!rlang::sym(VNameN)))) %>%
    dplyr::select(!!rlang::sym(VName0),!!rlang::sym(VNameN))
})
df6<-cbind(WForm_Wetland_Co,do.call(cbind,df5)) %>%
  dplyr::select(-c(paste0(MissCase,'_0')))
WForm4<-WForm4.1 %>%
  dplyr::select(-c(paste0(c(MissCase),'_',MissValue))) %>%
  left_join(df6,by='Wetland_Co')

#Data Checking
#tt<-WForm3[!(WForm3 %in% WForm4)]
WForm4Check<-WForm4 %>%
  dplyr::select(Wetland_Co,F53_0,c(paste0('F53_',(1:6))))

#dplyr::select(Wetland_Co,F19_0,c(paste0('F19_',(1:6))),F19_2,F22_1, F22_1,F4_1, c(paste0('F4_',(1:3))))

WriteXLS(WForm4,file.path(dataOutDir,paste('WForm4.xlsx',sep='')),
         row.names=FALSE,col.names=TRUE,AllText=TRUE)

