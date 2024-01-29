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

#Make a flat file of F, OF, and S

wetAll<-lapply(1:length(WESPclean), function(x) {
  Question<-paste0(WESPinSheets[x],"_Question")
  wet1b<-WESPclean[[x]] %>% #single sheet
    dplyr::select(Question=ends_with('Question'),as.character(all_of(BWetList))) %>%
    #drop all non data rows e.g F#_0
    #dplyr::filter(!str_detect(Question, "_0|_A |_B |_a|_b|_c|_d|_e")) %>%
    #dplyr::filter(!str_detect(Question, "_0|_a|_b|_c|_d|_e"),c('F2_A','F2_B')) %>%
    dplyr::filter(!str_detect(Question, "_0|_a|_b|_c|_d|_e")) %>%
    dplyr::filter(!Question==c('F2_A','F2_B')) %>%
    replace(is.na(.), 0) #set all NA to 0
  return(wet1b)
})
wetFlat<-do.call(rbind, wetAll)

#Output flat file
WriteXLS(wetFlat,file.path(dataOutDir,paste('wetFlat.xlsx',sep='')),
        row.names=FALSE,col.names=TRUE,AllText=TRUE)

