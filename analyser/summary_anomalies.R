args <- commandArgs(trailingOnly=T)

if (length(args) < 2) {
	stop("Enter 2 arguments: <Input CSV file> <output file>")
}

summary.file <- args[1]
result.file <- args[2]

source("summary_cfg.R")

library(plyr)

SUM <- read.csv(summary.file)
SUMF <- mutate(SUM, pattern=gsub(";1..","",pattern)) # remove all provisional responses
SUMF <- mutate(SUMF, out.ok=grepl(pattern.ok,pattern), out.busy=grepl(pattern.busy,pattern), out.cxl=grepl(pattern.cancel,pattern), out.block=grepl(pattern.block,pattern), out.cred=grepl(pattern.cred,pattern))
SUMF <- mutate(SUMF, out.anomaly=(out.ok==F & out.cxl==F & out.busy==F & out.block==F & out.cred==F) ) 

# output HLE dataset structure
hle.col <- c("ts","type","sev","detail","ts_ini","gen","cid")
HLE <- data.frame(ts=double(),type=character(),sev=character(),detail=character(), ts_ini=double(), gen=character(), cid=character())

# initialize timestamps
ts <- as.numeric(Sys.time())
pts <- as.POSIXct(Sys.time())

# anomaly events from sequences
ANOM <- SUMF[SUMF$out.anomaly==T,c("key", "ts_ini", "pattern")]

# if we have anomalies, include in HLE dataframe 
if (dim(ANOM)[1] > 0) {
	ANOM <- rename(ANOM, c("key"="cid", "pattern"="detail"))
	ANOM <- mutate(ANOM, type="SEQ", sev="CRITICAL", ts=ts, gen="summary")
	HLE <- ANOM[hle.col] 
}

# proportion table for regular calls

P <- count(SUMF, vars=c("out.ok","out.cxl","out.busy","out.block","out.cred", "out.anomaly"))
regular.total <- sum(P[!P$out.anomaly,]$freq)
perc.cxl <- sum(P[P$out.cxl,]$freq)/regular.total*100
perc.busy <- sum(P[P$out.busy,]$freq)/regular.total*100
perc.block <- sum(P[P$out.block,]$freq)/regular.total*100
perc.nocred <- sum(P[P$out.nocred,]$freq)/regular.total*100

#perc <- cbind(perc.cxl, perc.busy, perc.block, perc.nocred)
#thr <- cbind(thr.perc.cxl, thr.perc.busy, thr.perc.block, thr.nocred)

checkProportion <- function(p, t, col) {
	if (p >= t) {
		cbind(ts=ts, type="PERF", sev="WARNING",detail=sprintf("%s ge %f %f", col, t, p),ts_ini=ts*1000,gen="summary", cid=sprintf("%s-%s",col,pts))
	}
}

HLE <- rbind(HLE, checkProportion(perc.cxl, thr.perc.cxl, "perc.cxl"), checkProportion(perc.busy, thr.perc.busy, "perc.busy"), checkProportion(perc.block, thr.perc.block, "perc.block"), checkProportion(perc.nocred, thr.perc.nocred, "perc.nocred"))

write.csv(HLE, result.file)
