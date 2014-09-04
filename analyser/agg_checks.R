args <- commandArgs(trailingOnly=T)

if (length(args) < 2) {
	stop("Enter 2 arguments: <Input CSV file> <output file>")
}

aggs.file <- args[1]
result.file <- args[2]

sprintf(">> [%s] -> [%s]", aggs.file, result.file) 

source("agg_cfg.R")

library(plyr)

F <- read.csv(aggs.file)

F.4xx <- F[with(F, res_4xx.doc_count > 0 & res_486.doc_count == 0 & res_487.doc_count ==0 & res_402.doc_count == 0 & res_403.doc_count ==0),]
F.5xx <- F[with(F, res_5xx.doc_count > 0) , ]
F.6xx <- F[with(F, res_6xx.doc_count > 0) ,]
F.2ACK <- F[with(F, res_200.doc_count > 0 & req_ack.doc_count > 0), ]
F.403 <- F[with(F, res_403.doc_count > 0) ,]
F.402 <- F[with(F, res_402.doc_count > 0) ,]
F.487 <- F[with(F, res_487.doc_count > 0) ,]
F.486 <- F[with(F, res_486.doc_count > 0) ,]

F.reg <- rbind(F.2ACK,F.403,F.402,F.487,F.486)
hle.cols = c("key", "tsms_ini.value", "mean_last_ts.value","msg_count","mean_last_ts","mean_req_ts","res_200.doc_count","res_403.doc_count","res_402.doc_count","res_487.doc_count","res_486.doc_count")

cols <- c("res_200", "res_403", "res_402", "res_487", "res_486")
sumCol <- function(X, src, t) { X[,t] <- apply(X, 1, function(x) { max(as.numeric(x[src]), na.rm=TRUE)}); X}

F.reg <- (sumCol(F.reg, paste(cols, "doc_count", sep="."), "msg_count"))
F.reg <- (sumCol(F.reg, paste(cols, "last_ts.value", sep="."), "mean_last_ts"))
F.reg <- (sumCol(F.reg, paste(cols, "req_ts.value", sep="."), "mean_req_ts"))

HLE <- mutate(F.reg[F.reg$mean_last_ts.value >= thr.req.time, hle.cols], detail=sprintf("mean_last_ts ge %f %f", thr.req.time, mean_last_ts.value)) 
HLE <- rbind(HLE, mutate(F.reg[F.reg$msg_count < thr.message.count[1], hle.cols], detail=sprintf("msg_count lt %d %d", thr.message.count[1], msg_count)))
HLE <- rbind(HLE, mutate(F.reg[F.reg$msg_count > thr.message.count[2], hle.cols], detail=sprintf("msg_count gt %d %d", thr.message.count[2], msg_count)))
HLE <- rbind(HLE, mutate(F.reg[F.reg$mean_req_ts >= thr.time.establishment, hle.cols], detail=sprintf("mean_req_ts ge %f %f", mean_req_ts, thr.time.establishment)))

ts <- as.numeric(Sys.time())
HLE <- mutate(HLE, cid=key, ts_ini=tsms_ini.value, type="PERF", sev="WARNING", gen="agg", ts=ts)

head(F.reg)

print("Full")
summary(F[c("mean_req_ts.value", "mean_last_ts.value")])
print("4xx")
summary(F.4xx[c("mean_req_ts.value", "mean_last_ts.value")])
print("5xx")
summary(F.5xx[c("mean_req_ts.value", "mean_last_ts.value")])
print("6xx")
summary(F.6xx[c("mean_req_ts.value", "mean_last_ts.value")])
print("2+ack")
summary(F.2ACK[c("mean_req_ts.value", "mean_last_ts.value")])

names(HLE)
write.csv(HLE[c("ts","type","sev","detail","ts_ini","gen","cid")], result.file)

