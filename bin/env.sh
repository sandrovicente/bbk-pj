BASE=/home/sandro/cygsandroav/tmp/bbk
SOURCE=$BASE/logs
TEMP=$BASE/tmp
DEST=$BASE/out

NAMELOGS=$SOURCE/name_resolver.log
LE_FILE=$DEST/full_le.dmp


ELASTIC_SRV=localhost
ELASTIC_PORT=9200
ELASTIC_INDEX=telco

export COLMAT=`pwd`/../colmat
export ANALYS=`pwd`/../analyser
export PERL5LIB=$PERL5LIB:$COLMAT

