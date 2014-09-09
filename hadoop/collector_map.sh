#/bin/sh
IFS= read var <<EOF
EOF
cat $var | perl collector.pl | awk '{ k1=$1; k2=$2; k3=$3; $1=$2=$3=""; print k1 "#" k2 "\t" k3 "\t" $0 }'
