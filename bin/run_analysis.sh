#!/bin/bash

source env.sh

echo "*************************************"
echo "* Source files in $SOURCE"
echo "* Temporary files in $TEMP"
echo "* Final result in $DEST"
echo "*************************************"
echo
echo "* Analsys" 
echo

if [ $# -eq 1 ]; then
    send_to_mq=true
fi  

## should check if elasticsearch is available
nc -z $ELASTIC_SRV $ELASTIC_PORT
status=$?
if [ $status -ne 0 ]; then
    echo "Error: ElasticSearch server is not UP"
    echo "Please check if server is listening on host: $ELASTIC_SRV, port: $ELASTIC_PORT"
    exit
fi

echo "* Retrieve summarized data from analytic database"
echo
bash $ANALYS/query_summary.sh $ELASTIC_SRV $ELASTIC_PORT $ELASTIC_INDEX $TEMP/tmp_sum.csv
echo
echo "* File generated"

echo
echo "* Retrieve send data for analysis"
echo
pushd $ANALYS
Rscript summary_anomalies.R $TEMP/tmp_sum.csv $DEST/a_summary.csv
popd

echo "* Retrieve full LEs from analytic database"
echo
Try bash $ANALYS/query_full.sh $ELASTIC_SRV $ELASTIC_PORT $ELASTIC_INDEX $TEMP/tmp_full.csv
echo
echo "* File generated"

echo
echo "* Retrieve send data for analysis"
echo
pushd $ANALYS
Try Rscript agg_checks.R $TEMP/tmp_full.csv $DEST/a_agg.csv
popd

if [ $send_to_mq ]; then
    echo "** SEND TO MQ"


    ## should check if MQ is available
    nc -z $MQ_SRV $MQ_PORT

    if [ $status -ne 0 ]; then
        echo "Error: ElasticSearch server is not UP"
        echo "Please check if server is listening on host: $ELASTIC_SRV, port: $ELASTIC_PORT"
        exit
    fi

    for F in $DEST/*.csv; do
        
        Try cat $F | perl $ANALYS/mq_pusher.pl $MQ_SRV $MQ_PORT $MQ_QUEUE $MQ_USER $MQ_PASS 

        rm $F
    done

fi
