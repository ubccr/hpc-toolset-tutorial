#!/bin/bash
set -e

if [ "$1" = "serve" ]
then
    echo "---> Starting SSSD on ondemand ..."
    /sbin/sssd --logger=stderr -d 3 -i 2>&1 &

    echo "---> Starting the MUNGE Authentication service (munged) on ondemand ..."
    gosu munge /usr/sbin/munged

    echo "---> Starting sshd on ondemand..."
    /usr/sbin/sshd -e

    echo "---> Starting ondemand httpd24..."
    /opt/rh/httpd24/root/usr/sbin/httpd-scl-wrapper -DFOREGROUND
fi

exec "$@"
