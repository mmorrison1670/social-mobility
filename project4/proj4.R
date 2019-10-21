#Gregory Bruich, Ph.D.
#Economics 1152, Spring 2019
#Harvard University
#Send suggestions and corrections to gbruich@fas.harvard.edu

rm(list=ls())
set.seed(123)

#Change this to location of your data
#Can use drop down menu in R studio: file->import data set-> from stata and find stata data set
setwd(dir = "C:/Users/gbruich/Projects/project4")

if (!require(foreign)) install.packages("foreign"); library(foreign)
if (!require(haven)) install.packages("haven"); library(haven)
if (!require(randomForest)) install.packages("randomForest"); library(randomForest)
if (!require(rpart)) install.packages("rpart"); library(rpart)

#Open stata data set
proj4 <- read_dta("project4.dta")
head(proj4)

#Storing predictor variables
#Order data in stata so all predictors appear in right-most columns
vars <- colnames(proj4[10:ncol(proj4)])

#OLS Regression
to_hat <- with(proj4[proj4$training==1,], lm(reformulate(vars, "kfr_pooled_p25")))
summary(to_hat)
rank_hat_ols = predict(to_hat, newdata=proj4)
summary(rank_hat_ols); hist(rank_hat_ols, xlab="Predicted Rates - OLS")

#Decision Tree or Regression Tree
one_tree <- rpart(reformulate(vars, "kfr_pooled_p25")
                  , data=proj4
                  , subset = training==1
                  , control = rpart.control(xval = 10)) ## this sets the number of folds for cross validation.

one_tree #Text Representation of Tree
rank_hat_tree <- predict(one_tree, newdata=proj4)
table(rank_hat_tree)
hist(rank_hat_tree, xlab="Predicted Rates - Single Tree")

plot(one_tree) # plot tree
text(one_tree) # add labels to tree
# print complexity parameter table using cross validation
printcp(one_tree)

#Random Forest from 1000 Bootstrapped Samples
forest_hat <- randomForest(reformulate(vars, "kfr_pooled_p25"), ntree=1000, mtry=11, maxnodes=100
                           ,importance=TRUE, do.trace=25, data=proj4[proj4$training==1,])
getTree(forest_hat, 250, labelVar = TRUE) #Text Representation of Tree
rank_hat_forest <- predict(forest_hat, newdata=proj4,type="response")
summary(rank_hat_forest); hist(rank_hat_forest, xlab="Predicted Rates - Random Forest")

#Export to stata
proj4$predictions_ols <- rank_hat_ols #Add OLS predictions to data set
proj4$predictions_tree <- rank_hat_tree #Add regression tree predictions to data set
proj4$predictions_forest <- rank_hat_forest #Add random forest predictions to data set
write.dta(proj4, "proj4_results.dta") #Save data as a stata .dta file

