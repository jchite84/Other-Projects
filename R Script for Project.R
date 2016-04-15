 library(zoo)
 df <- read.csv(choose.files())
 
 ShortRollAvg <- as.data.frame(rollmean(df[,3], 13))
 LongRollAvg <- as.data.frame(rollmean(df[,3], 62))
 
