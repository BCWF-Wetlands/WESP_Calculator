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
#Office case
nQs<-44
Qlist<-c(paste0('OF',(2:(nQs)),'_'))
max_length<-11 #maximum number of sub-questions + OF#_0

#Loop through each wetland
wetOF<-lapply(1:length(WetList), function(y) {
#Single wetland
wet1<-WESPclean[[2]] %>% #single sheet - OF
  dplyr::select(OF_Question,WetList[[y]])

#make each question it's own list
  wet1Q<-lapply(1:length(Qlist), function(x) {
    df1<-wet1 %>%
      dplyr::filter(str_detect(OF_Question, Qlist[x]))
    wetP<-df1[[2]]
    df2<- data.frame(c(wetP[2:length(wetP)],rep(NA,max_length - length(wetP))))
    names(df2)[1]<-strsplit(df1$OF_Question[[1]], "[_]")[[1]][1]
    return(df2)
  })

#Combine all the questions for a single wetland
df3<-do.call(cbind, wet1Q)

})
#Generates a list of wetlands, as a dataframe of questions x sub-questions
#wetOF
