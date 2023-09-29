# WESP_Calculator
R code to interact with excel based WESP calculator

============================

The B.C. Wildlife Federation’s Wetlands Workforce project is a collaboration with conservation organizations and First Nations working to maintain and monitor wetlands across British Columbia. https://bcwf.bc.ca/initiatives/wetlands-workforce/.  

WESP - Wetland Ecosystem Services Protocol   

### Data

The input excel WESP Spreadsheet requires some minor formatting changes to be machine readable.   
1. Remove bottom row referencing site ids.   
2. Adding a column indicating question and sub-questions, for example the row describing OF32 becomes OF32_0 and the individual OF32 questions become OF32_1, OF32_2 and OF32_3.   
3. The first row, specifically the "F" and "S" sheets are modified so that every column has a heading.
    
### Usage

There are a set of scripts that help load data from WESP Calculator excel spreadsheet and from the Survey 123 WESP protocol applicationn there are four basic sets of scripts:    
Control scripts - set up the analysis environment;   
Load scripts - loads excel and survey 123 data;   
Clean scripts - cleans loaded data and generates a single EcoProvince data set;   
Output scripts - outputs collated data.

#Control Scripts:   
run_all.R	Sets local variables and directories used by scripts, presents script order.  
header.R	loads R packages, sets global directories, and attributes.

#Load Scripts:	
Load_BatchCalculator.R  
Clean_BatchCalculator_Field.R 
Clean_BatchCalculator_Office.R  
Clean_BatchCalculator_Stressor.R  

#Loading and cleaning Survey 123
Load_Survey123.R  
Clean_Survey123_Function.R  
Clean_Survey123_Stressor.R

#Output   
Output_WESP_Data.R 

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
