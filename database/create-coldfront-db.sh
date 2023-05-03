#!/bin/bash
set -e

trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

echo "Creating coldfront database.."
mysql -uroot <<EOF
create database if not exists coldfront
EOF

echo "Creating coldront mysql user.."
mysql -uroot <<EOF
create user 'coldfrontapp'@'%' identified by '9obCuAphabeg';
EOF

echo "Granting coldfront user access to coldfront database.."
echo "grant all on coldfront.* to 'coldfrontapp'@'%';" | mysql -uroot
echo "flush privileges;" | mysql -uroot


if [ -f "/docker-entrypoint-initdb.d/coldfront.dump" ]; then
    echo "Restoring coldfront database..."
    mysql -uroot coldfront < /docker-entrypoint-initdb.d/coldfront.dump
fi
