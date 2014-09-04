# Patterns for anomaly finding

pattern.ok <- "INVITE;INVITE;INVITE;INVITE;200;200;200;200(;200)?;ACK;ACK;ACK;.*;OK"
pattern.ok.bye <- "INVITE;INVITE;INVITE;INVITE;200;200;200;200;.*ACK;ACK;ACK;.*BYE;BYE;BYE.*OK"
pattern.cancel <- "INVITE;.*;CANCEL.*;487;.*;ACK.*;OK"
pattern.busy <- "INVITE;.*;486;.*;ACK.*;OK"
pattern.block <- "INVITE;INVITE;INVITE;INVITE;403.*;OK"
pattern.cred <- "INVITE;INVITE;INVITE;INVITE;402.*;OK"

# Thresholds 

thr.perc.cxl=30
thr.perc.busy=5
thr.perc.block=1
thr.perc.nocred=5

