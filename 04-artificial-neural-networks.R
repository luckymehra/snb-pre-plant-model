setwd("C:/Users/path-to-folder")
library(nnet)
library(foreign)
library(caret)

for (i in 1:15){
  obj_name = paste('SNB maxdis model partition',i,sep='_')
  file_name = file.path(paste(obj_name,'xlsx',sep='.'))
  
library(XLConnect)  
snb <- readWorksheet(loadWorkbook(file_name),sheet=1)
detach("package:XLConnect",unload=TRUE)
snb.train = snb[which(snb$dataset==1),]
snb.test = snb[which(snb$dataset==3),]
myvars = c("longitude", "latitude",
           "residueM", "hostres", "seedtrtR", "seedrtR", "maxdisM")
#"PCR", "tillR",
snb.train = snb.train[myvars]
snb.test = snb.test[myvars]


#set.seed(27)
a = avNNet(maxdisM~.,
         data=snb.train,bag=F, size=12, decay=0.001,
         repeats=100, maxit=1000,linout=T, skip=T)

predict(a,snb.test)->test.pred

test.pred.1=cbind(snb.test$maxdisM,test.pred)
colnames(test.pred.1)=c("obs_dis","pred_dis")
rownames(test.pred.1)=NULL

library(xlsx)
exp.obj=paste('Neural Networks pred test resid caret12',i,sep='_')
exp.file=file.path(paste(exp.obj,'xlsx',sep='.'))
write.xlsx(test.pred.1, exp.file)
detach("package:xlsx",unload=TRUE)
}

#I ran the size=1 through 8, 6 was found to be optimun based on evaluation
# on test dataset

###########################
##
## FULL MODEL using ALL data
###########################

obj_name = paste('SNB maxdis model partition',1,sep='_')
file_name = file.path(paste(obj_name,'xlsx',sep='.'))

library(XLConnect)  
snb <- readWorksheet(loadWorkbook(file_name),sheet=1)
detach("package:XLConnect",unload=TRUE)

myvars = c("longitude", "latitude", 
           "residueM", "hostres", "seedtrtR", "seedrtR", "maxdisM")
# "PCR", "tillR",
snb = snb[myvars]

set.seed(703)
a = nnet(maxdisM~.,
         data=snb,size=12,maxit=1000,linout=T, skip=T,
        decay=0.001)

varImp(a)

# I ran the above code 20 times to get variable imortance measures
# for 10 runs of the nnet (20 neural networks with different seed each time)
#here are the seeds
# 164	702	528	79	19	39	250	882	
# 169	200	140	118	480	975	217	841	225	288	273	703



snb.pred=cbind(snb$maxdisM,a$fitted.values)
colnames(snb.pred)=c("obs_dis","pred_dis")
rownames(snb.pred)=NULL

library(xlsx)
exp.file=file.path(paste('Neural Networks pred full size 1','xlsx',sep='.'))
write.xlsx(snb.pred, exp.file)
detach("package:xlsx",unload=TRUE)

library(Rcpp)
library(devtools)
source_url('https://gist.githubusercontent.com/fawda123/7471137/raw/466c1474d0a505ff044412703516c34f1a4684a5/nnet_plot_update.r')
plot.nnet(a)

###########################
##
## FULL MODEL using ALL data
## and Caret package, avNNet
###########################

obj_name = paste('SNB maxdis model partition',1,sep='_')
file_name = file.path(paste(obj_name,'xlsx',sep='.'))

library(XLConnect)  
snb <- readWorksheet(loadWorkbook(file_name),sheet=1)
detach("package:XLConnect",unload=TRUE)

myvars = c("longitude", "latitude", 
           "residueM", "hostres", "seedtrtR", "seedrtR", "maxdisM")
#"PCR", "tillR",
snb = snb[myvars]

#set.seed(27)
library(caret)
#myTrainControl=trainControl(method="none")

a1 = avNNet(maxdisM~.,
         data=snb, bag=F, size=12, decay=0.001,
         repeats=100, maxit=1000,linout=T, skip=T)
a1

# a2grid=expand.grid(.size=1:20, .decay=0.001, .bag=F)
# fitControl <- trainControl(method = 'cv', number = 10)
# # 
# a2 = train(maxdisM~., data=snb,
#            method='avNNet', repeats=50, 
#            maxit=1000, linout=T, skip=T, 
#            tuneGrid=a2grid,
#            trControl=fitControl)
# a2
# a2$finalModel


fitted=predict(a1,snb)
snb.pred=cbind(snb$maxdisM,fitted)
colnames(snb.pred)=c("obs_dis","pred_dis")
rownames(snb.pred)=NULL

#plot(snb.pred)
#plot(lm(snb.pred[,1]~snb.pred[,2]))


library(xlsx)
exp.file=file.path(paste('Neural Networks pred full caret size 12','xlsx',sep='.'))
write.xlsx(snb.pred, exp.file)
detach("package:xlsx",unload=TRUE)


#  Code for calculating relative importance

a2 = train(maxdisM~., data=snb,
          method='avNNet',
          tuneGrid = expand.grid(.size =5,
                       .decay =0.0001,
                       .bag=F),
          repeats=100, maxit=1000,
          trace=FALSE,linout=T,skip=T
          )
varImp(a2,scale=TRUE)
varImp(a2,scale=F)



