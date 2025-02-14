#!/bin/bash
set -e

trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT
CONF_EMPTY=1

echo "Creating keycloak database.."
mariadb -uroot <<EOF
create database if not exists keycloak
EOF

echo "Creating keycloak mysql user.."
mariadb -uroot <<EOF
create user 'keycloak'@'%' identified by 'keycloak';
EOF

echo "Granting keycloak access to keycloak"
echo "grant all on keycloak.* to 'keycloak'@'%';" | mariadb -uroot
echo "flush privileges;" | mariadb -uroot

if [[ -f "/docker-entrypoint-initdb.d/keycloak.dump" && $CONF_EMPTY -eq 0 ]]; then
    echo "Restoring keycloak database..."
    mariadb -uroot keycloak < /docker-entrypoint-initdb.d/keycloak.dump
fi
