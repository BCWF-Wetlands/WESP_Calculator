# Copyright 2018 Province of British Columbia
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

source("header.R")

#Set the EcoProvince and name of the Survey 123 file name - it needs to be in the 'data' directory
EcoP<-'GD'

#Load survey 123 data from file
source("Load_Survey123.R")
#Clean Survey123 data
source("Clean_Survey123_Function.R")
source("Clean_Survey123_Stressor.R")

#Collate function and stressor data with Office Data
source("Clean_Collate_F_S_OF.R")

#Run wespR on data, normalize scores and run Jenks breaks
source('Analysis_wespR.R')
