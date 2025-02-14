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
oidc_uri: '/oidc'
oidc_scope: "openid profile email groups"
auth:
 - 'AuthType openid-connect'
 - 'Require valid-user'
logout_redirect: '/oidc?logout=https%3A%2F%2Flocalhost%3A3443'
EOF

log_info "Configuring OIDC .."

tee /etc/httpd/conf.d/auth_openidc.conf <<EOF
OIDCProviderMetadataURL https://keycloak:7443/realms/HPC-Cluster/.well-known/openid-configuration
OIDCClientID        "OpenOnDemand"
OIDCClientSecret    "M6F7fVyJvVOK84Zve18mrsRxwhbWP7uf"
OIDCRedirectURI      https://localhost:3443/oidc
OIDCCryptoPassphrase "es60gW2i8RPpJm2edsjnJFPGF4kVbOu1"
OIDCSSLValidateServer Off

# Keep sessions alive for 8 hours
OIDCSessionInactivityTimeout 28800
OIDCSessionMaxDuration 28800

# Set REMOTE_USER
OIDCRemoteUserClaim preferred_username

# Don't pass claims to backend servers
OIDCPassClaimsAs environment

# Strip out session cookies before passing to backend
OIDCStripCookies mod_auth_openidc_session mod_auth_openidc_session_chunks mod_auth_openidc_session_0 mod_auth_openidc_session_1
EOF


log_info "Generating new httpd24 config.."
/opt/ood/ood-portal-generator/sbin/update_ood_portal

dnf clean all
rm -rf /var/cache/dnf
