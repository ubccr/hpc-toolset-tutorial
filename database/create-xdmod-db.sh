#!/bin/bash
set -e

trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

echo "Creating xdmod mysql user.."
mysql -uroot <<EOF
create user 'xdmodapp'@'%' identified by 'ofbatgorWep0';
EOF


echo "Creating xdmod databases.."

for db in mod_hpcdb mod_logger mod_shredder moddb modw modw_aggregates modw_filters modw_supremm modw_etl modw_jobefficiency modw_cloud modw_ondemand
do
    echo "Creating $db database.."
    echo "create database if not exists $db" | mysql -uroot
    echo "grant all on $db.* to 'xdmodapp'@'%';" | mysql -uroot
done

echo "flush privileges;" | mysql -uroot
