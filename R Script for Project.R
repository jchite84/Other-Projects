#required libraries
library(zoo)
#import files
df <- read.csv(choose.files())
itable <- read.csv(choose.files())
ltable <- read.csv(choose.files())
wt13 <- read.csv(choose.files())
wt52 <- read.csv(choose.files())

#I must have miscounted or something. There are about 7 extra rows in each DF
#When building final functions, change dataframes to matrices where possible

#Works
LongRollAvg <- as.matrix(rollmean(df[,3], 62))
LongLCycle <- as.matrix(2*diff(as.matrix(LongRollAvg), lag = 26))
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
DLCycle <- matrix(LongLCycle - PeakOrTrough)
#Works
WksSince <- matrix(ncol = 1, nrow = nrow(LTrendDirection))
WksSince[1,1]<-0
for(k in 1:nrow(WksSince)){
    WksSince[k+1,] <- ifelse(PeakOrTrough[k+1,]==PeakOrTrough[k,], (WksSince[k,]+1), 1)
}

#Works
prjctchng <- as.data.frame(cbind(DLCycle, WksSince))
prjctchng$V2 <- prjctchng$V2+1
prjctchng <- prjctchng[2:nrow(prjctchng),]
prjctchng$index <- matrix(c(1:nrow(prjctchng)))
prjctchng <- merge(prjctchng, ltable, by.x = "V2", by.y = "Week", all.x = TRUE)
prjctchng$Keep <- prjctchng$Value * prjctchng$V1
prjctchng <- prjctchng[order(prjctchng$index),]
prjctchng <- as.matrix(prjctchng[,5])

#Figure out which intermediate sets can be removed
rm()

#Short Calculations - Works
ShortRollAvg <- as.matrix(rollmean(df[,3], 13))
ShortLCycle <- as.matrix(6.5*diff(as.matrix(ShortRollAvg), lag = 8))

STrendDirection <- matrix(ncol=1, nrow = nrow(ShortLCycle))
STrendDirection[1,1] <- 1
for(i in 1:nrow(ShortLCycle)){
    STrendDirection [i+1,] <- ifelse(ShortLCycle[i+1,] == ShortLCycle[i,], STrendDirection[i], 
                                     ifelse(ShortLCycle[i+1,]> ShortLCycle[i,], 1,-1))
}

iPeakOrTrough <- matrix(ncol = 1, nrow = nrow(STrendDirection)-1)
iPeakOrTrough[1,1] <- ShortLCycle[1,1]
for (j in 1:(nrow(STrendDirection)-1)){
    iPeakOrTrough[j+1] <- ifelse(STrendDirection[j+1]==STrendDirection[j,], iPeakOrTrough[j,], 
                                ShortLCycle[j,])
}
iPeakOrTrough <- as.matrix(iPeakOrTrough)

iDLCycle <- matrix(ShortLCycle - iPeakOrTrough)

iWksSince <- matrix(ncol = 1, nrow = nrow(STrendDirection))
iWksSince[1,1]<-0
for(k in 1:nrow(iWksSince)){
    iWksSince[k+1,] <- ifelse(iPeakOrTrough[k+1,]==iPeakOrTrough[k,], (iWksSince[k,]+1), 1)
}

iprjctchng <- as.data.frame(cbind(iDLCycle, iWksSince))
iprjctchng$V2 <- iprjctchng$V2+1
iprjctchng <- iprjctchng[2:nrow(iprjctchng),]
iprjctchng$index <- matrix(c(1:nrow(iprjctchng)))
iprjctchng <- merge(iprjctchng, itable, by.x = "V2", by.y = "Week", all.x = TRUE)
iprjctchng$Keep <- iprjctchng$Value * iprjctchng$V1
iprjctchng <- iprjctchng[order(iprjctchng$index),]
iprjctchng <- as.matrix(iprjctchng[,6])

#Price Projections
projection <- matrix (ncol = 1, nrow = 13)
projection[1,1] <- ifelse(df[nrow(df),3]+(iprjctchng[nrow(iprjctchng),]+
                            prjctchng[nrow(prjctchng),])/2 < 0, 0.1,
                          df[nrow(df),3]+(iprjctchng[nrow(iprjctchng),]+
                                            prjctchng[nrow(prjctchng),])/2)

#Needs to update all other matricies within the loop. Fuck.
for (i in 2:14){
  projection[i,] <- ifelse(projection[i-1,]+(iprjctchng[i,]+
                                              prjctchng[nrow(prjctchng),])/2 < 0, 0.1,
                            df[3,nrow(df)]+(iprjctchng[nrow(iprjctchng),]+
                                              prjctchng[nrow(prjctchng),])/2)
}
