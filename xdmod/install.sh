#!/bin/bash
set -e

trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

log_info() {
  printf "\n\e[0;35m $1\e[0m\n\n"
}

log_info "Installing required packages for xdmod.."

#------------------------
# Open XDMoD has several dependencies that are satisfied by
# packages available in EPEL
#------------------------
yum install -y epel-release

#------------------------
# For the purpose of the tutorial we install some extra packages that
# facilitate the automatic install. These are not requirements for Open XDMoD
# itself. The expect and pexpect software are used to automate the interactive
# setup. We install the mongoshell is an optional dependency for supremm pip and pexpect are
# needed for automated setup, not for supremm
#------------------------

yum install -y \
    expect \
    python2-pip

pip install pexpect==4.4.0

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
yum install -y https://tas-tools-ext-01.ccr.xdmod.org/9.0.0rc3/xdmod-9.0.0-0.3.rc3.el7.noarch.rpm \
               https://tas-tools-ext-01.ccr.xdmod.org/9.0.0rc3/xdmod-supremm-9.0.0-0.3.rc3.el7.noarch.rpm \
               https://github.com/ubccr/supremm/releases/download/1.4.0rc01/supremm-1.4.0-rc01.el7.x86_64.rpm

#------------------------
# phantomjs is used by Open XDMoD for chart image export and for the
# report generator.
#------------------------
wget -O /var/tmp/phantomjs-2.1.1-linux-x86_64.tar.bz2 https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2
pushd /var/tmp
tar xvjf phantomjs-2.1.1-linux-x86_64.tar.bz2 phantomjs-2.1.1-linux-x86_64/bin/phantomjs
cp phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin/
rm -Rf phantomjs-2.1.1-linux-x86_64*
popd

#------------------------
# The Job Performance software uses MongoDB to store the job-level performance
# data and the job timeseries data. Here we ensure that the version of the mongo driver
# is recent enough to work with the containerized mongo (3.6).
# The appropriate mongo shell is also installed so it can be used as part of the setup.
#------------------------

yum install -y \
    https://repo.mongodb.org/yum/redhat/7/mongodb-org/3.6/x86_64/RPMS/mongodb-org-shell-3.6.18-1.el7.x86_64.rpm

pip install pymongo --upgrade

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
# These commands remove cached files to reduce the overall image size.
#------------------------
yum clean all
rm -rf /var/cache/yum
