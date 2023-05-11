#!/usr/bin/env bash
echo "******* Populating MongoDB *******"
for collection in schema resource_1 timeseries-resource_1
do
  file="/docker-entrypoint-initdb.d/$collection.json"
  printf "\tChecking for %s\n" "$file";
  if [ -f "$file" ]; then
    printf "\tPopulating %s\n" "$collection"
    mongoimport "mongodb://admin:hBbeOfpFLfFT5ZO@localhost:27017/supremm?authSource=admin" "$file"
    printf "\t%s Populated\n" "$collection"
  else
      printf "\t %s does not exist!" "$file";
  fi
done
echo "******* MongoDB population done *******"
