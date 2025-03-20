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

#Prepare for and install wespr
Sys.unsetenv("GITHUB_PAT")
#library(devtools)
#install.packages("devtools")
#devtools::install_github("BCWF-Wetlands/wespr")
library(wespr)
#find.package(wespr, lib.loc, quiet = TRUE)

#read wesp data into wespr
baseDir<-system('pwd',intern=TRUE)
#system.file("/Users/darkbabine/Sync/_dev/Water/WESP_Calculator/out/data/wesp.csv", package = "base",lib.loc =NULL,mustWork=TRUE)
wesp_file <- file.path(baseDir,dataOutDir,'wesp.csv')
wesp_data <- wespr::load_wesp_data(wesp_file)
nsites<-ncol(wesp_data)-2
#Check file
head(wesp_data)

#Get wetland names
wetName<-data.frame(site=as.double(gsub("^.*?_","",colnames(wesp_data[3:ncol(wesp_data)]))),
                    Wetland_Co=t(wesp_data[nrow(wesp_data),3:ncol(wesp_data)]))

#load supporting files
#wetLUT<-readRDS(file='tmp/wetLUT')

#Run as a single site to test
site <- as.wesp_site(wesp_data, site = 1)
wesp.data.check<-wesp_data %>%
  dplyr::select(q_no,response_no,site_57,site_58)

#Calculate wesp indicators
site <- calc_indicators(site)
get_derived_values(site)

#loop over all sites and calculate indicators and store in list
# used below for normalizing and jenks breaks
siteL<-lapply(1:nsites, function(x) {
  calc_indicators(as.wesp_site(wesp_data, site=x))
})

##### Calculate Jenks  Breaks #####

#Function Scores
#store names of eco services and get number of services
wespServices<-paste0(names(siteL[[1]]$indicators))
wespServicesFun<-paste0(wespServices,'F_')
nServicesF<-length(wespServicesFun)
#Pull out the raw wesp scores for each service and site and store it in a data frame
FunctionL<-lapply(1:nServicesF, function(x) {
  siteFL<-lapply(1:nsites, function(y) {
    #Index into wesp object to get raw scores
    #siteL[[y]][[4]][[x]]$fun[[1]]
    siteL[[y]][[4]][[x]][[1]][[1]]
  })
  siteFLL <- as.data.frame(do.call(rbind, siteFL))
})

#siteL[[107]][[4]][[12]]

wespFn.1<-do.call(cbind, FunctionL)
colnames(wespFn.1)<-c(paste0(wespServicesFun,'Raw'))
wespRawF<-wespFn.1 %>%
  mutate(site=as.numeric(rownames(.)), .before=1) %>%
  replace(is.na(.),0)

#Benefit Scores
nServicesB<-length(wespServicesFun)
wespServicesBenL<-lapply(1:nServicesF, function(x) {
    #Index into wesp object to see if la benefit score is present
    length(siteL[[1]]$indicators[[x]])
  })
wespServicesBen.1 <- as.data.frame(do.call(rbind, wespServicesBenL))
colnames(wespServicesBen.1)<-c('servLength')

wespServicesBen.2<- wespServicesBen.1 %>%
  mutate(id = seq_len(nrow(wespServicesBen.1))) %>%
  filter(servLength>1)

wespServicesBen<-paste0(wespServices[wespServicesBen.2[[2]]],'B_')

BenefitL<-lapply(wespServicesBen.2[[2]], function(x) {
siteBL<-lapply(1:nsites, function(y) {
  lr<-siteL[[y]][[4]][[x]][[2]][[1]]
  return(lr)
})
siteBLL <- as.data.frame(do.call(rbind, siteBL))
})
wespBn.1<-do.call(cbind, BenefitL)
colnames(wespBn.1)<-c(paste0(wespServicesBen,'Raw'))
wespRawB<-wespBn.1 %>%
  mutate(site=as.numeric(rownames(.)), .before=1) %>%
  replace(is.na(.),0) %>%
  dplyr::select(!c(site))

#Combine Function and Benefits into one df
wespRaw<-cbind(wespRawF,wespRawB)
nFB<-length(wespRaw)
wespRawNames<-colnames(wespRaw)[2:nFB]

#Calculate Jenks breaks and add to data.frame
#First normalize the service and add to data.frame
#Min-Max normalization function
min_max_norm <- function(x) {
  #if_else((max(x) == min(x)),1,0)
  (x - min(x)) / (max(x) - min(x))
}
#apply Min-Max normalization
wespNorm <- as.data.frame(lapply(wespRaw[2:nFB], min_max_norm)) %>%
  mutate(site=as.numeric(rownames(.)), .before=1) %>%
  replace(is.na(.),1)

colnames(wespNorm)<-c('site',paste0(wespRawNames,'Norm'))

#Do Jenks breaks using normalized scores
# use BAMMtools' getJenksBreaks function
library('BAMMtools')

#wesp_breaksL.1 <- lapply(2:(nFB+1), function(x) {
wesp_breaksL.1 <- lapply(2:nFB, function(x) {
    jen_breaks<-getJenksBreaks(wespNorm[[x]], 4, subset = NULL)
      .bincode(wespNorm[[x]], jen_breaks,include.lowest=TRUE)
      })
#Change numeric to character High, Medium, Low
wesp_breaksL<- lapply(wesp_breaksL.1[1:(nFB+1)], function(x) case_when(
  x ==1 ~ 'L',
  x ==2  ~ 'M',
  x ==3  ~ 'H'
))
#Change list to data frame
wespBreaks<-as.data.frame(do.call(cbind, wesp_breaksL)) %>%
  mutate(site=as.numeric(rownames(.)), .before=1)
colnames(wespBreaks)<-c('site',paste0(wespRawNames,'Jenks'))

#Make a single data frame that includes the raw, normalized and Jenks values
wespEcoS.1<-list(wespRaw, wespNorm, wespBreaks) %>%
  purrr::reduce(full_join, by='site') %>%
  dplyr::select(site,sort(names(.)))
wespEcoSFun<-data.frame(Wetland_Co=wetLUT,wespEcoS.1) %>%
  dplyr::full_join(wetName,by=c('site')) %>%
  dplyr::select(site,Wetland_Co,contains("F_"))
wespEcoSBen<-data.frame(Wetland_Co=wetLUT,wespEcoS.1) %>%
  dplyr::full_join(wetName,by=c('site')) %>%
  dplyr::select(site,Wetland_Co,contains("B_"))
wespEcoSout<-list(Functions=wespEcoSFun,Benefits=wespEcoSBen)
#Write out the data frame
WriteXLS(wespEcoSout,file.path(dataOutDir,paste('wespEcoS.xlsx',sep='')),
         #sheetNames=c('Functions','Benefits'),
         row.names=FALSE,col.names=TRUE,AllText=TRUE)


###### testing with Paul's batch spreadsheet raw values for comparison
JenksWS<-read_excel(file.path(DataDir,paste('JenksWS.xlsx',sep='')),
                  col_names=TRUE, col_types=c('text'),
                  sheet='SFTS')
var<-JenksWS$WS_Norm
k<-2
getJenksBreaks(var, k, subset = NULL)


