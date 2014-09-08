export BASE=/home/sandro/cygsandroav/tmp/bbk
export SOURCE=$BASE/logs
export TEMP=$BASE/tmp
export DEST=$BASE/out

export NAMELOGS=$SOURCE/name_resolver.log
export LE_FILE=$DEST/full_le.dmp

export ELASTIC_SRV=localhost
export ELASTIC_PORT=9200
export ELASTIC_INDEX=telco

export MQ_SRV=localhost
export MQ_PORT=61613
export MQ_USER=admin
export MQ_PASS=admin

export MQ_QUEUE=HLE

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
