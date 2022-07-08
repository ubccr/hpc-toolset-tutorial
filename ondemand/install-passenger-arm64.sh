#!/bin/bash
set -e

trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

log_info() {
  printf "\n\e[0;35m $1\e[0m\n\n"
}


PASS_VERSION='6.0.14'
NGINX_VERSION='1.18.0'
BUILD_DIR=$(mktemp -d -p /build)

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
BASE_CCOPTS='-g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -march=native -mtune=native'
NGINX_CCOPTS="-O2 $BASE_CCOPTS"
PASSENGER_CCOPTS="$BASE_CCOPTS -Wno-deprecated"
LDOPTS="-Wl,-z,relro -Wl,-E"
RUBY_LIBDIR=$PREFIX/usr/share/ruby/vendor_ruby

rake nginx OPTIMIZE=yes CACHING=false
cd "$BUILD_DIR/passenger-$PASS_VERSION/nginx-$NGINX_VERSION"
./configure --prefix=$NGINX_DATADIR --sbin-path=$PREFIX/usr/sbin/nginx --conf-path=$NGINX_CONFDIR/nginx.conf --error-log-path=$NGINX_LOGDIR/error.log --http-log-path=$NGINX_LOGDIR/access.log --http-client-body-temp-path=$NGINX_HOME_TMP/client_body --http-proxy-temp-path=$NGINX_HOME_TMP/proxy --http-fastcgi-temp-path=$NGINX_HOME_TMP/fastcgi --http-uwsgi-temp-path=$NGINX_HOME_TMP/uwsgi --http-scgi-temp-path=$NGINX_HOME_TMP/scgi --pid-path=/run/ondemand-nginx.pid --lock-path=/run/lock/subsys/ondemand-nginx --user=ondemand-nginx --group=ondemand-nginx --with-file-aio --with-http_ssl_module --with-http_v2_module --with-http_realip_module --with-http_addition_module --with-http_xslt_module --with-http_image_filter_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_degradation_module --with-http_stub_status_module --with-mail --with-mail_ssl_module --with-pcre --with-pcre-jit --add-module=../src/nginx_module --with-cc-opt="$NGINX_CCOPTS" --with-ld-opt="$LDOPTS" --with-debug

make -j$(nproc) && make install INSTALLDIRS=vendor
mkdir -p  $NGINX_DATADIR/html
mkdir -p  $NGINX_CONFDIR
mkdir -p  $NGINX_HOME
mkdir -p  $NGINX_HOME_TMP
mkdir -p  $NGINX_LOGDIR

set -x
cd "$BUILD_DIR/passenger-$PASS_VERSION"
which ruby
rake fakeroot NATIVE_PACKAGING_METHOD=rpm FS_PREFIX=$PREFIX FS_BINDIR=$PREFIX/bin FS_SBINDIR=$PREFIX/sbin FS_DATADIR=$PREFIX/usr/share FS_LIBDIR=$PREFIX/lib64 FS_DOCDIR=$PREFIX/usr/share/doc RUBY=$(which ruby) RUBYLIBDIR=$RUBY_LIBDIR RUBYARCHDIR=$RUBY_LIBDIR APACHE2_MODULE_PATH=$PREFIX/usr/lib/apache2/modules/mod_passenger.so OPTIMIZE=yes CACHING=false EXTRA_CFLAGS="$PASSENGER_CCOPTS" EXTRA_CXXFLAGS="$PASSENGER_CCOPTS"

cp -a $BUILD_DIR/passenger-$PASS_VERSION/pkg/fakeroot/* /
cd $BUILD_DIR/passenger-$PASS_VERSION
./dev/install_scripts_bootstrap_code.rb --ruby $RUBY_LIBDIR $PREFIX/bin/passenger* $PREFIX/sbin/passenger* `find $PREFIX -name rack_handler.rb`

./dev/install_scripts_bootstrap_code.rb --nginx-module-config $PREFIX/bin $PREFIX/usr/share/passenger/ngx_http_passenger_module/config
chmod +x $PREFIX/usr/share/passenger/helper-scripts/wsgi-loader.py
