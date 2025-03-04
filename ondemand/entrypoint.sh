#!/bin/bash
set -e

if [ "$1" = "serve" ]
then
    until nc -vzw 2 frontend 22
    do
        echo "-- Waiting for frontend ssh to become active ..."
        sleep 2
    done

    echo "---> Populating /etc/ssh/ssh_known_hosts from frontend for ondemand..."
    /usr/bin/ssh-keyscan frontend >> /etc/ssh/ssh_known_hosts

    echo "---> Starting SSSD on ondemand ..."
    # Sometimes on shutdown pid still exists, so delete it
    rm -f /var/run/sssd.pid
    /sbin/sssd --logger=stderr -d 2 -i 2>&1 &

    if [ -f "/opt/ood/nginx_stage/sbin/nginx_stage" ]; then
      echo "---> Cleaning NGINX ..."
      /opt/ood/nginx_stage/sbin/nginx_stage nginx_clean
    fi

    echo "---> Starting the MUNGE Authentication service (munged) on ondemand ..."
    gosu munge /usr/sbin/munged

    echo "---> Starting sshd on ondemand..."
    /usr/sbin/sshd -e

    if [ -f "/opt/ood/ood-portal-generator/sbin/update_ood_portal" ]; then
       echo "---> Running update ood portal..."
       /opt/ood/ood-portal-generator/sbin/update_ood_portal
    fi

    if [ -f "/usr/sbin/httpd" ]; then
       echo "---> Starting ondemand httpd24..."
       # Sometimes on shutdown pid still exists, so delete it
       rm -f /run/httpd/httpd.pid
       /usr/sbin/httpd -DFOREGROUND
    else
      tail -f /dev/null
    fi
fi

exec "$@"