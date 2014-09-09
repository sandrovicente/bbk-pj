#!/bin/bash

source env.sh

function cleanup() {
    rm -f $TEMP/*.dmp
    rm -f $DEST/*.dmp
}

cleanup

echo "*************************************"
echo "* Source files in $SOURCE"
echo "* Temporary files in $TEMP"
echo "* Final result in $DEST"
echo "*************************************"
echo
echo "* Processing MR-1 on SIP log files" 
echo

cat $SOURCE/c_*.log | perl $COLMAT/collector.pl | awk '{ k1=$1; k2=$2; k3=$3; $1=$2=$3=""; print k1 "#" k2 "\t" k3 "\t" $0 }'  > $TEMP/sip_mr1.dmp 2> $TEMP/sip_mr1.err
echo
echo "* Processing  MR-2 on SIP log files" 
echo 
cat $TEMP/sip_mr1.dmp | sort | perl $COLMAT/collector_reduce.pl  |  sort | perl $COLMAT/merger_map.pl |  sort | perl $COLMAT/merger_reduce.pl  > $TEMP/sip_ordered.dmp 2> $TEMP/sip_ordered.err

n_sip_ordered=$(wc -l < $TEMP/sip_ordered.dmp)
echo "** MR-1 and MR-2 completed. Total of SIP sequences of events: $n_sip_ordered"
echo

echo "* Processing MR-3" 
echo
cat $NAMELOGS | awk '{k1=$1;k2=$2;k3=$3;$1=$2=$3=""; print k3 "\t" k2 " " k1 " " $0}' |  sort | perl $COLMAT/name_reduce.pl | awk '{ k = $5; $1=$5=""; print k "\tn\t" $0 }' > $TEMP/names1.dmp 

n_names1=$(wc -l < $TEMP/names1.dmp)
echo "** MR-3 completed. Total of name resolution aggregations: $n_names1"
echo

# 4.1. SIP collection for name matching

echo "* Processing MR-4 Map phase on SIP Events"
echo
cat $SOURCE/c_*.log | perl $COLMAT/sname_collector.pl | awk '{ k=$4; $4="";  print k "\ts\t" $0 }'  > $TEMP/names2.dmp  

n_names2=$(wc -l < $TEMP/names2.dmp)
echo "** Total of SIP Events ordered by email: $n_names2"
echo

# 4.2. cid name matching

echo "* Processing MR-4 on SIP Events and name resolution events"
echo
cat $TEMP/names1.dmp $TEMP/names2.dmp | sort | perl $COLMAT/resolv_reduce.pl |   perl -lane 'print "$F[0]\tn\t" . join "\t", map {"$_"} @F[1..7];' > $TEMP/cid_names.dmp 2> $TEMP/cid_names.err

n_cid_names=$(wc -l < $TEMP/cid_names.dmp)
echo "** Total of matches between SIP events and name resolution events: $n_cid_names"
echo


# 4.3. final SIP + name matching
echo "* Processing matching of ordered SIP events (MR-1) with name resolution events (MR-4)"
echo
cat $TEMP/cid_names.dmp $TEMP/sip_ordered.dmp | sort | perl $COLMAT/sipname_reduce.pl > $LE_FILE

n_full_le=$(wc -l < $LE_FILE)
echo "** Total of LEs generated: $n_full_le"

# to view in full format
#cat $LE_FILE | perl $COLMAT viewer.pl

# to view in summarized format
#cat $LE_FILE | perl viewer_sum.pl
