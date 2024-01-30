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
EcoP<-'CM'
#BatchCalcFile<-'BC_BatchCalculator_ModelsRevised_18Oct2023_wColumns.xlsm'
BatchCalcFile<-'Copy of BC_BatchCalculator_ModelsRevised_17Jan2024_wColumns.xlsm'
BCWFfile<-'WESP_06_24_0_export02.23_06Oct2023.xlsx'
numSites<-100

#Loading and cleaning Single and Batch Calculator
source("Load_BatchCalculator.R")
source("Clean_BatchCalculator_Field.R")
source("Clean_BatchCalculator_Office.R")
source("Clean_BatchCalculator_Stressor.R")
#Combine each of the cleaned Batch Calculator pieces into a single list
wetBatch<-list(wetOF,wetF,wetS)
source("Clean_BatchCalculator_Flat.R")
#Loading and cleaning Survey 123 data
#Need to reconcile 'Region' field prior to loading to ensure proper EcoProv site selection
# this is used for selecting data and only EcoProvince abbreviations are acceptable
# Currently: GD, CM, SIM, BP, TP, SB, SI
# Note that the Wetland_Co column and investigator columns can be used to confirm Region assignment.
source("Load_Survey123.R")
#Clean Survey123 data so in a flat format
source("Clean_Survey123_Function.R")
source("Clean_Survey123_Stressor.R")
#Combine each of the cleaned Survey123 pieces into a single list
wetS123<-list(wetFS123,wetSS123)
