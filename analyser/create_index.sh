#!/bin/bash

HOST=localhost
PORT=9200
INDEX=anonym

if [ $# -eq 3 ]; then
    HOST=$1
    PORT=$2
    INDEX=$3
fi

curl -XPOST "http://$HOST:$PORT/s_$INDEX" -d ' 
{
	"mappings": {
		"summaries" : {
			"properties": { 
				"ts_name": {"type": "string", "index":"not_analyzed"},
					"count": {"type": "long"},
					"max": {"type": "long"},
					"mean": {"type": "double"},
					"min": {"type": "long"},
					"pattern": {"type": "string", "index":"not_analyzed"},
					"std": {"type": "double"},
					"ts_end": {"type": "long"},
					"ts_ini": {"type": "long"}
			}
		}
	}
}'


curl -XPOST "http://$HOST:$PORT/f_$INDEX" -d ' 
{
	"mappings": {
		"event_sequence" : {
			"properties": { 
				"callid":{"type":"string", "index":"not_analyzed"},
					"comp_name":{"type":"string", "index":"not_analyzed"},
					"component":{"type":"string", "index":"not_analyzed"},
					"cseq":{"type":"string"},
					"cseq_n":{"type":"string"},
					"from":{"type":"string"},
					"from_uri":{"type":"string", "index":"not_analyzed"},
					"last_ts":{"type":"long"},
					"origin":{"type":"string"},
					"req":{"type":"string", "index":"not_analyzed"},
					"req_ts":{"type":"long"},
					"res":{"type":"string", "index":"not_analyzed"},
					"result":{"type":"string"},
					"ret":{"type":"string"},
					"to":{"type":"string"},
					"to_uri":{"type":"string", "index":"not_analyzed"},
					"ts_diff":{"type":"long"},
					"ts_end":{"type":"long"},
					"ts_ini":{"type":"long"},
					"tsms":{"type":"long"},
					"type":{"type":"string"},
					"via":{"type":"string"},
					"via_l":{"type":"string"}

			}
		}
	}
}'

