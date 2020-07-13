#!/bin/bash
set -e

host=mysql
user=xdmodapp
pass=ofbatgorWep0

if [ "$1" = "serve" ]
then
    echo "---> Starting SSSD on xdmod ..."
    # Sometimes on shutdown pid still exists, so delete it
    rm -f /var/run/sssd.pid
    /sbin/sssd --logger=stderr -d 2 -i 2>&1 &

    echo "---> Starting sshd on xdmod..."
    /usr/sbin/sshd -e

    echo "---> Starting the MUNGE Authentication service (munged) on xdmod ..."
    gosu munge /usr/sbin/munged

    echo "---> Starting sshd on xdmod..."
    /usr/sbin/sshd

    until echo "SELECT 1" | mysql -h $host -u$user -p$pass 2>&1 > /dev/null
    do
        echo "-- Waiting for database to become active ..."
        sleep 2
    done

    tables=$(mysql -u${user} -p${pass} --host ${host} -NB modw -e "SHOW TABLES")
    if [[ -n "$tables" ]]; then
        echo "Open XDMoD already initialized"
    else
        #------------------------
        # Run xdmod-setup
        #------------------------
        echo "---> Open XDMoD Setup: SSO..."
        /srv/xdmod/scripts/xdmod-setup-sso.sh
        echo "---> Open XDMoD Setup: start"
        expect /srv/xdmod/scripts/xdmod-setup-start.tcl | col -b
        echo "---> Open XDMoD Setup: hpc resource"
        expect /srv/xdmod/scripts/xdmod-setup-jobs.tcl | col -b
        echo "---> Open XDMoD Setup: finish"
        expect /srv/xdmod/scripts/xdmod-setup-finish.tcl | col -b

        echo "Open XDMoD Import: Hierarchy"
        xdmod-import-csv -t hierarchy -i /srv/xdmod/hierarchy.csv

        #------------------------
        # Ingest slurm job data
        #------------------------
        echo "---> Open XDMoD Import: slurm hpc"
        xdmod-slurm-helper -r hpc
        echo "---> Open XDMoD: Ingest"
        xdmod-ingestor

        echo "---> Open XDMoD Setup: Job Performance"
        expect /srv/xdmod/scripts/xdmod-setup-supremm.tcl | col -b
        echo "---> Open XDMoD Aggregate: Job Performance"
        aggregate_supremm.sh

        echo "---> supremm setup"
        export TERMINFO=/bin/bash
        export TERM=linux
        /srv/xdmod/scripts/supremm.py
    fi

    echo "---> Starting HTTPD on xdmod..."
    # Sometimes on shutdown pid still exists, so delete it
    rm -f /var/run/httpd/httpd.pid
    /usr/sbin/httpd -DFOREGROUND

fi

exec "$@"
