BASE=/home/sandro/cygsandroav/tmp/bbk
SOURCE=$BASE/logs
TEMP=$BASE/tmp
DEST=$BASE/out

NAMELOGS=$SOURCE/name_resolver.log
LE_FILE=$DEST/full_le.dmp

ELASTIC_SRV=localhost
ELASTIC_PORT=9200
ELASTIC_INDEX=telco

MQ_SRV=localhost
MQ_PORT=61613
MQ_USER=admin
MQ_PASS=admin

MQ_QUEUE=HLE

export COLMAT=`pwd`/../colmat
export ANALYS=`pwd`/../analyser
export PERL5LIB=$PERL5LIB:$COLMAT

function Try {
    "$@"
    local status=$?
    if [ $status -ne 0 ]; then
        echo "error with $1" >&2
                exit $status
    fi
}  
