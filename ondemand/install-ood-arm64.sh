#!/bin/bash
set -e

trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

log_info() {
  printf "\n\e[0;35m $1\e[0m\n\n"
}

BUILD_DIR=$(mktemp -d -p /build)
cd $BUILD_DIR

git clone https://github.com/cisco/cjose
cd cjose
git checkout 0.6.1
./configure
make && make install

# so mod_auth_openidc can find cjose
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig

cd $BUILD_DIR
git clone https://github.com/zmartzone/mod_auth_openidc.git
cd mod_auth_openidc
git checkout v2.4.9.4
sh autogen.sh
./configure
make && make install

cd $BUILD_DIR
OOD_VERSION='3.0.0'
wget "https://github.com/OSC/ondemand/archive/refs/tags/v$OOD_VERSION.tar.gz"
tar -xf "v$OOD_VERSION.tar.gz"
cd ondemand-$OOD_VERSION
bundle config --local path ~/vendor/bundle
bundle config build.nokogiri --use-system-libraries
bundle config set force_ruby_platform true
bundle install
rake build -mj$(nproc)

mkdir -p /opt/ood
mkdir -p /var/www/ood/{apps,public,discover}
mkdir -p /var/www/ood/apps/{sys,dev,usr}
mkdir -p /etc/ood/config

mv mod_ood_proxy /opt/ood/
mv nginx_stage /opt/ood/
mv ood-portal-generator /opt/ood/
mv ood_auth_map /opt/ood/
mv apps/* /var/www/ood/apps/sys/

mkdir -p /var/lib/ondemand-nginx/config/apps/sys/
touch /var/lib/ondemand-nginx/config/apps/sys/dashboard.conf
touch /var/lib/ondemand-nginx/config/apps/sys/shell.conf
touch /var/lib/ondemand-nginx/config/apps/sys/myjobs.conf
/opt/ood/nginx_stage/sbin/update_nginx_stage

tee /etc/httpd/conf.d/enabled_mods.conf <<EOF
LoadModule auth_openidc_module modules/mod_auth_openidc.so
LoadModule ssl_module modules/mod_ssl.so
EOF

tee /etc/sudoers.d/ood <<EOF
Defaults:apache !requiretty, !authenticate
Defaults:apache env_keep += "NGINX_STAGE_* OOD_*"
apache ALL=(ALL) NOPASSWD: /opt/ood/nginx_stage/sbin/nginx_stage
Cmnd_Alias KUBECTL = /usr/local/bin/kubectl, /usr/bin/kubectl, /bin/kubectl
Defaults!KUBECTL !syslog
EOF
