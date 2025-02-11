#!/bin/bash
set -e

trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

echo "Creating coldfront database.."
mariadb -uroot <<EOF
create database if not exists coldfront
EOF

echo "Creating coldront mysql user.."
mariadb -uroot <<EOF
create user 'coldfrontapp'@'%' identified by '9obCuAphabeg';
EOF

echo "Granting coldfront user access to coldfront database.."
echo "grant all on coldfront.* to 'coldfrontapp'@'%';" | mariadb -uroot
echo "flush privileges;" | mariadb -uroot


if [ -f "/docker-entrypoint-initdb.d/coldfront.dump" ]; then
    echo "Restoring coldfront database..."
    mariadb -uroot coldfront < /docker-entrypoint-initdb.d/coldfront.dump
fi
