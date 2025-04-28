# WESP_Calculator
R code to process Survey 123 WESP field app data and Office question data to generate wetland ecosystem services scores

============================

The B.C. Wildlife Federation’s Wetlands Workforce project is a collaboration with conservation organizations and First Nations working to maintain and monitor wetlands across British Columbia. https://bcwf.bc.ca/initiatives/wetlands-workforce/.  

WESP - Wetland Ecosystem Services Protocol   

### Data

Some modifications may be required to make the Survey 123 form output, which is in csv, more machine readable and cleaner, they are as follows:  
1. Fix the date field in excel by creating a new field with a text date (eg =TEXT(D3,"d/m/yy")). Check that dates are valid. 
2. Check the 'Region' column and ensure consistent assignment of Region - this is used for selecting data and only EcoProvince abbreviations are acceptable (currently: GD, CM, SIM, BP, TP, SB, SI). The Wetland_Co column and investigator columns can be used to confirm Region assignment.  
3. Clean up the 'ph column'pH measurement' column so that it contains only 1 numeric entry.  
4. The Load script does some data checking and generates an excel table listing wetlands that appear more than once in the data and where field and stressor entries are blank in the survey 123 data.
5. Check if spreadsheet is multi-tab, update Load_Survey123.R  to read correct tab if not in first position

### Usage

There is a single script Analysis_wespR.R that reads the field and office questions and generates the wetland ecosystem scores for each wetland.  

Enter the EcoProvince abbreviation (GD, SIM, CI, etc)  

Identify if it is a Single or Reference site 

Enter the location and name of the survey 123 xlsx file (without extension), for example 'data/field_survey123_edited_04.14.2025'  

Enter the location and name of the manual questions xlsx spreadsheet (without extension), for example - '../WESP_OF/out/data/GD_Base/GD_BaseOF_Answers.data' 

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
