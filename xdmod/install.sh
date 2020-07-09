#!/bin/bash
set -e

trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

log_info() {
  printf "\n\e[0;35m $1\e[0m\n\n"
}


# php-ldap is installed for XDMoD SSO via LDAP
# See https://open.xdmod.org for more information
log_info "Installing required packages for xdmod.."
yum install -y epel-release
yum install -y \
    httpd php php-cli php-mysql php-gd php-mcrypt \
    gmp-devel php-gmp php-pdo php-xml openssl mod_ssl \
    php-pear-MDB2 php-pear-MDB2-Driver-mysql \
    java-1.8.0-openjdk java-1.8.0-openjdk-devel \
    mariadb-server mariadb cronie logrotate expect \
    ghostscript php-mbstring php-pecl-apcu jq \
    php-ldap

#------------------------
# XDMoD Installation 
#------------------------
yum install -y https://tas-tools-ext-01.ccr.xdmod.org/9.0.0rc1/xdmod-9.0.0-0.1.rc1.el7.noarch.rpm \
               https://tas-tools-ext-01.ccr.xdmod.org/9.0.0rc1/xdmod-supremm-9.0.0-0.1.rc1.el7.noarch.rpm \
               https://github.com/ubccr/supremm/releases/download/1.4.0rc01/supremm-1.4.0-rc01.el7.x86_64.rpm

sed -i 's/.*date.timezone[[:space:]]*=.*/date.timezone = UTC/' /etc/php.ini

#------------------------
# supremm requirements
# mongoshell is an optional dependency for supremm
# pip and pexpect are needed for automated setup, not for supremm
#------------------------
yum install -y https://repo.mongodb.org/yum/redhat/7/mongodb-org/3.6/x86_64/RPMS/mongodb-org-shell-3.6.18-1.el7.x86_64.rpm \
               python2-pip -y
pip install pexpect==4.4.0
pip install pymongo --upgrade

# Create self-signed ssl cert
log_info "Creating self-signed ssl cert for xdmod.."
openssl req -x509 -nodes -days 365 -subj "/C=US/ST=NY/O=HPC Tutorial/CN=xdmod" -newkey rsa:2048 -keyout /etc/pki/tls/private/xdmod.key -out /etc/pki/tls/certs/xdmod.crt

rm -f /etc/httpd/conf.d/ssl.conf

#------------------------
# Install phatomjs
#------------------------
wget -O /var/tmp/phantomjs-2.1.1-linux-x86_64.tar.bz2 https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2
pushd /var/tmp
tar xvjf phantomjs-2.1.1-linux-x86_64.tar.bz2
cp phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin/
rm -Rf phantomjs-2.1.1-linux-x86_64*
popd

yum clean all
rm -rf /var/cache/yum
