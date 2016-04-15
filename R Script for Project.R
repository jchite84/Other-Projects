library(zoo)
df <- read.csv(choose.files())

#Works
ShortRollAvg <- as.data.frame(rollmean(df[,3], 13))
LongRollAvg <- as.data.frame(rollmean(df[,3], 62))

#Does Not Quite Work - But is Close 
for (i in 1:length(LongRollAvg[,1])){
  rounded[i,]<- as.data.frame((LongRollAvg[i+25,]-LongRollAvg[(i-25),])*2)
}