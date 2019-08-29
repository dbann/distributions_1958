///////   Recodes/cleaning do file for Bann et al paper on quantile regression in the 1958 birth cohort (NCDS)
///////   Run this do-file before running the analysis do file 
///////   Make sure to change directory to your own machine
///////   Data files are available from the UK Data Archive: https://beta.ukdataservice.ac.uk/datacatalogue/series/series?id=2000032
///////   For further information on this dataset, see the CLS website: https://cls.ucl.ac.uk/

***merge and open data files
*bmi outcome data at 44/45y
use "$data\45y_biomed\biomed2004All.dta", clear

*childhood SEP and maternal weight from childhood sweeps
merge 1:1 ncdsid using "$data\0, 7, 11, 16y\ncds0123.dta"

*adult SEP data from age 42y
drop _merge
merge 1:1 ncdsid using "$data\42y\ncds6.dta", keepusing(sc breathls exercise)

*sex
clonevar sex = n622
mvdecode sex, mv( -1=.) 
tab sex

 
***clean and recode relevant exposure and outcme data
*bmi
mvdecode bweight bheight , mv( -3/-1=.) 
gen bheightm = bheight /100
sum bheightm bheight

gen bmi45 = bweight / bheightm ^2
sum bmi45 bweight bheight

*waist circmumference
clonevar waist45=waist 
mvdecode waist45, mv(-3/-1=.  \ 999.9=.) 

sum waist45
*hist waist45

**generate logged outcomes
foreach var of varlist   bmi45 waist45 {
capture drop `var'log
gen `var'log = ln(`var')
}

*label outcomes
label var bmi45 "BMI (kg/m2) at 45y"
label var bheightm "Height at 45y (per 1m higher)"

*0y
*father's class at 0y
capture drop fsc
clonevar fsc = n236
mvdecode fsc , mv( -1=. \ 1=. \ 9=. \ 10 =. \ 11=. \ 12 = . ) //note codes missing to. and unemployed, students etc
tab  fsc 
recode fsc (2=0 "I professional") (3=1 "II") (4=2 "III nm") (5=3 "III m") (6=4 "IV") (7=5 "V"), gen(fsc0)

label var fsc0 "Paternal social class (per 1 category lower), birth"

*binary version
recode fsc0 (0/2 = 0 "Non-manual") (3/5 =1 "Manual"), gen(fsc0b)
tab fsc0 fsc0b 
label var fsc0b "Paternal social class (manual vs non-manual), birth"


*maternal weight
tab n496 //note non-linear order
mvdecode n496, mv( -1=.) 

cap drop mwt0x 
clonevar mwt0x = n496  
tab mwt0x
tab mwt0x, nolab
recode mwt0x ( 7=1  " Under 7 stone " ) ( 8=2  " 7st below 8st " ) ( 9=3  " 8st below 9st " ) ( 10=4  " 9st below 10st " ) ( 1=5  " 10st below 11st " ) ( 2=6  " 11st below 12st " ) ( 3=7  " 12st below 13st " ) ( 4=8  " 13st below 14st " ) ( 5=9  " 14st below 15st " ) ( 6=10  " 15st and over " ) , gen(mwt0)
tab mwt0x mwt0

label var mwt0 "Maternal weight (per 1 higher category), birth"

*binary version
recode mwt0 (1/3 = 0 "< 9 stone") (4/10= 1 "9 stone or more"), gen(mwt0b)
tab mwt0 mwt0b, mi
label var mwt0b "Maternal weight (9 stone or more vs less), birth"


*maternal education at 0y
desc n537
tab n537
clonevar med0 = n537  //"0 Was mum at sch. after min.leaving age" - slightly unclear responses, conservatively coded
tab med0 
tab med0 , nolab
mvdecode med0 , mv( -1=. \ 1=. \ 2=. \ 8=. ) 
cap drop med0b 
recode med0 (3/4 =0 "yes (higher education)") (6=0) (5=1 "no (lower ed)"), gen(med0b)
tab med0 med0b, mi 

*cognition at 11y - for details of this measure see https://cls.ucl.ac.uk/wp-content/uploads/2017/07/NCDS-user-guide-NCDS1-3-Measures-of-ability-P-Shepherd-December-2012.pdf
mvdecode n920 , mv( -1=.) 
*reverse order per other variables so higher score = lower cognition score
gen xx = 81 - n920
corr xx n920
egen cog11 = std(xx)
sum cog11 
*kdensity cog11 //broadly normally distributed

label var cog11 "General cognition (per 1 lower SDS), 11y"

*exercise at 42y
desc exercise
recode exercise  (1=0 "yes does regular exercise") (2=1  "does not") (8=.) (9=.), gen(sports42b)
label var sports42b "Physical exercise (inactive vs active), 42y"
tab exercise   sports42b, mi
