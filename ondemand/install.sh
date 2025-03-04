#!/bin/bash
set -e

trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

log_info() {
  printf "\n\e[0;35m $1\e[0m\n\n"
}

log_info "Setting up Ondemand"
dnf config-manager --set-enabled powertools
dnf -y module enable ruby:3.3 nodejs:20
dnf install -y https://yum.osc.edu/ondemand/4.0/ondemand-release-web-4.0-1.el8.noarch.rpm
dnf install -y ondemand mod_auth_openidc

mkdir -p /etc/ood/config/clusters.d
mkdir -p /etc/ood/config/apps/shell
mkdir -p /etc/ood/config/apps/bc_desktop
mkdir -p /etc/ood/config/apps/dashboard
mkdir -p /etc/ood/config/apps/dashboard/views
mkdir -p /etc/ood/config/ondemand.d
echo "OOD_DEFAULT_SSHHOST=frontend" >> /etc/ood/config/apps/shell/env
echo "OOD_SSHHOST_ALLOWLIST=ondemand:cpn01:cpn02" >> /etc/ood/config/apps/shell/env

log_info "Generating new httpd24 config.."
/opt/ood/ood-portal-generator/sbin/update_ood_portal

dnf clean all
rm -rf /var/cache/dnf
