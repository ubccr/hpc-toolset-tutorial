#!/bin/bash

users='hpcadmin sfoster astewart'
opmodes='sleep stress timeout'

for ((node_count=1; node_count <= 2; node_count++)); do
    for user in $users; do
        for mode in $opmodes; do
                sudo -u $user -i -- sbatch -n $node_count --job-name=$user_$script_$node_count --export='ALL,MODE='$mode /usr/local/bin/example_job.sbatch
        done
    done
done
