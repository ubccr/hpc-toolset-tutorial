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
        if [ -f "/xdmod/setup.sh" ]; then
            /xdmod/setup.sh
        fi
        /srv/xdmod/scripts/xdmod-setup-sso.sh
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

        #------------------------
        # The xdmod-setup interactive script includes menu items for all of the
        # common basic Open XDMoD configuration.  The
        # /etc/xdmod/portal_settings.ini file can always be manually edited for
        # site-specific configuration For the demo we enable the CORS setting
        # to allow the Open XDMoD server to process requests from within
        # OnDemand. In a production system this should be set to the
        # appropriate address of the OnDemand webserver.
        #------------------------
        sed -i 's%domains = ""%domains = "https://localhost:3443"%g' /etc/xdmod/portal_settings.ini

        echo "Open XDMoD Import: Hierarchy"
        sudo -u xdmod xdmod-import-csv -t hierarchy -i /srv/xdmod/hierarchy.csv

        #------------------------
        # Ingest slurm job data
        #------------------------
        echo "---> Open XDMoD Import: slurm hpc"
        sudo -u xdmod xdmod-slurm-helper -r hpc
        echo "---> Open XDMoD: Ingest"
        sudo -u xdmod xdmod-ingestor

        echo "---> Open XDMoD Setup: Job Performance"
        expect /srv/xdmod/scripts/xdmod-setup-supremm.tcl | col -b
        echo "---> Open XDMoD Aggregate: Job Performance"
        sudo -u xdmod aggregate_supremm.sh

        echo "---> supremm setup"
        export TERMINFO=/bin/bash
        export TERM=linux
        /srv/xdmod/scripts/supremm.py

        echo "---> XDMoD Open OnDemand module setup"
        expect /srv/xdmod/scripts/xdmod-setup-ondemand.tcl | col -b

        echo "---> XDMoD Open OnDemand ingest historical data"
        chown hpcadmin:xdmod -R /scratch/ondemand/logs
        sudo -u xdmod xdmod-ondemand-ingestor -r ondemand -u https://localhost:3443 -d /scratch/ondemand/logs
        sudo -u xdmod xdmod-ingestor
        sudo -u xdmod xdmod-ondemand-ingestor -r ondemand -u https://localhost:3443 -d /scratch/ondemand/logs

        echo "---> Make sure we have a place to keep our backups"
        mkdir -p /srv/xdmod/backups
    fi
    echo "---> Staring php-fpm"
    mkdir -p /run/php-fpm
    php-fpm

    echo "---> Starting HTTPD on xdmod..."
    # Sometimes on shutdown pid still exists, so delete it
    rm -f /var/run/httpd/httpd.pid
    /usr/sbin/httpd -DFOREGROUND

fi

exec "$@"
