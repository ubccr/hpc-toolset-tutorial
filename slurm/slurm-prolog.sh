#!/bin/sh

jobdatelong=`date +%Y%m%d.%H.%M.%S`

logyear=`echo $jobdatelong | cut -b 1-4`
logmonth=`echo $jobdatelong | cut -b 5-6`
logday=`echo $jobdatelong | cut -b 7-8`

hostname=`hostname`

logdir="/home/pcp/$logyear/$logmonth/$hostname/$logyear-$logmonth-$logday";

mkdir -p $logdir
chown pcp:pcp $logdir

sudo -u pcp /usr/bin/env PMLOGGER_PROLOG=yes pmlogger -c /etc/pcp/pmlogger/pmlogger-supremm.config -s 1 -l /tmp/job-$SLURM_JOB_ID-begin-$jobdatelong.log $logdir/job-$SLURM_JOB_ID-begin-$jobdatelong > /dev/null 2>&1

exit 0
