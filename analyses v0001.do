///////   analysis do file for Bann et al paper on quantile regression in the 1958 birth cohort (NCDS)

*run cleaning file first
do "$syntax\recodes_etc_v0005.do" 

*****results 
*output ols regression estimates - average difference in outcome [note add "noaster ci level(95)" for CI with no sig signs)
reg bmi45 fsc0  mwt0 cog11 sports42b 
outreg2 using qreg.doc,   replace  auto(2) nocons  label nor2

*output quantile regression estimates 
sqreg bmi45 fsc0  mwt0 cog11 sports42b , q(.1 .25 .5 .75 .9 ) 
outreg2 using qreg.doc,   auto(2) nocons  label  nor2


*****appendix results
******waist circumference as an outcome
reg waist45 fsc0  mwt0 cog11 sports42b 
outreg2 using waist45qreg.doc,   replace  auto(2) nocons  label nor2

*quantile regression estimates
sqreg waist45 fsc0  mwt0 cog11 sports42b , q(.1 .25 .5 .75 .9 ) 
outreg2 using waist45qreg.doc,   auto(2) nocons  label  nor2


*****log-transformed outcome - waist
*ols reg estimates [note add "noaster ci level(95)" for CI with no sig signs)
reg waist45log fsc0  mwt0 cog11 sports42b 
outreg2 using waist45qreg_log.doc,   replace  auto(2) nocons  label nor2

*quantile regression estimates
sqreg waist45log fsc0  mwt0 cog11 sports42b , q(.1 .25 .5 .75 .9 ) 
outreg2 using waist45qreg_log.doc,   auto(2) nocons  label  nor2


*****log-transformed outcome - BMI
reg bmi45log fsc0  mwt0 cog11 sports42b 
outreg2 using qreglog.doc,   replace  auto(2) nocons  label nor2

*quantile regression estimates
sqreg bmi45log fsc0  mwt0 cog11 sports42b , q(.1 .25 .5 .75 .9 ) 
outreg2 using qreglog.doc,   auto(2) nocons  label nor2


*****additionally adjust for height
*using logged bmi
reg bmi45log fsc0  mwt0 cog11 sports42b bheightm
outreg2 using qreglog_adjheight.doc,   replace  auto(2) nocons  label nor2

*quantile regression estimates
sqreg bmi45log fsc0  mwt0 cog11 sports42b bheightm, q(.1 .25 .5 .75 .9 ) 
outreg2 using qreglog_adjheight.doc,   auto(2) nocons  label nor2

*****additional analyses
**test if correlation between socioeconomic measures differs by BMI

sum bmi45
cap drop bmi45q
xtile bmi45q = bmi45, nq(5)
tabstat bmi45 , by(bmi45q ) stats (mean n)

by bmi45q, sort: tab med0b fsc, chi
by bmi45q, sort: spearman med0b fsc

by bmi45q, sort: corr fsc  cog11
by bmi45q, sort: tab fsc0 med0b, chi

sqreg bmi45log cog11 , q(.1 .25 .5 .75 .9 ) 
