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
    ondemand-dex

log_info "Setting up Ondemand"
mkdir -p /etc/ood/config/clusters.d
mkdir -p /etc/ood/config/apps/shell
mkdir -p /etc/ood/config/apps/bc_desktop
mkdir -p /etc/ood/config/apps/dashboard
echo "DEFAULT_SSHHOST=frontend" > /etc/ood/config/apps/shell/env
echo "OOD_SSHHOST_ALLOWLIST=ondemand" >> /etc/ood/config/apps/shell/env
echo "OOD_DEV_SSH_HOST=ondemand" >> /etc/ood/config/apps/dashboard/env

log_info "Configuring Ondemand ood_portal.yml .."

tee /etc/ood/config/ood_portal.yml <<EOF
---
#
# Portal configuration
#
listen_addr_port:
  - '3443'
servername: localhost
port: 3443
ssl:
  - 'SSLCertificateFile "/etc/pki/tls/certs/localhost.crt"'
  - 'SSLCertificateKeyFile "/etc/pki/tls/private/localhost.key"'
node_uri: "/node"
rnode_uri: "/rnode"
oidc_scope: "openid profile email groups"
dex:
  connectors:
    - type: ldap
      id: ldap
      name: LDAP
      config:
        host: ldap:636
        insecureSkipVerify: true
        bindDN: cn=admin,dc=example,dc=org
        bindPW: admin
        userSearch:
          baseDN: ou=People,dc=example,dc=org
          filter: "(objectClass=posixAccount)"
          username: uid
          idAttr: uid
          emailAttr: mail
          nameAttr: gecos
          preferredUsernameAttr: uid
        groupSearch:
          baseDN: ou=Groups,dc=example,dc=org
          filter: "(objectClass=posixGroup)"
          userMatchers:
            - userAttr: DN
              groupAttr: member
          nameAttr: cn
  # This is the default, but illustrating how to change
  frontend:
    theme: ondemand
EOF

log_info "Generating new httpd24 and dex configs.."
/opt/ood/ood-portal-generator/sbin/update_ood_portal

yum clean all
rm -rf /var/cache/yum

log_info "Cloning repos to assist with app development.."
mkdir -p /var/git
git clone https://github.com/OSC/bc_example_jupyter.git --bare /var/git/bc_example_jupyter

log_info "Enabling app development for hpcadmin..."
mkdir -p /var/www/ood/apps/dev/hpcadmin
ln -s /home/hpcadmin/ondemand/dev /var/www/ood/apps/dev/hpcadmin/gateway
echo 'if [[ ${HOSTNAME} == ondemand ]]; then source scl_source enable ondemand; fi' >> /home/hpcadmin/.bash_profile
