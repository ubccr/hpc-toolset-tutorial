#!/bin/bash
set -e

trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

log_info() {
  printf "\n\e[0;35m $1\e[0m\n\n"
}

ARCHTYPE=`uname -m`
DEX_VERSION=${DEX_VERSION:-2.31.1}
DEX_PATCH_VERSION=${DEX_PATCH_VERSION:-703e26bc109e86d00be22ef1803bdb96b2dc09e2}

log_info "Installing required packages for Ondemand ${ARCHTYPE}.."

if [[ "${ARCHTYPE}" = "x86_64" ]]; then
    dnf install -y https://yum.osc.edu/ondemand/2.0/ondemand-release-web-2.0-1.noarch.rpm
    dnf install -y \
        netcat \
        ondemand \
        ondemand-dex
elif [[ "${ARCHTYPE}" = "aarch64" ]]; then
    # TODO: flesh out arm64 builds?
    dnf install -y golang-bin
    log_info "Install dex ${DEX_VERSION}..."
    wget -O /tmp/dex-${DEX_VERSION}.tar.gz https://github.com/dexidp/dex/archive/v${DEX_VERSION}.tar.gz
    wget -O /tmp/dex-ood.patch https://github.com/OSC/dex/commit/${DEX_PATCH_VERSION}.patch
    pushd /tmp
    tar xvf dex-${DEX_VERSION}.tar.gz
    pushd dex-${DEX_VERSION}
    make build
    mv bin/dex bin/dex-orig
    patch -p1 < ../dex-ood.patch
    make build
    mv bin/dex /usr/sbin/ondemand-dex-session
    mv bin/dex-orig /usr/sbin/ondemand-dex
    popd
    rm -rf /tmp/dex*
    mkdir -p /usr/share/ondemand-dex/
    git clone https://github.com/OSC/ondemand-dex.git
    pushd ondemand-dex
    mv web /usr/share/ondemand-dex/
    popd
    rm -Rf ondemand-dex
    groupadd -r ondemand-dex
    useradd -r -d /var/lib/ondemand-dex -g ondemand-dex -s /sbin/nologin -c "OnDemand Dex" ondemand-dex
    mkdir -p /etc/ood/dex
    tee /etc/ood/dex/config.yaml <<EOF
---
issuer: http://eb8307ff82be:5556
storage:
  type: sqlite3
  config:
    file: "/etc/ood/dex/dex.db"
web:
  http: 0.0.0.0:5556
telemetry:
  http: 0.0.0.0:5558
staticClients:
- id: eb8307ff82be
  redirectURIs:
  - http://eb8307ff82be/oidc
  name: OnDemand
  secret: 7c6c2f51-2f97-4866-886e-2fcf5b974224
oauth2:
  skipApprovalScreen: true
enablePasswordDB: true
staticPasswords:
- email: ood@localhost
  hash: "$2a$10$2b2cU8CPhOTaGrs1HRQuAueS7JTT5ZHsHSzYiFPm1leZck7Mc8T4W"
  username: ood
  userID: '08a8684b-db88-4b73-90a9-3cd1661f5466'
frontend:
  dir: "/usr/share/ondemand-dex/web"
  theme: hpc-coop
EOF
fi

log_info "Setting up Ondemand"
mkdir -p /etc/ood/config/clusters.d
mkdir -p /etc/ood/config/apps/shell
mkdir -p /etc/ood/config/apps/bc_desktop
mkdir -p /etc/ood/config/apps/dashboard
mkdir -p /etc/ood/config/apps/myjobs/templates
echo "DEFAULT_SSHHOST=frontend" > /etc/ood/config/apps/shell/env
echo "OOD_DEFAULT_SSHHOST=frontend" >> /etc/ood/config/apps/shell/env
echo "OOD_SSHHOST_ALLOWLIST=ondemand:cpn01:cpn02" >> /etc/ood/config/apps/shell/env
echo "OOD_DEV_SSH_HOST=ondemand" >> /etc/ood/config/apps/dashboard/env
echo "MOTD_PATH=/etc/motd" >> /etc/ood/config/apps/dashboard/env
echo "MOTD_FORMAT=markdown" >> /etc/ood/config/apps/dashboard/env

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

if [[ ${ARCHTYPE} = "x86_64" ]]; then
    log_info "Generating new httpd24 and dex configs.."
    /opt/ood/ood-portal-generator/sbin/update_ood_portal

    log_info "Adding new theme to dex"
    sed -i "s/theme: ondemand/theme: hpc-coop/g" /etc/ood/dex/config.yaml
fi

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
