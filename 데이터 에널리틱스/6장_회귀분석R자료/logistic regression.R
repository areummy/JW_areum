####################################################
## Data Preprocessing
####################################################
kc <- read.table('./KidCreative.csv', header=TRUE, sep=','); head(kc); dim(kc)
is.na(kc);
table(is.na(kc))

cn <- colnames(kc); cn
cn[length(cn)+1] <- cn[2]; cn
cn[length(cn)+1] <- cn[1]; cn
cn <- cn[c(-1,-2)]; cn

kc <- subset(kc, select=cn); head(kc)
colnames(kc)[ncol(kc)] <- 'idx'; head(kc)


####################################################
## Data Splitting
####################################################
#install.packages('splitstackshape')
library(splitstackshape)

pSeed <- 12345
set.seed(pSeed)

kc.tra <- stratified(kc, 'Buy', 0.6)

## ONLY TEST for STRATIFIED SAMPLING
kc.tra <- kc.tra[order(kc.tra$idx),]
kc.rest <- kc[kc$idx %in% kc.tra$idx,]
kc.rest <- kc.rest[order(kc.rest$idx),]
table(kc.tra$idx == kc.rest$idx)
table(kc.tra$Income == kc.rest$Income)
## ONLY TEST for STRATIFIED SAMPLING

kc.rest <- kc[! kc$idx %in% kc.tra$idx,]

kc.val <- stratified(kc.rest, 'Buy', 0.5)
kc.tes <- kc.rest[! kc.rest$idx %in% kc.val$idx,]

kc.tra <- subset(kc.tra, select=-c(idx)); head(kc.tra)
kc.val <- subset(kc.val, select=-c(idx)); head(kc.val)
kc.tes <- subset(kc.tes, select=-c(idx)); head(kc.tes)

## ONLY TEST for STRATIFIED SAMPLING
t <- table(kc.tra$Buy); t; t[1]/t[2] 
t <- table(kc.val$Buy); t; t[1]/t[2] 
t <- table(kc.tes$Buy); t; t[1]/t[2]
## ONLY TEST for STRATIFIED SAMPLING

####################################################
## Logistic Regression(A_model)
####################################################
#install.packages('caret')
#install.packages('e1071')
library(caret)

A_model <- glm(Buy~., kc.tra, family=binomial)
All_var <- formula(A_model);
summary(A_model)

predTra <- predict(A_model, kc.tra, type='response')
Predict.tra <- ifelse(predTra>=0.5, 1, 0)
cTab.tra <- table(Actual=kc.tra$Buy, Predict.tra); cTab.tra
cM.tra <- confusionMatrix(t(cTab.tra), positive='1'); cM.tra
Accu.tra <- cM.tra$overall['Accuracy']
cTab.tra; Accu.tra

predVal <- predict(A_model, kc.val, type='response')
Predict.val <- ifelse(predVal>=0.5, 1, 0)
cTab.val <- table(Actual=kc.val$Buy, Predict.val); cTab.val
cM.val <- confusionMatrix(t(cTab.val), positive='1'); cM.val
Accu.val <- cM.val$overall['Accuracy']
cTab.val; Accu.val

####################################################
## Logistic Regression(S_model)
####################################################
startModel <- glm(Buy~1, kc.tra, family=binomial)
summary(startModel)

s_Result <- step(startModel, direction='both', scope=All_var)
s_var <- as.formula(s_Result$call); s_var

S_model <- glm(s_var, kc.tra, family=binomial)
summary(S_model)

predTra <- predict(S_model, kc.tra, type='response')
Predict.tra <- ifelse(predTra>=0.5, 1, 0)
cTab.tra <- table(Actual=kc.tra$Buy, Predict.tra); cTab.tra
cM.tra <- confusionMatrix(t(cTab.tra), positive='1'); cM.tra
Accu.tra <- cM.tra$overall['Accuracy']
cTab.tra; Accu.tra

predVal <- predict(S_model, kc.val, type='response')
Predict.val <- ifelse(predVal>=0.5, 1, 0)
cTab.val <- table(Actual=kc.val$Buy, Predict.val); cTab.val
cM.val <- confusionMatrix(t(cTab.val), positive='1'); cM.val
Accu.val <- cM.val$overall['Accuracy']
cTab.val; Accu.val
