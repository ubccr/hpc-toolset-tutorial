#!/bin/bash
yesterday=`date +%Y-%m-%d --date="-1 day"`
tomorrow=`date +%Y-%m-%d --date="+1 day"`

xdmod-slurm-helper -r hpc --start-time $yesterday --end-time $tomorrow
xdmod-ingestor
indexarchives.py -a
summarize_jobs.py
aggregate_supremm.sh
