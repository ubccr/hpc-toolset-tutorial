#!/bin/bash
set -e

trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

log_info() {
  printf "\n\e[0;35m $1\e[0m\n\n"
}

log_info "Installing required packages for coldfront.."
yum install -y \
    python3 \
    python3-devel \
    memcached \
    nginx \
    openssl \
    redis

log_info "Creating coldfront system user account.."
groupadd -r coldfront
useradd -r -g coldfront -m -c 'coldfront server' coldfront

log_info "Installing coldfront.."
install -d -o coldfront -g coldfront -m 0755 /srv/www/ssl
pushd /srv/www
git clone https://github.com/ubccr/coldfront.git
python3 -mvenv venv
source venv/bin/activate
pushd coldfront
pip install --upgrade pip
pip install wheel mysqlclient gunicorn django_pam
pip install -r requirements.txt
pip install -e .

# This is to allow coldfront to use pam for local logins in docker:
chmod 640 /etc/shadow
chgrp nginx /etc/shadow

# Adjust nginx
log_info "Setting up nginx.."
sed -i 's/ default_server;/;/' /etc/nginx/nginx.conf

# Create self-signed ssl cert
log_info "Creating self-signed ssl cert for coldfront.."
openssl req -x509 -nodes -days 365 -subj "/C=US/ST=NY/O=HPC Tutorial/CN=coldfront" -newkey rsa:2048 -keyout /srv/www/ssl/coldfront.key -out /srv/www/ssl/coldfront.crt;

chown -R coldfront.coldfront /srv/www/coldfront

yum clean all
rm -rf /var/cache/yum
