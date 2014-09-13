#!/bin/bash

source env.sh

echo "Pull data from ActiveMQ queue" 
echo

## should check if MQ is available
nc -z $MQ_SRV $MQ_PORT
status=$?

if [ $status -ne 0 ]; then
	echo "Error: Apache ActiveMQ server is not UP"
	echo "Please check if server is listening on host: $MQ_SRV, port: $MQ_PORT"
	exit
fi
	
Try cat $F | perl $ANALYS/mq_puller.pl $MQ_SRV $MQ_PORT $MQ_QUEUE $MQ_USER $MQ_PASS 

