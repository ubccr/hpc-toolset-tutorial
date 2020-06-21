#!/bin/bash
set -e

trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

log_info() {
  printf "\n\e[0;35m $1\e[0m\n\n"
}

log_info "Installing required packages for Ondemand.."
yum install -y \
    centos-release-scl \
    https://yum.osc.edu/ondemand/latest/ondemand-release-web-latest-1-6.noarch.rpm

yum install -y \
    ondemand \
    openssl \
    mod_authnz_pam

log_info "Setting up Ondemand"
mkdir -p /etc/ood/config/clusters.d
mkdir -p /etc/ood/config/apps/shell
echo "DEFAULT_SSHHOST=frontend" > /etc/ood/config/apps/shell/env


log_info "Configuring Ondemand for PAM based logins.."

# This is to allow ondemand to use pam for local logins in docker:
chmod 640 /etc/shadow
chgrp apache /etc/shadow

echo "LoadModule authnz_pam_module modules/mod_authnz_pam.so" > /opt/rh/httpd24/root/etc/httpd/conf.modules.d/55-authnz_pam.conf
cp /usr/lib64/httpd/modules/mod_authnz_pam.so /opt/rh/httpd24/root/usr/lib64/httpd/modules/
cp /etc/pam.d/sshd /etc/pam.d/ood-webapp

tee /etc/ood/config/ood_portal.yml <<EOF
---
#
# Portal configuration
#
ssl:
  - 'SSLCertificateFile "/etc/pki/tls/certs/ood.crt"'
  - 'SSLCertificateKeyFile "/etc/pki/tls/private/ood.key"'
auth:
  - 'AuthType Basic'
  - 'AuthName "HPC Tutorial OnDemand"'
  - 'AuthBasicProvider PAM'
  - 'AuthPAMService ood-webapp'
  - 'Require valid-user'
EOF

# Create self-signed ssl cert
log_info "Creating self-signed ssl cert for ondemand.."
openssl req -x509 -nodes -days 365 -subj "/C=US/ST=NY/O=HPC Tutorial/CN=ondemand" -newkey rsa:2048 -keyout /etc/pki/tls/private/ood.key -out /etc/pki/tls/certs/ood.crt

log_info "Generating new httpd24 configs.."
/opt/ood/ood-portal-generator/sbin/update_ood_portal
