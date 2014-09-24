#install.packages("RODBC")

#INITIALIZE LIBRARIES
library(RODBC)
library("parallel")
library("randomForest")
library("rpart")
library("e1071")
library("randomForest")
library("gbm")
library("klaR")

#Set Globals
setwd("C:\\Users\\Administrator\\Documents\\GitHub\\HiggsBoston")
options(scipen=999)

#GET DATA
myconn = odbcConnect("HB")
train = sqlQuery(myconn, "select * from training")
close(myconn)
train.input = subset(train, select=-c(EventId))
train.input = cbind (train.input[32:32], sapply(train.input[1:31],as.numeric))

model = randomForest(Label~., data=train.input)

myconn = odbcConnect("HB")
test = sqlQuery(myconn, "select * from test")
close(myconn)
test.input = subset(test, select=-c(EventId))
test.input  = sapply(test.input[1:30], as.numeric)

Predicted.test = cbind(test, predicted = predict(model, test.input, interval="predict", type="response"))
Predicted.test.prob = cbind(Predicted.test, predictedp = predict(model, test.input, interval="predict", type="prob"))
Predicted.test.prob = cbind(Predicted.test.prob, rank = sapply(rank(Predicted.test.prob[33:33]), as.numeric))

out = c("EventId",  "rank", "predictedp.class")
Predicted.test.prob$rank = format(Predicted.test.prob$rank, scientific = FALSE)
write.csv(Predicted.test.prob[out], "data\\resultsRF.csv", row.names = FALSE)
