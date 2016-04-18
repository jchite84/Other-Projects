library(zoo)
df <- read.csv(choose.files())

#Works
ShortRollAvg <- as.data.frame(rollmean(df[,3], 13))
LongRollAvg <- as.data.frame(rollmean(df[,3], 62))
LongLCycle <- as.data.frame(2*diff(as.matrix(LongRollAvg), lag = 26))



