#!/bin/bash

if [ `whoami` != 'root' ]; then
    echo "ERROR: This script should only be run as root" >&2
    exit 1
fi
historialdir='/srv/xdmod/historical'
if [ -f $historialdir/.hasrun ]; then
    echo "ERROR: This has already been run once. Trying to do it again will cause errors" >&2
    exit 2
fi
touch $historialdir/.hasrun
jq --argfile f1 /etc/xdmod/resources.json --argfile f2 $historialdir/resources.json -n '$f1 + $f2' | sudo tee /etc/xdmod/resources.json 
jq --argfile f1 /etc/xdmod/resource_specs.json --argfile f2 $historialdir/resource_specs.json -n '$f1 + $f2' | sudo tee /etc/xdmod/resource_specs.json 
types='Cloud Jobs Storage'
for resource in $historialdir/Jobs/*.log; do
    sudo -u xdmod xdmod-shredder -r `basename $resource .log` -f slurm -i $resource;
done
last_modified_start_date=$(date +'%F %T')
sudo -u xdmod xdmod-shredder -r cumulonimbus -d $historialdir/Cloud/ -f openstack
sudo -u xdmod xdmod-ingestor --last-modified-start-date "$last_modified_start_date"
for storage_dir in $historialdir/Storage/*; do
   sudo -u xdmod xdmod-shredder -f storage -r $(basename $storage_dir) -d $storage_dir
done
last_modified_start_date=$(date +'%F %T')
sudo -u xdmod xdmod-ingestor --datatype storage
cat names.slurm.csv names.csv > /tmp/historical.names.csv
sudo -u xdmod xdmod-import-csv -t names -i /tmp/historical.names.csv
sudo -u xdmod xdmod-ingestor
