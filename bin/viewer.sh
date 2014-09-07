#!/bin/bash

source env.sh

## should check if has LEs to push
if [ ! -f $LE_FILE ]; then
    echo "File containing serialized LEs not found.($LE_FILE)"
    echo "Did the map reduce steps finished successfully?"
    exit
fi

PS3="Please choose the option for viewing: "
options=("View summarized LEs" "View full LEs" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "View summarized LEs")
            cat $LE_FILE | perl $COLMAT/viewer_sum.pl | less
            ;;
        "View full LEs")
            cat $LE_FILE | perl $COLMAT/viewer.pl | less
            ;;
        "Quit")
            break
            ;;
        *) echo invalid option;;
    esac
done
