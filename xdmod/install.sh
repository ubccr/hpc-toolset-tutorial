#!/bin/bash
set -e

trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

log_info() {
  printf "\n\e[0;35m $1\e[0m\n\n"
}

log_info "Installing required packages for xdmod.."

ARCHTYPE=`uname -m`

#------------------------
# For the purpose of the tutorial we install some extra packages that
# facilitate the automatic install. These are not requirements for Open XDMoD
# itself. The expect and pexpect software are used to automate the interactive
# setup. We install the mongoshell is an optional dependency for supremm pip and pexpect are
# needed for automated setup, not for supremm
#------------------------

dnf module -y reset nodejs
dnf module -y install nodejs:16

dnf install -y \
    expect \
    python3-devel \
    python3-scipy \
    pcp-devel \
    python3-pexpect \
    php-pear \
    php-devel

#------------------------
# Open XDMoD Installation
#
# The xdmod RPM contains the main Open XDMoD software.
# The xdmod-supremm RPM contains the Job Performance module for XDMoD.
# The supremm RPM contains the software that generates job performance summaries from the performance
# data collected on the compute nodes.
#
# In this tutorial both the Open XDMoD software and the job summarization software will
# be installed in the same container.  In a production deployment they may be installed
# on separate hosts.
#------------------------
dnf install -y https://github.com/ubccr/xdmod/releases/download/v10.0.2-2-el8/xdmod-10.0.2-2.0.el8.noarch.rpm \
               https://github.com/ubccr/xdmod-ondemand/releases/download/v10.0.0/xdmod-ondemand-10.0.0-1.0.beta1.el8.noarch.rpm \
               https://github.com/ubccr/xdmod-supremm/releases/download/v10.0.1-rc.1/xdmod-supremm-10.0.1-1.0.rc01.el8.noarch.rpm

# supremm rpm has broken deps so we force install the rpm and install the deps via pip
rpm --nodeps -ivh https://github.com/ubccr/supremm/releases/download/2.0.0-beta3/supremm-2.0.0-1.0_beta3.el8."$ARCHTYPE".rpm

#------------------------
# The Job Performance software uses MongoDB to store the job-level performance
# data and the job timeseries data. Here we ensure that the version of the mongo driver
# is recent enough to work with the containerized mongo (3.6).
# The appropriate mongo shell is also installed so it can be used as part of the setup.
#------------------------

dnf install -y \
    https://repo.mongodb.org/yum/redhat/8/mongodb-org/5.0/${ARCHTYPE}/RPMS/mongodb-org-shell-5.0.9-1.el8.${ARCHTYPE}.rpm


#------------------------
#
#------------------------
pecl install mongodb
echo "extension=mongodb.so" >> /etc/php.d/40-mongodb.ini

# This is required because /usr/bin/supremm-setup uses the platform-python
/usr/libexec/platform-python -m pip install pymongo==3.7.0 --upgrade
/usr/libexec/platform-python -m pip install pytz
/usr/libexec/platform-python -m pip install Cython
/usr/libexec/platform-python -m pip install pcp
/usr/libexec/platform-python -m pip install PyMySQL

#------------------------
# O/S package configuration.
#------------------------

#------------------------
# Some Linux distributions (including CentOS) do not set the timezone used by PHP
# in their default configuration. This will result in many warning messages from PHP.
# The following sets this php configuration. A production install should set this
# to the appropriate timezone.
#------------------------
sed -i 's/.*date.timezone[[:space:]]*=.*/date.timezone = UTC/' /etc/php.ini

#------------------------
# The container includes an apache configuration file that enables SSL on
# port 4443. A production Open XDMoD install must use SSL, but there are no port
# number restrictions.
#
# The httpd rpm is configured to listen to port 443. Remove this configuration since
# we use a different port for the tutorial.
#------------------------
rm -f /etc/httpd/conf.d/ssl.conf

#------------------------
# We need to make sure that we have access to this file so that SSO works.
#------------------------
if [[ -f /etc/pki/tls/private/localhost.key ]]; then
    chown root:apache /etc/pki/tls/private/localhost.key
    chmod 750         /etc/pki/tls/private/localhost.key
fi

#------------------------
# These commands remove cached files to reduce the overall image size.
#------------------------
dnf clean all
rm -rf /var/cache/dnf

#------------------------
# OnDemand Module Setup:
# Create the directory that will contain the Open OnDemand log files for use with
# the Open OnDemand XDMoD Module. Also copy in some 'historical' data for
# display during the tutorial.
#------------------------
mkdir -p /scratch/ondemand/logs
cp /srv/xdmod/historical/localhost_access_ssl-20220706.log /scratch/ondemand/logs
chmod 750 /scratch/ondemand/logs
# note - the file permissions will be set to hpcadmin:xdmod after the hpcadmin
#        user has been created later in the build


mkdir -p /srv/xdmod/backups
