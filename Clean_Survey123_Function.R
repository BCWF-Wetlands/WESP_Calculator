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
WForm<-read_excel(file.path(dataOutDir,paste('WFormIn.xlsx',sep='')),
                    col_names=TRUE, col_types=c('text')) %>%
                    dplyr::select(Wetland_Co,starts_with('F')) %>%
                    mutate(across(everything(), as.character))

#Re-format the Survey123 data

#Case 1
# Split F2 into c(F2_A1, F2_A2, F2_B1, F2_B2)
WForm1 <- WForm %>% mutate(
  F2_A1 := case_when(
    F2=="A1" ~ 1,
    TRUE ~ 0),
  F2_A2 := case_when(
    F2=="A2" ~ 1,
    TRUE ~ 0),
  F2_B1 := case_when(
    F2=="B1" ~ 1,
    TRUE ~ 0),
  F2_B2 := case_when(
    F2=="B2" ~ 1,
    TRUE ~ 0)
)

#Case 2
# Make list of variables that require parsing
ParseVars<-c('F3','F56','F57','F58','F61')
#Number of sub-categories for each variable
NparseVars<-c(8,3,7,9,4)

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
WForm2 <- cbind(WForm1,(do.call(cbind, df3)))

#Check parsing
WForm2Check<-WForm2 %>%
  dplyr::select(F3, c(paste0('F3_',(1:8))))

#Case 3
# Split out form binary variables that are contained in 1 variable
ParseVars<-c('F4','F5','F6','F7','F8','F9','F10','F11','F12','F13',
             'F14','F15','F16','F17','F18','F19','F20','F21','F24','F25',
             'F26','F27','F28','F29','F30','F31','F32','F33','F34','F35',
             'F36','F37','F38','F39','F40','F41', 'F43','F44','F45','F47','F48',
             'F50','F51','F52','F53','F54','F55')
#Number of sub-categories for each variable
NparseVars<-c(4,5,5,5,3,4,5,5,4,5,
              5,5,5,5,3,6,5,6,5,5,
              5,6,3,6,6,6,6,6,6,4,
              5,6,3,4,5,4,5,4,3,3,3,
              5,3,4,6,6,7)

df4<-lapply(1:length(ParseVars), function(x) {
  df1<-WForm2 %>%
    rowwise() %>%
    mutate(VpartsN=parse_number(!!rlang::sym(ParseVars[x]))) %>%
    dplyr::select(ParseVars[x],VpartsN)
  SplitFn1(x,df1)
})
WForm3 <- cbind(WForm2,(do.call(cbind, df4)))

WForm3Check<-WForm3 %>%
  dplyr::select(Wetland_Co,F22,F23,F42,F49,F4, c(paste0('F4_',(1:4))))

#Case 4
# Modify y/n to 1/0 and set
WForm4<-WForm3 %>%
  mutate(across(c(F22,F23,F42,F49), ~ case_when(. == "yes" ~ "1", TRUE ~ "0"))) %>%
  mutate(F22_1 = F22) %>%
  mutate(F23_1 = F23) %>%
  mutate(F42_1 = F42) %>%
  mutate(F49_1 = F49) %>%
  mutate(F59_1 = F59) %>%
  #mutate(across(everything(), as.character)) %>%
  #Set parsed variable source to empty?? Not sure about this step
  mutate(across(c(F2,F3,F4,F5,F6,F7,F8,F9,F10,F11,F12, F13,F14,F15,F16,F17,F18,F19,F20,
                  F21,F22,F23,F24,F25,F26,F27,F28,F29,F30,F31,F32,F33,F34,F35,F36,F37,F38,F39,F40,
                  F41,F42,F43,F44,F45,F47,F48,F49,F50,F51,F52,F53,F54,F55,F56,F57,F58,F61),
                ~ case_when(nchar(.) > 0 ~ " ", TRUE ~ " "))) %>%
  mutate(across(F60_1, as.numeric)) %>%
  mutate(F60=if_else((!is.na(F60_1)),F60_1,0)) %>%
  mutate(across(c(F60,F60_1), as.character))

WForm4Check<-WForm4 %>%
  dplyr::select(Wetland_Co,F19,F19_1,F19_2,F22, F22_1,F4, c(paste0('F4_',(1:4))))

WriteXLS(WForm4,file.path(dataOutDir,paste('WForm4.xlsx',sep='')),
         row.names=FALSE,col.names=TRUE,AllText=TRUE)

#Cast data into same data structure as Batch Calculator
#Select each wetland, then each question and create a 3 dimension table - resulting in a list of wetland,
# with a data frame of question and sub-questions
#Field case
nQs<-61
Qlist<-c(paste0('F',(1:(nQs)),'_'))
max_length<-10 #maximum number of sub-questions
wetName123<-WForm4$Wetland_Co
#Loop through each wetland
wetFS123<-lapply(1:length(SWetList), function(y) {
  #Single wetland
  wet1<-as.data.frame(t(rbind(names(WForm4[y,]),WForm4[y,])))
  colnames(wet1)<-c('F_Question',wet1[1,2])
  wet1<-wet1[-1,]
  rownames(wet1)<-1:nrow(wet1)

  #Change all F# to F#_0
 # wet1<-wet1 %>%  arrange(F_Question)

  #make each question it's own list
  wet1Q<-lapply(1:length(Qlist), function(x) {
    df1<-wet1 %>%
      dplyr::filter(str_detect(F_Question, Qlist[x])) %>%
      replace(is.na(.), 0)
    wetP<-df1[[2]]
    #changed from index of 2 to 1 since no F#_0s in survey 123 vs load from Batch
    df2<- data.frame(c(wetP[1:length(wetP)],rep(NA,max_length - length(wetP))))
    names(df2)[1]<-strsplit(df1$F_Question[[1]], "[_]")[[1]][1]
    print(x)
    return(df2)
  })

  #Combine all the questions for a single wetland
  df3<-do.call(cbind, wet1Q)
})
#Name each list element (wetland)
names(wetFS123)<-wetName123
