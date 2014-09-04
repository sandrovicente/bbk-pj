### Thresholds ###

# for call establishment (200 ok), 85% time between msgs is below 6s
thr.req.time <- 5000 # milliseconds

# for all messages altogether, for the ones that contain 200 ok, the distribution is
# quantile(X$mean_last_ts.value,c(50,75,80,85,90,95,100)/100,na.rm=TRUE)
#      50%       75%       80%       85%       90%       95%      100% 
# 1523.405  2888.250  3011.429  3163.221  3421.081  3720.101 83436.909 
thr.time.establishment <- 12000 # milliseconds

thr.message.count <- c(4,5) # min, max
