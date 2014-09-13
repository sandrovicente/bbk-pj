#export BASE=/home/sandro/cygsandro/work/prjtst/github/bbk-pj/var
export BASE=../var
export SOURCE=$BASE/log
export TEMP=$BASE/tmp
export DEST=$BASE/result

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

function CheckPack {
	
	# Check curl

	curl --version > /dev/null 2>&1 || { echo >2& "Missing curl. Please install it"; exit 1;}

	for X in JSON::XS LWP::Simple Net::Stomp; do
		perl -e "use $X" > /dev/null 2>&1 || { echo "Missing perl package $X. Please install it from 'cpan $X'."; exit 1;}
	done

	jq --version > /dev/null 2>&1 || { echo "Missing package jq. Please install it from here: http://stedolan.github.io/jq/download"; exit 1;}

	Rscript --version > /dev/null 2>&1 || { echo "Missing R. Please install R version 3.0 or higher."; exit 1; }

	Rscript -e 'library("plyr")' 2>&1 || { echo "R installed, but missing package 'plyr'. Please install it from cran"; exit 1; }
}
