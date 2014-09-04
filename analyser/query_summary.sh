HOST=localhost
PORT=9200
SIZE=10000
FILE=out.csv

if [ $# -eq 3 ]
	then
		HOST=$1
		PORT=$2
		FILE=$3
fi

F=(ts_name count ts_ini ts_end req_min req_std req_max req_mean last_min last_std last_max last_mean pattern)

TITLE="key,"$(echo ${F[*]} | perl -lane 'print join ",", map { "$_" } @F; print "\n";' )

FIELDS="._id,"$(echo ${F[*]} | perl -lane 'print join ",", map { "._source.$_" } @F' )

JQ='.["hits"].hits[] | ['$FIELDS'] | @csv'

echo $TITLE > $FILE
curl http://$HOST:$PORT/summaries/summary2/_search?size=$SIZE | jq -r "$JQ" >> $FILE 
