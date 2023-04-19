#!/bin/bash
set -e

trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

log_info() {
  printf "\n\e[0;35m $1\e[0m\n\n"
}

ARCHTYPE=`uname -m`

log_info "Installing required packages for coldfront.."
dnf install -y \
    python39-devel \
    memcached \
    nginx \
    openssl \
    openldap-devel \
    redis

log_info "Creating coldfront system user account.."
groupadd -r coldfront
useradd -r -g coldfront -m -d /srv/www -c 'coldfront server' coldfront

mkdir /etc/coldfront
chmod 0755 /srv/www

log_info "Installing coldfront.."
install -d -o coldfront -g coldfront -m 0755 /srv/www/static
install -d -o coldfront -g coldfront -m 0755 /srv/www/ssl
pushd /srv/www
python3 -mvenv venv
source venv/bin/activate
pip install --upgrade pip
pip install coldfront wheel mysqlclient gunicorn python-ldap ldap3 mozilla_django_oidc django_auth_ldap

# Adjust nginx
log_info "Setting up nginx.."
sed -i 's/ default_server;/;/' /etc/nginx/nginx.conf

dnf clean all
rm -rf /var/cache/dnf
