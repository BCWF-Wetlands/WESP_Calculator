# WESP_Calculator
R code to extract excel based WESP calculator input data and Survey 123 WESP field app data.

============================

The B.C. Wildlife Federation’s Wetlands Workforce project is a collaboration with conservation organizations and First Nations working to maintain and monitor wetlands across British Columbia. https://bcwf.bc.ca/initiatives/wetlands-workforce/.  

WESP - Wetland Ecosystem Services Protocol   

### Data

The input excel WESP Spreadsheet requires some minor formatting changes to be machine readable.   
1. Modify the '#' column - change its name to 'OF_Quesiton', 'F_Question' or 'S_Question. Add sub-questions to rows, for example the row describing OF32 becomes OF32_0 and the individual OF32 questions become OF32_1, OF32_2 and OF32_3. As well, un-merge rows.  
2. The first row, specifically the "F" and "S" sheets are modified so that every column has a heading.  
3. Label all rows to be dropped as 'Drop#', including any empty rows at bottom of sheet where there is another row containing the Wetland_Co data, and those rows that were merged that contain further OF directions.   

Some modifications are also required to make the Survey 123 form output, which is in csv, more machine readable and cleaner, they are as follows:  
1. Fix the date field in excel by creating a new field with a text date (eg =TEXT(D3,"d/m/yy")).  
2. Delete fields L and M – they are empty and repeated in columns DD and DE but have data.  
3. Add a row that has labels corresponding to question number (F1_1 to F60) and the ancillary information (Wetland_Co, date, etc). Older versions of the form with this modification are in the sync and the row should copy and paste into the new spreadsheet.  
4. Note that the form generates a few extra rows – F45_1.1, F46_1.1, F46_1.2 and F60_1. As well, Wetland_CoIn is used to track some of the odd Form Wetland_Co values.  
5. Check the 'Region' column and ensure consistent assignment of Region - this is used for selecting data and only EcoProvince abbreviations are acceptable (currently: GD, CM, SIM, BP, TP, SB, SI). The Wetland_Co column and investigator columns can be used to confirm Region assignment.  
6. Clean up the 'ph column'pH measurement' column so that it contains only 1 numeric entry. 

### Usage

There are a set of scripts that help load data from WESP Calculator excel spreadsheet and from the Survey 123 WESP protocol applicationn there are three basic sets of scripts:    
Control scripts - set up the analysis environment;   
Load scripts - loads excel and survey 123 data;   
Clean scripts - cleans loaded data and generates a single EcoProvince data set;   

#Control Scripts:   
run_all.R	Sets local variables and directories used by scripts, presents script order.  
header.R	loads R packages, sets global directories, and attributes.

#Load and Clean Batch Calculator:	
Load_BatchCalculator.R  
#Flat file clean  
Clean_BatchCalculator_Flat.R  
#Individual cleans for making embeded list data structure   
Clean_BatchCalculator_Field.R   
Clean_BatchCalculator_Office.R    
Clean_BatchCalculator_Stressor.R      

#Loading and cleaning Survey 123  
Load_Survey123.R  
Clean_Survey123_Function.R  
Clean_Survey123_Stressor.R

### Project Status

The scripts are continually being modified and improved.

### Getting Help or Reporting an Issue

To report bugs/issues/feature requests, please file an [issue](https://github.com/BCWF-Wetlands/WESP_data_prep/issues/).

### How to Contribute

If you would like to contribute, please see our [CONTRIBUTING](CONTRIBUTING.md) guidelines.

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

### License

```
Licensed under the Apache License, Version 2.0 (the &quot;License&quot;);
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an &quot;AS IS&quot; BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and limitations under the License.
```
---
