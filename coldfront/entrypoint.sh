#!/bin/bash
set -e

if [ "$1" = "serve" ]
then
    echo "---> Starting SSSD on coldfront ..."
    # Sometimes on shutdown pid still exists, so delete it
    rm -f /var/run/sssd.pid
    /sbin/sssd --logger=stderr -d 2 -i 2>&1 &

    echo "---> Starting sshd on coldfront..."
    /usr/sbin/sshd -e

    echo "---> Starting the MUNGE Authentication service (munged) on coldfront ..."
    gosu munge /usr/sbin/munged

    source /srv/www/venv/bin/activate

    until coldfront shell < /srv/www/checkdb.py 2>&1 > /dev/null
    do
        echo "-- Waiting for database to become active ..."
        sleep 2
    done

    if ! coldfront show_users_in_project_but_not_in_allocation &> /dev/null; then
        echo "-- Initializing coldfront database..."
        coldfront initial_setup

        echo "-- Generating static css files..."
        coldfront collectstatic

        echo "-- Creating superuser..."
        echo "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('admin', 'admin@localhost', 'admin')" | \
               coldfront shell
    fi

    echo "---> Starting nginx on coldfront..."
    /sbin/nginx

    echo "---> Starting coldfront in gunicorn..."
    exec gosu coldfront:nginx bash -c 'cd /srv/www; source /srv/www/venv/bin/activate; gunicorn --workers 3 --bind unix:/srv/www/coldfront.sock -m 007 coldfront.config.wsgi'
fi

exec "$@"
