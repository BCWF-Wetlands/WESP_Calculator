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
library(devtools)
install.packages("devtools")
devtools::install_github("BCWF-Wetlands/wespr")
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
#store names of eco services and get number of services
wespServices<-names(siteL[[1]]$indicators)
nServices<-length(wespServices)

##### Calculate Jenks  Breaks #####

#Pull out the raw wesp scores for each service and site and store it in a data frame
FunctionL<-lapply(1:nServices, function(x) {
  siteFL<-lapply(1:nsites, function(y) {
    #Index into wesp object to get raw scores
    siteL[[y]][[4]][[x]][[1]][[1]]
  })
  siteLL <- as.data.frame(do.call(rbind, siteFL))
})
wespFn.1<-do.call(cbind, FunctionL)
colnames(wespFn.1)<-c(paste0(wespServices,'Raw'))
wespRaw<-wespFn.1 %>%
  mutate(site=as.numeric(rownames(.)), .before=1) %>%
  replace(is.na(.),0)


#Calculate Jenks breaks and add to data.frame
#First normalize the service and add to data.frame
#Min-Max normalization function
min_max_norm <- function(x) {
  (x - min(x)) / (max(x) - min(x))
}
#apply Min-Max normalization
wespNorm <- as.data.frame(lapply(wespRaw[2:20], min_max_norm)) %>%
  mutate(site=as.numeric(rownames(.)), .before=1)
colnames(wespNorm)<-c('site',paste0(wespServices,'Norm'))

#Do Jenks breaks using normalized scores
# use BAMMtools' getJenksBreaks function
library('BAMMtools')

wesp_breaksL.1 <- lapply(2:(nServices+1), function(x) {
      jen_breaks<-getJenksBreaks(wespNorm[[x]], 4, subset = NULL)
      .bincode(wespNorm[[x]], jen_breaks,include.lowest=TRUE)
      })
#Change numeric to character High, Medium, Low
wesp_breaksL<- lapply(wesp_breaksL.1[1:(nServices+1)], function(x) case_when(
  x ==1 ~ 'L',
  x ==2  ~ 'M',
  x ==3  ~ 'H'
))
#Change list to data frame
wespBreaks<-as.data.frame(do.call(cbind, wesp_breaksL)) %>%
  mutate(site=as.numeric(rownames(.)), .before=1)
colnames(wespBreaks)<-c('site',paste0(wespServices,'Jenks'))

#Make a single data frame that includes the raw, normalized and Jenks values
wespEcoS.1<-list(wespRaw, wespNorm, wespBreaks) %>%
  purrr::reduce(full_join, by='site') %>%
  dplyr::select(site,sort(names(.)))
wespEcoS<-data.frame(Wetland_Co=wetLUT,wespEcoS.1)

#Write out the data frame
WriteXLS(wespEcoS,file.path(dataOutDir,paste('wespEcoS.xlsx',sep='')),
         row.names=FALSE,col.names=TRUE,AllText=TRUE)


###### testing with Paul's batch spreadsheet raw values for comparison
JenksWS<-read_excel(file.path(DataDir,paste('JenksWS.xlsx',sep='')),
                  col_names=TRUE, col_types=c('text'),
                  sheet='SFTS')
var<-JenksWS$WS_Norm
k<-2
getJenksBreaks(var, k, subset = NULL)


