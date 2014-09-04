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

QUERY="{
    \"query\" : {
            \"filtered\" : {
                \"filter\" : {
                    \"bool\" : {
                        \"should\" : [
                            {\"regexp\" : {
							    \"cseq\" : { \"value\" : \"invite\"} 
							    }
							},
                            {\"regexp\" : {
							    \"cseq\" : { \"value\" : \"ack\"} 
							    }
							},
							{ \"term\" : { \"type\" : \"n\" }} 
                        ]
                    }
                }
            }
    },
    \"aggs\": {
        \"callid_agg\": {
            \"terms\": { \"field\" : \"callid\", \"size\" : $SIZE },
            \"aggs\": {
                \"ts_name\" : { \"max\": {\"field\": \"ts_diff\"}},
                \"tsms_end\": { \"max\": {\"field\":\"tsms\"}},
                \"tsms_ini\": { \"min\": {\"field\":\"tsms\"}},
				\"mean_req_ts\" : {
					\"avg\" : { \"field\": \"req_ts\" }
				}, 
				\"mean_last_ts\" : {
					\"avg\" : { \"field\": \"last_ts\" }
				},           
                \"res_180\" : {
                    \"filter\" : { \"term\" : {\"res\" : \"180\"}},
				    \"aggs\" : {
				        \"req_ts\" : {
				            \"avg\": { \"field\": \"req_ts\" }
				        },
				        \"last_ts\" : {
				            \"avg\": { \"field\": \"last_ts\" }
				        }
				    }
				},
                \"res_486\" : {
                    \"filter\" : { \"term\" : {\"res\" : \"486\"}},
				    \"aggs\" : {
				        \"req_ts\" : {
				            \"avg\": { \"field\": \"req_ts\" }
				        },
				        \"last_ts\" : {
				            \"avg\": { \"field\": \"last_ts\" }
				        }
				    }
				},
                \"res_487\" : {
                    \"filter\" : { \"term\" : {\"res\" : \"487\"}},
				    \"aggs\" : {
				        \"req_ts\" : {
				            \"avg\": { \"field\": \"req_ts\" }
				        },
				        \"last_ts\" : {
				            \"avg\": { \"field\": \"last_ts\" }
				        }
				    }
				},
               \"res_402\" : {
                    \"filter\" : { \"term\" : {\"res\" : \"402\"}},
				    \"aggs\" : {
				        \"req_ts\" : {
				            \"avg\": { \"field\": \"req_ts\" }
				        },
				        \"last_ts\" : {
				            \"avg\": { \"field\": \"last_ts\" }
				        }
				    }
				},
               \"res_403\" : {
                    \"filter\" : { \"term\" : {\"res\" : \"403\"}},
				    \"aggs\" : {
				        \"req_ts\" : {
				            \"avg\": { \"field\": \"req_ts\" }
				        },
				        \"last_ts\" : {
				            \"avg\": { \"field\": \"last_ts\" }
				        }
				    }
				},
                 \"res_200\" : {
                    \"filter\" : { \"term\" : {\"res\" : \"200\"}},
				    \"aggs\" : {
				        \"req_ts\" : {
				            \"avg\": { \"field\": \"req_ts\" }
				        },
				        \"last_ts\" : {
				            \"avg\": { \"field\": \"last_ts\" }
				        }
				    }
				},
				\"res_4xx\" : {
                    \"filter\" : {
                		\"regexp\" : {
							\"res\" : {
								\"value\" : \"4..\"
							}
						}
					},
				    \"aggs\" : {
				        \"req_ts\" : {
				            \"avg\": { \"field\": \"req_ts\" }
				        },
				        \"last_ts\" : {
				            \"avg\": { \"field\": \"last_ts\" }
				        }
				    }
				},
				\"res_5xx\" : {
                    \"filter\" : {
                		\"regexp\" : {
							\"res\" : {
								\"value\" : \"5..\"
							}
						}
					},
				    \"aggs\" : {
				        \"req_ts\" : {
				            \"avg\": { \"field\": \"req_ts\" }
				        },
				        \"last_ts\" : {
				            \"avg\": { \"field\": \"last_ts\" }
				        }
				    }
				},
				\"res_6xx\" : {
                    \"filter\" : {
                		\"regexp\" : {
							\"res\" : {
								\"value\" : \"6..\"
							}
						}
					},
				    \"aggs\" : {
				        \"req_ts\" : {
				            \"avg\": { \"field\": \"req_ts\" }
				        },
				        \"last_ts\" : {
				            \"avg\": { \"field\": \"last_ts\" }
				        }
				    }
				},
				\"req_ack\" : {
                    \"filter\" : { \"term\" : {\"req\" : \"ACK\"}}
				}
			}
		}
	}
}"

F=(key mean_req_ts.value mean_last_ts.value tsms_ini.value  tsms_end.value  ts_name.value  res_180.doc_count  res_180.req_ts.value  res_180.last_ts.value  res_487.doc_count  res_487.req_ts.value  res_487.last_ts.value  res_486.doc_count  res_486.req_ts.value  res_486.last_ts.value  res_402.doc_count  res_402.req_ts.value  res_402.last_ts.value  res_403.doc_count  res_403.req_ts.value  res_403.last_ts.value  res_4xx.doc_count  res_4xx.req_ts.value  res_4xx.last_ts.value  res_5xx.doc_count  res_5xx.req_ts.value  res_5xx.last_ts.value  res_6xx.doc_count  res_6xx.req_ts.value  res_6xx.last_ts.value  res_200.doc_count  res_200.req_ts.value  res_200.last_ts.value  req_ack.doc_count)

TITLE=$(echo ${F[*]} | perl -lane 'print join ",", map { "$_" } @F; print "\n";' )
FIELDS=$(echo ${F[*]} | perl -lane 'print join ",", map { ".$_" } @F' )

JQ='.["aggregations"].callid_agg.buckets[] | ['$FIELDS'] | @csv'

echo $TITLE > $FILE
curl http://$HOST:$PORT/events/event_sequence/_search?search_type=count -d "$QUERY" | jq -r "$JQ" >> $FILE

#Rscript agg_checks.R $FILE

