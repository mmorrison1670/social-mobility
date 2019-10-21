#Gregory Bruich, Ph.D.
#Economics 1152, Spring 2019
#Harvard University
#Send suggestions and corrections to gbruich@fas.harvard.edu

### SUPER LEARNER ###
if (!require(rpart)) install.packages("rpart"); library(rpart)
if (!require(dplyr)) install.packages("dplyr"); library(dplyr)
if (!require(SuperLearner)) install.packages("SuperLearner"); library(SuperLearner)

#### Easy Implementation of the Super Learner ####
#The super chooses the optimal weighted combination of algorithms that minimizes a cross validated loss function#
#See Rose (2013) "Mortality risk score prediction in an elderly population using machine learning."
#for a thorough and relatively non-technical review
#install.packages("SuperLearner")#
library(SuperLearner)

cdc_train <- cdc_deaths %>%
  filter(training==1)

cdc_test <- cdc_deaths %>%
  filter(training==1)

Y <- cdc_train$teenbrth_pooled_female_p25
X <- subset(cdc_train, select=vars)


#think about the algorithms you would like to include in your library#
#the super learner package has many choices built in# use listWrappers() to see all possible algorithms
#Here is an example library#
SL.library <- c("SL.glm", "SL.randomForest", "SL.rpart")

##Now we can create a super learner function
##SUPER LEARNER##
prediction.function <- SuperLearner(Y=Y, X = X, SL.library = SL.library, family = gaussian())
#where Y is the outcome, X is matrix of covariates you would like to consider, and family tells the 
#function whether or not your outcome is binary or continuous.

##to get new predictions using your function, you can use the predict function
out <-predict(prediction.function , newdata = cdc_test)
cdc_test$predicted <- out$pred

##Compare MSE
mse(cdc_deaths_oos$teenbrth_actual, cdc_deaths_oos$rank_hat_ols)
mse(cdc_deaths_oos$teenbrth_actual, cdc_deaths_oos$rank_hat_tree)
mse(cdc_deaths_oos$teenbrth_actual, cdc_deaths_oos$rank_hat_forest)
mse(cdc_test$teenbrth_actual, cdc_test$predicted)