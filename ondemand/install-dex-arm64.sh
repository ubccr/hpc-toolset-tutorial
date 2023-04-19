#!/bin/bash
set -e

trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

log_info() {
  printf "\n\e[0;35m $1\e[0m\n\n"
}

DEX_VERSION=${DEX_VERSION:-2.32.0}
DEX_PATCH_VERSION=${DEX_PATCH_VERSION:-9366a1969bd656daa1df44e0bdd02f14437ed466}

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
chown ondemand-dex:ondemand-dex /etc/ood/dex
