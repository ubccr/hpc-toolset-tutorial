#!/bin/bash
set -e

trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT
CONF_EMPTY=0

echo "Creating keycloak database.."
mysql -uroot <<EOF
create database if not exists keycloak
EOF

echo "Creating keycloak mysql user.."
mysql -uroot <<EOF
create user 'keycloak'@'%' identified by 'keycloak';
EOF

echo "Granting $StorageUser access to $StorageLoc.."
echo "grant all on \`keycloak//_/\\_}\`.* to 'keycloak'@'%';" | mysql -uroot
echo "flush privileges;" | mysql -uroot

if [ -f "/docker-entrypoint-initdb.d/keycloak.dump" && $CONF_EMPTY == 0]; then
    echo "Restoring keycloak database..."
    mysql -uroot keycloak < /docker-entrypoint-initdb.d/keycloak.dump
fi
