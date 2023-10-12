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
WFormS<-read_excel(file.path(dataOutDir,paste('WFormIn.xlsx',sep='')),
                   col_names=TRUE, col_types=c('text')) %>%
  dplyr::select(Wetland_Co,
                starts_with('S')) %>%
  mutate(across(everything(), as.character))

#Make list of variables that require parsing
#S1 S1_3
ParseVars<-c('S1','S2','S3','S4','S5','S6')
#Number of sub-categories for each variable
#NparseVars<-c(10,5,9,8,8,4)
NparseVars<-c(10,5,9,9,8,2)

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
WFormS2 <- cbind(WFormS,(do.call(cbind, df3))) %>%
  mutate(across(everything(), as.character))

WFormS2Check<-WFormS2 %>%
  dplyr::select(Wetland_Co,c(paste0('S5_',(1:12))))

#Split out form binary variables that are contained in 1 variable
ParseVars<-c('S1_11','S1_12','S1_13','S1_14','S2_6','S2_7','S2_8','S3_10','S3_11','S3_12',
             'S4_10','S4_11','S4_12','S5_9','S5_10','S5_11','S5_12','S6_3','S6_4')

WFormS3<-WFormS2 %>%
  mutate(across(all_of(ParseVars), parse_number)) %>%
  mutate(across(everything(), as.character)) %>%
  dplyr::select(Wetland_Co,
                S1, starts_with('S1_'),S2, starts_with('S2_'),
                S3, starts_with('S3_'),S4, starts_with('S4_'),
                S5, starts_with('S5_'),S6, starts_with('S6_'))
StressCols<-colnames(WFormS3)

WFormS3Check<-WFormS3 %>%
  dplyr::select(Wetland_Co,c(paste0('S5_',(1:12))))

WriteXLS(WFormS3,file.path(dataOutDir,paste('WFormS3.xlsx',sep='')),
         row.names=FALSE,col.names=TRUE,AllText=TRUE)

#Cast data into same data structure as Batch Calculator
#Select each wetland, then each question and create a 3 dimension table - resulting in a list of wetland,
# with a data frame of question and sub-questions
#Field case
nQs<-6
Qlist<-c(paste0('S',(1:(nQs)),'_'))
max_length<-14 #maximum number of sub-questions
wetName123<-WFormS3$Wetland_Co
#Loop through each wetland
wetSS123<-lapply(1:length(wetName123), function(y) {
  #Single wetland
  wet1<-as.data.frame(t(rbind(names(WFormS3[y,]),WFormS3[y,])),stringsAsFactors=F)
  colnames(wet1)<-c('F_Question',wet1[1,2])
  wet1a<-wet1[-1,]
  wet1<-wet1a[gtools::mixedorder(wet1a$F_Question),]
  rownames(wet1)<-1:nrow(wet1)
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
names(wetSS123)<-wetName123

wetSS123Check<-wetSS123[["ESI-32955"]] #Batch ID 13
