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
yum install -y https://github.com/ubccr/xdmod/releases/download/v9.5.0/xdmod-9.5.0-1.0.el7.noarch.rpm \
               https://github.com/ubccr/xdmod-supremm/releases/download/v9.5.0/xdmod-supremm-9.5.0-1.0.el7.noarch.rpm \
               https://github.com/ubccr/supremm/releases/download/1.4.1/supremm-1.4.1-1.el7.x86_64.rpm

#------------------------
# The Job Performance software uses MongoDB to store the job-level performance
# data and the job timeseries data. Here we ensure that the version of the mongo driver
# is recent enough to work with the containerized mongo (3.6).
# The appropriate mongo shell is also installed so it can be used as part of the setup.
#------------------------

yum install -y \
    https://repo.mongodb.org/yum/redhat/7/mongodb-org/3.6/x86_64/RPMS/mongodb-org-shell-3.6.18-1.el7.x86_64.rpm

pip install pymongo==3.12.3 --upgrade

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

#------------------------
# OnDemand Module Setup:
#   - Make sure to create the directory that will contain the OnDemand log files for use with
#     the OnDemand XDMoD Module.
#------------------------
mkdir -p /scratch/ondemand

mkdir -p /srv/xdmod/backups
