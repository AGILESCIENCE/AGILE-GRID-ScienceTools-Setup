#!/bin/bash

# Copyright (c) 2016, AGILE team
# Authors: Andrea Zoli <zoli@iasfbo.inaf.it>
#
# Any information contained in this software is property of the AGILE TEAM
# and is strictly private and confidential. All rights reserved.

# Use with a cron line like the following:
#
#   */5 * * * * $HOME/solo -port=1300 $HOME/transfer.sh >> $HOME/transfer.log 2>&1
#
# The cronline uses the solo script.

trap exit SIGINT SIGTERM

TIMEOUT=5
MAX_RETRIES=12

retry()
{
    i=0
    false
    while [[ $? -ne 0 && $i -lt $MAX_RETRIES ]] ;
    do
        i=$(($i+1))
        $@
    done
    if [ $i -eq $MAX_RETRIES ]
    then
        date
        echo "Err: reached the maximum number of $MAX_RETRIES retries with $TIMEOUT seconds of timeout!"
        exit 1
    fi
}

remote=192.167.166.46
tmplogdir=$HOME/tmplog
tmpevtdir=$HOME/tmpevt

date
echo "Beginning the transfert.."

rm -r $tmplogdir
mkdir $tmplogdir
log_files=$(mysql -s -B -hagiles9 -ugs agile2 -e "SELECT filename FROM PIPE_ProductFile WHERE (type='LOG') AND datemin>=DATE_SUB(NOW(), INTERVAL 1 MONTH);")
for file in $log_files ; do
    ln -s /storage1/agile/agile2/qlstd/$file $tmplogdir/$(basename $file)
done
retry rsync -rLptgoDvz --timeout=$TIMEOUT ${tmplogdir}/ bulgarelli@$remote:/ASDC_PROC2/DATA_2/LOG/

rm -r $tmpevtdir
mkdir $tmpevtdir
evt_files=$(mysql -s -B -hagiles9 -ugs agile2 -e "SELECT filename FROM PIPE_ProductFile WHERE (type='EVT__FM') AND datemin>=DATE_SUB(NOW(), INTERVAL 1 MONTH);")
for file in $evt_files ; do
    ln -s /storage1/agile/agile2/qlstd/$file $tmpevtdir/$(basename $file)
done
retry rsync -rLptgoDvz --timeout=$TIMEOUT ${tmpevtdir}/ bulgarelli@$remote:/ASDC_PROC2/FM3.119_2/EVT/

echo "Rebuilding indices.."
ssh -o ConnectTimeout=$TIMEOUT -o ConnectionAttempts=$MAX_RETRIES bulgarelli@$remote "/home/bulgarelli/buildindex.sh"
if [[ $? -ne 0 ]] ; then
    date
    echo "Err: reached the maximum number of $MAX_RETRIES retries with $TIMEOUT seconds of timeout!"
    exit 1
fi

echo "Deleting old files.."
retry rsync -rLptgoDvzn --delete --timeout=$TIMEOUT ${tmplogdir}/ bulgarelli@$remote:/ASDC_PROC2/DATA_2/LOG/
retry rsync -rLptgoDvzn --delete --timeout=$TIMEOUT ${tmpevtdir}/ bulgarelli@$remote:/ASDC_PROC2/FM3.119_2/EVT/

date
echo "Transfer complete."
