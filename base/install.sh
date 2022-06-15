#!/bin/bash
set -e

trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

log_info() {
  printf "\n\e[0;35m $1\e[0m\n\n"
}

ARCHTYPE=`uname -m`
GOSU_VERSION=${GOSU_VERSION:-1.12}

log_info "HPCTS Base image for $ARCHTYPE"

source /build/base.config

#------------------------
# Setup system user/groups
#------------------------
log_info "Creating munge user account.."
groupadd -r munge
useradd -r -g munge -s /sbin/nologin -d /var/run/munge munge
log_info "Creating sssd user account.."
groupadd -r sssd
useradd -r -g sssd -d / -s /sbin/nologin sssd

#------------------------
# Install base packages
#------------------------
log_info "Installing base packages.."
dnf install -y \
    openssh-server \
    sudo \
    epel-release \
    wget \
    vim \
    openldap-clients \
    sssd \
    sssd-tools \
    authselect \
    openssl \
    bash-completion

#------------------------
# Generate ssh host keys
#------------------------
log_info "Generating ssh host keys.."
ssh-keygen -t rsa -N '' -f /etc/ssh/ssh_host_rsa_key
ssh-keygen -t ecdsa -N '' -f /etc/ssh/ssh_host_ecdsa_key
ssh-keygen -t ed25519 -N '' -f /etc/ssh/ssh_host_ed25519_key
chgrp ssh_keys /etc/ssh/ssh_host_rsa_key
chgrp ssh_keys /etc/ssh/ssh_host_ecdsa_key
chgrp ssh_keys /etc/ssh/ssh_host_ed25519_key

sed -i 's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/' /etc/ssh/sshd_config

#------------------------
# Setup LDAP and SSSD
#------------------------
log_info "Configuring LDAP and SSSD"
authselect select sssd --force

cat > /etc/openldap/ldap.conf <<EOF
TLS_CACERTDIR /etc/openldap/cacerts
TLS_REQCERT never
SASL_NOCANON	on
URI ldaps://ldap:636
BASE dc=example,dc=org
EOF

cat > /etc/sssd/sssd.conf <<EOF
[domain/default]
reconnection_retries = 10
offline_timeout = 1
debug_level = 2
autofs_provider = ldap
ldap_schema = rfc2307bis
ldap_group_member = member
ldap_search_base = dc=example,dc=org
id_provider = ldap
auth_provider = ldap
chpass_provider = ldap
sudo_provider = none
ldap_uri = ldaps://ldap:636
cache_credentials = True
ldap_tls_reqcert = never
ldap_default_bind_dn = cn=admin,dc=example,dc=org
ldap_default_authtok = admin

[sssd]
debug_level = 2
services = nss, pam
domains = default

[nss]
reconnection_retries = 10
debug_level = 2
homedir_substring = /home

[pam]
reconnection_retries = 10
debug_level = 2
EOF

chmod 600 /etc/sssd/sssd.conf
rm -f /var/run/nologin

#------------------------
# Setup user accounts
#------------------------

idnumber=1001
for uid in hpcadmin $USERS
do
    log_info "Bootstrapping $uid user account.."
    install -d -o $idnumber -g $idnumber -m 0700 /home/$uid
    install -d -o $idnumber -g $idnumber -m 0700 /home/$uid/.ssh
    ssh-keygen -b 2048 -t rsa -f /home/$uid/.ssh/id_rsa -q -N ""
    install -o $idnumber -g $idnumber -m 0600 /home/$uid/.ssh/id_rsa.pub /home/$uid/.ssh/authorized_keys
    cat > /home/$uid/.ssh/config <<EOF
Host *
   StrictHostKeyChecking no
   UserKnownHostsFile /dev/null
EOF
    chmod 0600 /home/$uid/.ssh/config
    cp /etc/skel/.bash* /home/$uid
    chown -R $idnumber:$idnumber /home/$uid
    idnumber=$((idnumber + 1))
done

sudo tee /etc/sudoers.d/90-hpcadmin <<EOF
# User rules for hpcadmin
hpcadmin ALL=(ALL) NOPASSWD:ALL
EOF
chmod 0440 /etc/sudoers.d/90-hpcadmin

#------------------------
# Install gosu
#------------------------
log_info "Installing gosu.."
if [[ "${ARCHTYPE}" = "x86_64" ]]; then
    wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64"
elif [[ "${ARCHTYPE}" = "aarch64" ]]; then
    wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-arm64"
fi
chmod +x /usr/local/bin/gosu
gosu nobody true

log_info "Creating self-signed ssl certs.."
# Generate CA
openssl genrsa -out /etc/pki/tls/ca.key 4096
openssl req -new -x509 -days 3650 -sha256 -key /etc/pki/tls/ca.key -extensions v3_ca -out /etc/pki/tls/ca.crt -subj "/CN=fake-ca"
# Generate certificate request
openssl genrsa -out /etc/pki/tls/private/localhost.key 2048
openssl req -new -sha256 -key /etc/pki/tls/private/localhost.key -out /etc/pki/tls/certs/localhost.csr -subj "/C=US/ST=NY/O=HPC Tutorial/CN=localhost"
# Config for signing cert
cat > /etc/pki/tls/localhost.ext << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = DNS:localhost
extendedKeyUsage = serverAuth
EOF
# Sign cert request and generate cert
openssl x509 -req -CA /etc/pki/tls/ca.crt -CAkey /etc/pki/tls/ca.key -CAcreateserial \
  -in /etc/pki/tls/certs/localhost.csr -out /etc/pki/tls/certs/localhost.crt \
  -days 365 -sha256 -extfile /etc/pki/tls/localhost.ext
# Add CA to trust store
cp /etc/pki/tls/ca.crt /etc/pki/ca-trust/source/anchors/
update-ca-trust extract

dnf clean all
rm -rf /var/cache/dnf
