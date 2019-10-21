*Gregory Bruich
*Economics 1152, Spring 2019
*Harvard University
*Send suggestions and corrections to gbruich@fas.harvard.edu

clear all
set more off
cap log close

import delimited "datacommons_cdc_deaths.csv", clear 

*Get rid of county prefix on variables
rename county* *

*Sum data
sum

*Drop data with lots of missing values
drop criminalactivitiescrimetyp mortalityeventcauseofdeath v5 v7
sum

*Store all the remaining predictors
ds geoid place, not
local vars = r(varlist)

*Merge with atlas training data
merge 1:1 geoid using atlas_training.dta
sum if _merge == 3

*Turn into a rate (deaths per 100,000)
*Impute 0 for missing -1 and .'s from CDC wonder
foreach j in `vars' {
replace `j' = 0 if `j' == -1 | missing(`j')
replace `j' = 100000*`j' / pop

}

*Produce summary statistics for combined data
sum

*Store predictors
global predictorvars "v6 v8 v9 v10 v11 v12 v13 v14 v15 v16 v17"

*OLS regression
reg kfr_pooled_p25 $predictorvars P_* if training == 1, r
predict rank_hat_ols

*Now prep data for exporting to R for decision trees and random forests

*Reorder variables
order geoid place pop housing kfr_pooled_p25 test training _merge rank_hat_ols

*Drop counties not in training and not in test data
drop if training == .

*Save data file
save project4.dta, replace



