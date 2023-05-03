#!/bin/bash
set -e

trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

log_info() {
  printf "\n\e[0;35m $1\e[0m\n\n"
}

log_info "Setting up Ondemand"
mkdir -p /etc/ood/config/clusters.d
mkdir -p /etc/ood/config/apps/shell
mkdir -p /etc/ood/config/apps/bc_desktop
mkdir -p /etc/ood/config/apps/dashboard
mkdir -p /etc/ood/config/apps/dashboard/views
mkdir -p /etc/ood/config/apps/myjobs/templates
mkdir -p /etc/ood/config/ondemand.d
echo "DEFAULT_SSHHOST=frontend" > /etc/ood/config/apps/shell/env
echo "OOD_DEFAULT_SSHHOST=frontend" >> /etc/ood/config/apps/shell/env
echo "OOD_SSHHOST_ALLOWLIST=ondemand:cpn01:cpn02" >> /etc/ood/config/apps/shell/env


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
dex_uri: false
dex:
  client_redirect_uris:
    - "https://localhost:4443/simplesaml/module.php/authoidcoauth2/linkback.php"
    - "https://localhost:2443/oidc/callback/"
  client_secret: 334389048b872a533002b34d73f8c29fd09efc50
  client_id: localhost
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

log_info "Adding new theme to dex"
sed -i "s/theme: ondemand/theme: hpc-coop/g" /etc/ood/dex/config.yaml

dnf clean all
rm -rf /var/cache/dnf

log_info "Cloning repos to assist with app development.."
mkdir -p /var/git
git clone https://github.com/OSC/bc_example_jupyter.git --bare /var/git/bc_example_jupyter
git clone https://github.com/OSC/ood-example-ps.git --bare /var/git/ood-example-ps

log_info "Enabling app development for hpcadmin..."
mkdir -p /var/www/ood/apps/dev/hpcadmin
ln -s /home/hpcadmin/ondemand/dev /var/www/ood/apps/dev/hpcadmin/gateway
echo 'if [[ ${HOSTNAME} == ondemand ]]; then source scl_source enable ondemand; fi' >> /home/hpcadmin/.bash_profile
