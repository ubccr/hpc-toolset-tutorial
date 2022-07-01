#!/bin/bash
set -e

trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

log_info() {
  printf "\n\e[0;35m $1\e[0m\n\n"
}

build_passenger() {

  PASS_VERSION='6.0.7'
  NGINX_VERSION='1.18.0'

  wget -O $BUILD_DIR/passenger.tar.gz https://github.com/phusion/passenger/releases/download/release-$PASS_VERSION/passenger-$PASS_VERSION.tar.gz
  cd $BUILD_DIR
  tar xf passenger.tar.gz
  wget -O $BUILD_DIR/nginx.tar.gz http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz
  cd "$BUILD_DIR/passenger-$PASS_VERSION"
  tar xf $BUILD_DIR/nginx.tar.gz

  PREFIX=/opt/ood/ondemand/root
  NGINX_DATADIR=$PREFIX/usr/share/nginx
  NGINX_CONFDIR=$PREFIX/etc/nginx
  NGINX_HOME=/var/lib/ondemand-nginx
  NGINX_HOME_TMP=$NGINX_HOME/tmp
  NGINX_LOGDIR=/var/log/ondemand-nginx
  BASE_CCOPTS='-g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -m64 -mtune=generic'
  NGINX_CCOPTS="-O2 $BASE_CCOPTS"
  PASSENGER_CCOPTS="$BASE_CCOPTS -Wno-deprecated"
  LDOPTS="-Wl,-z,relro -Wl,-E"
  RUBY_LIBDIR=$PREFIX/usr/share/ruby/vendor_ruby

  rake nginx OPTIMIZE=yes CACHING=false
  cd "$BUILD_DIR/passenger-$PASS_VERSION/nginx-$NGINX_VERSION"
  ./configure \
	  --prefix=$NGINX_DATADIR \
	  --sbin-path=$PREFIX/usr/sbin/nginx \
    --conf-path=$NGINX_CONFDIR/nginx.conf \
    --error-log-path=$NGINX_LOGDIR/error.log \
    --http-log-path=$NGINX_LOGDIR/access.log \
    --http-client-body-temp-path=$NGINX_HOME_TMP/client_body \
    --http-proxy-temp-path=$NGINX_HOME_TMP/proxy \
    --http-fastcgi-temp-path=$NGINX_HOME_TMP/fastcgi \
    --http-uwsgi-temp-path=$NGINX_HOME_TMP/uwsgi \
    --http-scgi-temp-path=$NGINX_HOME_TMP/scgi \
    --pid-path=/run/ondemand-nginx.pid \
    --lock-path=/run/lock/subsys/ondemand-nginx \
    --user=ondemand-nginx \
    --group=ondemand-nginx \
    --with-file-aio \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_xslt_module \
    --with-http_image_filter_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_degradation_module \
    --with-http_stub_status_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-pcre \
    --with-pcre-jit \
    --add-module=../src/nginx_module \
    --with-cc-opt="$NGINX_CCOPTS" \
    --with-ld-opt="$LDOPTS" \
    --with-debug

  make -j$(nproc) && make install INSTALLDIRS=vendor
  mkdir -p  $NGINX_DATADIR/html
  mkdir -p  $NGINX_CONFDIR
  mkdir -p  $NGINX_HOME
  mkdir -p  $NGINX_HOME_TMP
  mkdir -p  $NGINX_LOGDIR

  set -x
  cd "$BUILD_DIR/passenger-$PASS_VERSION"
  which ruby
	rake fakeroot \
	    NATIVE_PACKAGING_METHOD=rpm \
	    FS_PREFIX=$PREFIX \
	    FS_BINDIR=$PREFIX/bin \
	    FS_SBINDIR=$PREFIX/sbin \
	    FS_DATADIR=$PREFIX/usr/share \
	    FS_LIBDIR=$PREFIX/lib64 \
	    FS_DOCDIR=$PREFIX/usr/share/doc \
	    RUBY=$(which ruby) \
	    RUBYLIBDIR=$RUBY_LIBDIR \
	    RUBYARCHDIR=$RUBY_LIBDIR \
	    APACHE2_MODULE_PATH=$PREFIX/usr/lib/apache2/modules/mod_passenger.so \
			OPTIMIZE=yes \
			CACHING=false \
			EXTRA_CFLAGS="$PASSENGER_CCOPTS" \
			EXTRA_CXXFLAGS="$PASSENGER_CCOPTS"

  cp -a $BUILD_DIR/passenger-$PASS_VERSION/pkg/fakeroot/* /
  cd $BUILD_DIR/passenger-$PASS_VERSION
  ./dev/install_scripts_bootstrap_code.rb --ruby $RUBY_LIBDIR \
	  $PREFIX/bin/passenger* \
	  $PREFIX/sbin/passenger* \
	  `find $PREFIX -name rack_handler.rb`

  ./dev/install_scripts_bootstrap_code.rb --nginx-module-config $PREFIX/bin $PREFIX/usr/share/passenger/ngx_http_passenger_module/config
  chmod +x $PREFIX/usr/share/passenger/helper-scripts/wsgi-loader.py
}

install_os_deps() {
  dnf -y update && \
    dnf install -y dnf-utils epel-release && \
    dnf config-manager --set-enabled powertools && \
    dnf -y module enable nodejs:12 ruby:2.7 && \
    dnf install -y \
        file lsof sudo gcc gcc-c++ git \
        patch lua-posix rsync ruby ruby-devel python2 python3 \
        nodejs sqlite sqlite-devel nmap-ncat httpd httpd-devel mod_ssl \
        libcurl-devel autoconf openssl-devel jansson-devel libxml2-devel \
        libxslt-devel gd-devel
  gem install rake dotenv bcrypt
}

build_ood_src() {
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
  OOD_VERSION='2.0.27'
  wget "https://github.com/OSC/ondemand/archive/refs/tags/v$OOD_VERSION.tar.gz"
  tar -xf "v$OOD_VERSION.tar.gz"
  cd ondemand-$OOD_VERSION
  bundle config --local path ~/vendor/bundle
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
    BUILD_DIR=$(mktemp -d -p /build)
    export BUILD_DIR

    install_os_deps
    build_passenger
    build_ood_src

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
    chown ondemand-dex:ondemand-dex /etc/ood/dex
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
