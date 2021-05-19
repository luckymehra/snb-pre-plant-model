setwd("C:/Users/path-to-folder")
library(randomForest)
library(foreign)

for (i in 1:15){
  obj_name = paste('SNB maxdis model partition',i,sep='_')
  file_name = file.path(paste(obj_name,'xlsx',sep='.'))
  
  library(XLConnect)  
  snb <- readWorksheet(loadWorkbook(file_name),sheet=1)
  detach("package:XLConnect",unload=TRUE)
  snb.train = snb[which(snb$dataset==1),]
  snb.test = snb[which(snb$dataset==3),]
  myvars = c("longitude", "latitude", 
             "PCR", "hostres", "seedtrtR", "seedrtR", "maxdisM")
#  "PCR", "tillR",
  snb.train = snb.train[myvars]
  snb.test = snb.test[myvars]
  
  
  set.seed(21)
  a = randomForest(maxdisM ~ ., data=snb.train,
                                ntree=300,
                                mtry=3,
                                nodesize=8,
#                                 maxnodes=65,
                                importance=TRUE,
                                proximity=TRUE,
                                na.action=na.omit)
  predict(a,snb.test)->test.pred
  
  test.pred.1=cbind(snb.test$maxdisM,test.pred)
  colnames(test.pred.1)=c("obs_dis","pred_dis")
  rownames(test.pred.1)=NULL
  
  library(xlsx)
  exp.obj=paste('RF pred test pcr',i,sep='_')
  exp.file=file.path(paste(exp.obj,'xlsx',sep='.'))
  write.xlsx(test.pred.1, exp.file)
  detach("package:xlsx",unload=TRUE)
}


                        
# save(maxdis.rf,file="maxdis.rf.Rdata")
#rm(maxdis.rf)
#load("maxdis.rf.Rdata")
#print(maxdis.rf)-> rfprint


