#!/bin/bash

set -e

docker-compose stop && \
docker-compose rm -f -v && \
docker-compose down -v
