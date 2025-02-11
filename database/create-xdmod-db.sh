#!/bin/bash
set -e

trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

echo "Creating xdmod mysql user.."
mariadb -uroot <<EOF
create user 'xdmodapp'@'%' identified by 'ofbatgorWep0';
EOF

if [ -f "/docker-entrypoint-initdb.d/xdmod.dump" ]; then
  echo "Restoring xdmod database..."
  mariadb -uroot < /docker-entrypoint-initdb.d/xdmod.dump
  for db in mod_hpcdb mod_logger mod_shredder moddb modw modw_aggregates modw_filters modw_supremm modw_etl modw_jobefficiency modw_cloud modw_ondemand
    do
        echo "grant all on $db.* to 'xdmodapp'@'%';" | mariadb -uroot
    done

    echo "flush privileges;" | mariadb -uroot
else
  echo "Creating xdmod databases.."
  for db in mod_hpcdb mod_logger mod_shredder moddb modw modw_aggregates modw_filters modw_supremm modw_etl modw_jobefficiency modw_cloud modw_ondemand
  do
      echo "Creating $db database.."
      echo "create database if not exists $db" | mariadb -uroot
      echo "grant all on $db.* to 'xdmodapp'@'%';" | mariadb -uroot
  done

  echo "flush privileges;" | mariadb -uroot
fi






