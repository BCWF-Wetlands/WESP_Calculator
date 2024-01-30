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

#Select each wetland, then each question and create a 3 dimension table - resulting in a list of wetland,
# with a dataframe of question and sub-questions
#Field case
nQs<-59
Qlist<-c(paste0('F',(1:(nQs)),'_'))
max_length<-11 #maximum number of sub-questions + F#_0

#Loop through each wetland
wetF<-lapply(1:length(BWetList), function(y) {
    #Single wetland
wet1b<-WESPclean[[1]] %>% #single sheet - F
  dplyr::select(F_Question,as.character(BWetList[[y]])) %>%
  #drop all non data rows e.g F#_0
  dplyr::filter(!(str_detect(F_Question, "_0|_A0|_B0"))) %>%
  replace(is.na(.), 0) #set all NA to 0

#make each question it's own list
wet1Q<-lapply(1:length(Qlist), function(x) {
    df1<-wet1b %>%
      dplyr::filter(str_detect(as.character(F_Question), Qlist[x]))
    # makes a list for each question with possible responses
    wetP<-df1[[2]]
    df2<- data.frame(c(wetP[2:length(wetP)],rep(0,max_length - length(wetP[2:length(wetP)])))) %>%
      replace(is.na(.), 0) #set all NA to 0
    names(df2)[1]<-strsplit(df1$F_Question[[1]], "[_]")[[1]][1]
    # Change to flat file by returning df1(flat file)  instead of df2(embeded list of sub-questions)
    return(df2)
  })
#Combine all the questions for a single wetland
df3<-do.call(cbind, wet1Q)

})
#Name each list element (wetland)
names(wetF)<-wetNameBF

