#!/bin/bash

source env.sh


echo "*************************************"
echo "* Source files in $SOURCE"
echo "* Temporary files in $TEMP"
echo "* Final result in $DEST"
echo "*************************************"
echo
echo "* Pusher" 
echo

## should check if elasticsearch is available
nc -z $ELASTIC_SRV $ELASTIC_PORT
status=$?
if [ $status -ne 0 ]; then
    echo "Error: ElasticSearch server is not UP"
    echo "Please check if server is listening on host: $ELASTIC_SRV, port: $ELASTIC_PORT"
    exit
fi

LE_FILE=$DEST/full_le.dmp

## should check if has LEs to push
if [ ! -f $LE_FILE ]; then
    echo "File containing serialized LEs not found.($LE_FILE)"
    echo "Did the map reduce steps finished successfully?"
    exit
fi

echo "* Going to create indexes for $ELASTIC_INDEX on $ELASTIC_SRV: $ELASTIC_PORT"
echo

bash $ANALYS/create_index.sh $ELASTIC_SRV $ELASTIC_PORT $ELASTIC_INDEX

echo
echo "* Going to send summarized events to analytic database"
echo

cat $LE_FILE | perl $ANALYS/pusher_summary.pl $ELASTIC_SRV $ELASTIC_PORT $ELASTIC_INDEX > /dev/null

echo "* finished sending summarized events"
echo

echo "* Going to send full event sequences to analytic database"
echo
cat $LE_FILE | perl $ANALYS/pusher.pl $ELASTIC_SRV $ELASTIC_PORT $ELASTIC_INDEX > /dev/null

echo "* finished sending events"
echo
