#!/usr/bin/env bash
echo "Creating mongo user accounts for use by XDMoD."
mongo admin --host localhost -u admin -p hBbeOfpFLfFT5ZO --eval "db.createUser({user: 'xdmod', pwd: 'xsZ0LpZstneBpijLy7', roles: [{role: 'readWrite', db: 'supremm'}]}); db.createUser({user: 'xdmod-ro', pwd: 'OPsvjY4gxq74ZIbOrz', roles: [{role: 'read', db: 'supremm'}]});"
echo "Mongo users created."
