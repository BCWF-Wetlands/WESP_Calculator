# WESP_Calculator
R code to process Survey 123 WESP field app data and Office question data to generate wetland ecosystem services scores

============================

The B.C. Wildlife Federation’s Wetlands Workforce project is a collaboration with conservation organizations and First Nations working to maintain and monitor wetlands across British Columbia. https://bcwf.bc.ca/initiatives/wetlands-workforce/.  

WESP - Wetland Ecosystem Services Protocol   

### Data

Some modifications are required to make the Survey 123 form output, which is in csv, more machine readable and cleaner, they are as follows:  
1. Fix the date field in excel by creating a new field with a text date (eg =TEXT(D3,"d/m/yy")).  
2. Check the 'Region' column and ensure consistent assignment of Region - this is used for selecting data and only EcoProvince abbreviations are acceptable (currently: GD, CM, SIM, BP, TP, SB, SI). The Wetland_Co column and investigator columns can be used to confirm Region assignment.  
3. Clean up the 'ph column'pH measurement' column so that it contains only 1 numeric entry.  
4. The Load script does some data checking and generates an excel table listing wetlands that appear more than once in the data and where field and stressor entries are blank in the survey 123 data.

### Usage

There are a set of scripts that help load data from the Survey 123 WESP protocol application there are four basic sets of scripts:    
Control scripts - set up the analysis environment;   
Load scripts - loads excel and survey 123 data;   
Clean scripts - cleans loaded data and generates a single EcoProvince data set; and   
Analysis scripts - generates the wetland ecosystem scores for each wetland

#Control Scripts:   
run_all.R	Sets local variables and directories used by scripts, presents script order.  
header.R	loads R packages, sets global directories, and attributes.

#Loading and cleaning Survey 123  
Load_Survey123.R  
Clean_Survey123_Field.R   
Clean_Survey123_Stressor.R   
#Collating field, stressor and office data and preparing for ecosystem services calculations   
Clean_Collate_F_S_O.R   

#Analysis Script - runs the wespR package against the data calculating wesp scores for each wetland   
Analysis_wespR.R   

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
