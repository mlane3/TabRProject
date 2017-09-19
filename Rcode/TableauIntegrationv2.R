# Install Rserve for Tableau Integration -----------------------

##The most important library we are using is called R serve, so run the follow line below:
if("Rserve" %in% rownames(installed.packages()) == FALSE) {install.packages("Rserve")}
#Details on Integrate R with Tableau Server can be found here:
# http://kb.tableau.com/articles/HowTo/configuring-tableau-server-for-r-and-rserve?userSource=1

##To Start Rserve:
#Try both Rserve() and the line commented out below to test the install works.
# Get a TA if both do not work
library(Rserve)
Rserve() #Default command to start R Tableau Integration.
#Rserve(args="--no-save") #some version of R may need to use this command instead of just Rserve()



##How too quit Rserve (for either Rstudio or R on Windows):
#Use this command if you need to shutdown Rserve while in Rstudio
system('tasklist /FI "IMAGENAME eq Rserve.exe"') #This will get the PID or port that you need
system('TASKKILL /PID {yourPID} /F') #Replace {yourPID} with the PID number you got from the last step


##What if I get an Error in Tableau?
#Typically if the error is printed from Tableau you have to fix the problem in R...
# then reconnect Tableau and R.

# Install Other Required Packages for Tableau Integration Capstone-----------------------

#For the R integration you will need these packages

if("RColorBrewer" %in% rownames(installed.packages()) == FALSE) {install.packages("RColorBrewer")}
if("wordcloud" %in% rownames(installed.packages()) == FALSE) {install.packages("wordcloud")}
if("mvoutlier" %in% rownames(installed.packages()) == FALSE) {install.packages("mvoutlier")}
if("dtw" %in% rownames(installed.packages()) == FALSE) {install.packages("dtw")}
if("reshape2" %in% rownames(installed.packages()) == FALSE) {install.packages("reshape2")}
if("tidyr" %in% rownames(installed.packages()) == FALSE) {install.packages("tidyr")}
if("RTextTools" %in% rownames(installed.packages()) == FALSE) {install.packages("RTextTools")}
if("lda" %in% rownames(installed.packages()) == FALSE) {install.packages("lda")}
if("data.table" %in% rownames(installed.packages()) == FALSE) {install.packages("data.table")}
if("dplyr" %in% rownames(installed.packages()) == FALSE) {install.packages("dplyr")}
if("NISTunits" %in% rownames(installed.packages()) == FALSE) {install.packages("NISTunits")}

#Manditory
if("forecast" %in% rownames(installed.packages()) == FALSE) {install.packages("forecast")}
if("lmtest" %in% rownames(installed.packages())==FALSE){install.packages("lmtest")}
if("CausalImpact" %in% rownames(installed.packages()) == FALSE) {install.packages("CausalImpact")}
if("ca" %in% rownames(installed.packages()) == FALSE) {install.packages("ca")}
if("tidyr" %in% rownames(installed.packages()) == FALSE) {install.packages("tidyr")}
if("tidyr" %in% rownames(installed.packages()) == FALSE) {install.packages("tidyr")}
if("tidyr" %in% rownames(installed.packages()) == FALSE) {install.packages("tidyr")}


#Other packages we use in the clas
if("tidyr" %in% rownames(installed.packages()) == FALSE) {install.packages("tidyr")}
if("stringr" %in% rownames(installed.packages()) == FALSE) {install.packages("stringr")}
if("rvest" %in% rownames(installed.packages()) == FALSE) {install.packages("rvest")}
if("SnowballC" %in% rownames(installed.packages()) == FALSE) {install.packages("SnowballC")}
if("proxy" %in% rownames(installed.packages()) == FALSE) {install.packages("proxy")}
if("stringi" %in% rownames(installed.packages()) == FALSE) {install.packages("stringi")}
if("tm" %in% rownames(installed.packages()) == FALSE) {install.packages("tm")}
if("XML" %in% rownames(installed.packages()) == FALSE) {install.packages("XML")}
if("RCurl" %in% rownames(installed.packages()) == FALSE) {install.packages("RCurl")}
if("tidyr" %in% rownames(installed.packages()) == FALSE) {install.packages("tidyr")}


# SCRIPT_REAL("
# i<-.arg1;
#             u<-.arg2;
#             dat<-data.frame(x= i[!is.na(i)],y= u[!is.na(u)])
#             mod <- nls(y ~ sin(alpha * x),data=dat, start = list(alpha = 0.4));
#             ss <- seq(.arg5[1], .arg4[1], by = .arg3[1]);
#             fit = predict(mod, newdata = data.frame(x = ss));",
#             ATTR([X]),MAX([Y]),[Coarseness (lines)],WINDOW_MAX(MAX([X])),WINDOW_MIN(MAX([X])))
curveexample <- read_csv("~/My Tableau Repository/Tableau Advanced Class/R Project/The Data/curveexample.csv")
curveexample <- data.frame(curveexample)
i<-curveexample$X
u<-curveexample$Y
dat<-data.frame(x= i[!is.na(i)],y= u[!is.na(u)])
mod <- nls(y ~ sin(alpha * x),data=dat, start = list(alpha = 0.4));
plot(fit)
ss <- seq(min(curveexample$X),max(curveexample$X), by = 1);
fit = predict(mod, newdata = data.frame(x = ss));
## 
fit <- lm(`CO2 emissions (kt)` ~ ., data=ChinaFinalModelData)
##Make the QQ and Residual Plots
# plot(fit) #The simple way but does not work in Tableau
myresiduals <- fit$residuals #to get Residuals
fittedestimate <- fit$fitted.values
mystdres <- rstandard(fit)



# library(CausalImpact)
# post.period <- c(11, 21);
# pre.period <- c(1,10); 
# 
# impact <- CausalImpact(dat, pre.period, post.period);



                 