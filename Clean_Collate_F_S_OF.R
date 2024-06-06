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

#Read in Survey 123 field and stressor scores
Fn<-read_xlsx(file.path(dataOutDir,paste('WForm4.xlsx',sep='')))

FnCheck<-Fn %>%
  dplyr::select(Wetland_Co,F22_1,F23_1,F42_1,F49_1,F4_0, c(paste0('F4_',(1:3))))

Stress<-read_xlsx(file.path(dataOutDir,paste('WFormS3.xlsx',sep='')))

#Read in Office scores
OFDataDir <- file.path('../WESP_OF/out/data',paste0(EcoP,'_Base'))

OF_Answers.data<-read_xlsx(file.path(OFDataDir,'OF_Answers.data.xlsx')) %>%
  dplyr::rename(Wetland_Co=WTLND_ID) %>%
  #Select rows that are in F and S
  dplyr::filter(Wetland_Co %in% Fn$Wetland_Co)

OF_Answers.data.Check<-OF_Answers.data %>%
  dplyr::select(Wetland_Co, c(paste0('OF30_',(1:3))))

#Combine field, stressors, and office question data
wespF<-list(Fn,OF_Answers.data,Stress)

wesp.1<-wespF %>% purrr::reduce(full_join, by='Wetland_Co') %>%
  select(-contains("_0"))
wetLUT<-wesp.1$Wetland_Co

wesp.1.check<-wesp.1 %>%
  dplyr::select(Wetland_Co, c(paste0('OF36_',(1:4))))

wesp.2<-wesp.1 %>%
  dplyr::select(-c(Wetland_Co))

#Transpose and format the data to wespR format and export
wesp.3<-as.data.frame(t(wesp.2))
rownames(wesp.3) <- colnames(wesp.2)
colnames(wesp.3) <- rownames(wesp.2)
#wetLUT<-wesp.1[1,]

colOrder<-str_sort(rownames(wesp.3),numeric=TRUE)
wesp.4<-wesp.3[match(colOrder, rownames(wesp.3)),]

wesp<-wesp.4 %>%
  mutate(Question=rownames(wesp.4)) %>%
  dplyr::select(Question,everything())

write.csv(wesp, file.path(dataOutDir,paste('wesp.csv',sep='')), row.names=FALSE)

