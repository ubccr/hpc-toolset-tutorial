#!/bin/bash
set -e

if [ "$1" = "serve" ]
then
    echo "---> Starting SSSD on ondemand ..."
    /sbin/sssd

    echo "---> Starting the MUNGE Authentication service (munged) on ondemand ..."
    gosu munge /usr/sbin/munged

    echo "---> Starting sshd on ondemand..."
    /usr/sbin/sshd

    echo "---> Starting ondemand httpd24..."
    /opt/rh/httpd24/root/usr/sbin/httpd-scl-wrapper -DFOREGROUND
fi

exec "$@"
