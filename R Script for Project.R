#required libraries
library(zoo)
#import files
df <- read.csv(choose.files())
itable <- read.csv(choose.files())
ltable <- read.csv(choose.files())

#I must have miscounted or something. There are about 7 extra rows in each DF
#When building final functions, change dataframes to matrices where possible

#Works
ShortRollAvg <- as.data.frame(rollmean(df[,3], 13))
LongRollAvg <- as.data.frame(rollmean(df[,3], 62))
LongLCycle <- as.data.frame(2*diff(as.matrix(LongRollAvg), lag = 26))
#Works LTrendDirection
LTrendDirection <- matrix(ncol=1, nrow = nrow(LongLCycle))
LTrendDirection[1,1] <- 1
for(i in 1:nrow(LongLCycle)){
   LTrendDirection [i+1,] <- ifelse(LongLCycle[i+1,] == LongLCycle[i,], LTrendDirection[i], 
           ifelse(LongLCycle[i+1,]> LongLCycle[i,], 1,-1))
}
#Works, will be more accurate once columns are arranged
PeakOrTrough <- matrix(ncol = 1, nrow = nrow(LTrendDirection)-1)
PeakOrTrough[1,1] <- LongLCycle[1,1]
for (j in 1:(nrow(LTrendDirection)-1)){
    PeakOrTrough[j+1] <- ifelse(LTrendDirection[j+1]==LTrendDirection[j,], PeakOrTrough[j,], 
                                LongLCycle[j,])
}
PeakOrTrough <- as.matrix(PeakOrTrough)
#Works
DLCycle <- data.frame(LongLCycle - PeakOrTrough)
#Works
WksSince <- matrix(ncol = 1, nrow = nrow(LTrendDirection))
WksSince[1,1]<-0
for(k in 1:nrow(WksSince)){
    WksSince[k+1,] <- ifelse(PeakOrTrough[k+1,]==PeakOrTrough[k,], (WksSince[k,]+1), 1)
}

#Works
prjctchng <- as.data.frame(cbind(DLCycle, WksSince))
prjctchng$WksSince <- prjctchng$WksSince+1
prjctchng <- prjctchng[2:nrow(prjctchng),]
prjctchng$index <- data.frame(c(1:nrow(prjctchng)))
prjctchng <- merge(prjctchng, ltable, by.x = "WksSince", by.y = "Week", all.x = TRUE)
prjctchng$Keep <- prjctchng$Value * prjctchng$rollmean.df...3...62.
prjctchng <- prjctchng[order(prjctchng$index),]
prjctchng <- as.matrix(prjctchng[,5])



