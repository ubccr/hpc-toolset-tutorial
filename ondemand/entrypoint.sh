#!/bin/bash
set -e

if [ "$1" = "serve" ]
then
    echo "---> Populating /etc/ssh/ssh_known_hosts from frontend for ondemand..."
    /usr/bin/ssh-keyscan frontend >> /etc/ssh/ssh_known_hosts

    echo "---> Starting SSSD on ondemand ..."
    # Sometimes on shutdown pid still exists, so delete it
    rm -f /var/run/sssd.pid
    /sbin/sssd --logger=stderr -d 2 -i 2>&1 &

    echo "---> Starting the MUNGE Authentication service (munged) on ondemand ..."
    gosu munge /usr/sbin/munged

    echo "---> Starting sshd on ondemand..."
    /usr/sbin/sshd -e

    echo "---> Starting ondemand-dex..."
    gosu ondemand-dex /usr/sbin/ondemand-dex serve /etc/ood/dex/config.yaml &

    echo "---> Setting git configs for hpcadmin"
    su hpcadmin bash -c "git config --global user.email hpcadmin@localhost"
    su hpcadmin bash -c "git config --global user.name 'HPC Admin'"

    echo "---> Starting ondemand httpd24..."
    # Sometimes on shutdown pid still exists, so delete it
    rm -f /opt/rh/httpd24/root/var/run/httpd/httpd.pid
    /opt/rh/httpd24/root/usr/sbin/httpd-scl-wrapper -DFOREGROUND
fi

exec "$@"
