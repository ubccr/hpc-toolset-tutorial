#!/bin/bash
set -e

host=mysql
user=xdmodapp
pass=ofbatgorWep0

if [ "$1" = "serve" ]
then
    echo "---> Starting SSSD on xdmod ..."
    /sbin/sssd

    echo "---> Starting the MUNGE Authentication service (munged) on xdmod ..."
    gosu munge /usr/sbin/munged

    until echo "SELECT 1" | mysql -h $host -u$user -p$pass 2>&1 > /dev/null
    do
        echo "-- Waiting for database to become active ..."
        sleep 2
    done

    tables=$(mysql -u${user} -p${pass} --host ${host} -NB modw -e "SHOW TABLES")
    if [[ -n "$tables" ]]; then
        echo "XDMoD already initialized"
    else
        echo "Running XDMoD setup and initial ingestion"
        #------------------------
        # Run xdmod-setup
        #------------------------
        expect /srv/xdmod/scripts/xdmod-setup-start.tcl | col -b
        expect /srv/xdmod/scripts/xdmod-setup-jobs.tcl | col -b
        expect /srv/xdmod/scripts/xdmod-setup-finish.tcl | col -b

        xdmod-import-csv -t hierarchy -i /srv/xdmod/hierarchy.csv

        #------------------------
        # Ingest slurm job data
        #------------------------
        xdmod-slurm-helper -v -r hpc
        xdmod-ingestor -v
    fi

    echo "---> Starting sshd on xdmod..."
    /usr/sbin/sshd

    echo "---> Starting XDMoD..."
    /usr/sbin/httpd -DFOREGROUND

fi

exec "$@"
