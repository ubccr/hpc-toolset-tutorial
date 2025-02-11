#!/bin/bash
set -e

trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

log_info() {
  printf "\n\e[0;35m $1\e[0m\n\n"
}

DEX_VERSION=${DEX_VERSION:-2.36.0}
ARCH=${ARCH:-arm64}  # Set architecture, change to 'amd64' if needed

log_info "Installing dependencies..."
dnf install -y wget git gcc make go

log_info "Downloading and building dex ${DEX_VERSION} for ${ARCH}..."
wget -O /tmp/dex-${DEX_VERSION}.tar.gz https://github.com/dexidp/dex/archive/v${DEX_VERSION}.tar.gz
pushd /tmp
tar xvf dex-${DEX_VERSION}.tar.gz
pushd dex-${DEX_VERSION}
make build
mv bin/dex /usr/sbin/ondemand-dex
cp /usr/sbin/ondemand-dex /usr/sbin/ondemand-dex-session
popd
rm -rf /tmp/dex*

log_info "Setting up ondemand-dex..."
mkdir -p /usr/share/ondemand-dex/
git clone https://github.com/OSC/ondemand-dex.git /tmp/ondemand-dex
mv /tmp/ondemand-dex/web /usr/share/ondemand-dex/
rm -rf /tmp/ondemand-dex

groupadd -r ondemand-dex
useradd -r -d /var/lib/ondemand-dex -g ondemand-dex -s /sbin/nologin -c "OnDemand Dex" ondemand-dex
mkdir -p /etc/ood/dex
chown ondemand-dex:ondemand-dex /etc/ood/dex

log_info "Creating default config.yaml for dex"
cat <<EOL > /etc/ood/dex/config.yaml
issuer: http://localhost:5556
storage:
  type: sqlite3
  config:
    file: /var/lib/ondemand-dex/dex.db
web:
  http: 0.0.0.0:5556
EOL

chown ondemand-dex:ondemand-dex /etc/ood/dex/config.yaml

log_info "ondemand-dex installation completed."
