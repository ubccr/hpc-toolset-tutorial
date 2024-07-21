#!/bin/bash
set -e

trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

log_info() {
  printf "\n\e[0;35m $1\e[0m\n\n"
}

SLURM_VERSION=${SLURM_VERSION:-21.08.8-2}
WEBSOCKIFY_VERSION=${WEBSOCKIFY_VERSION:-0.11.0}
ARCHTYPE=`uname -m`

log_info "Installing required packages for building slurm.."
curl -o /etc/yum.repos.d/turbovnc.repo https://raw.githubusercontent.com/TurboVNC/repo/main/TurboVNC.repo
dnf -y install dnf-plugins-core
dnf -y config-manager --set-enabled powertools
dnf -y module enable ruby:3.0 nodejs:14
dnf install -y \
    @Development \
    munge \
    munge-devel \
    libcgroup \
    curl \
    bzip2 \
    readline-devel \
    numactl-devel \
    pam-devel \
    glib2-devel \
    hwloc-devel \
    openssl-devel \
    curl-devel \
    mariadb \
    turbovnc \
    mariadb-devel \
    python39 \
    python39-devel \
    python2-numpy \
    kitty-terminfo \
    stress

log_info "Installing compute packages .."

alternatives --set python3 /usr/bin/python3.9

dnf groupinstall -y "Xfce"

log_info "Compiling python-websockify version ${WEBSOCKIFY_VERSION}.."
wget -O /tmp/websockify-${WEBSOCKIFY_VERSION}.tar.gz https://github.com/novnc/websockify/archive/refs/tags/v${WEBSOCKIFY_VERSION}.tar.gz
pushd /tmp
tar xzf websockify-${WEBSOCKIFY_VERSION}.tar.gz
pushd websockify-${WEBSOCKIFY_VERSION}
python3 setup.py install
popd
rm -rf /tmp/websockify*

log_info "Compiling slurm version ${SLURM_VERSION}.."
curl -o /tmp/slurm-${SLURM_VERSION}.tar.bz2 https://download.schedmd.com/slurm/slurm-${SLURM_VERSION}.tar.bz2
pushd /tmp
tar xf slurm-${SLURM_VERSION}.tar.bz2
pushd slurm-${SLURM_VERSION}
./configure --prefix=/usr --sysconfdir=/etc/slurm 
make -j4
make install
install -D -m644 etc/cgroup.conf.example /etc/slurm/cgroup.conf.example
install -D -m644 etc/slurm.conf.example /etc/slurm/slurm.conf.example
install -D -m644 etc/slurmdbd.conf.example /etc/slurm/slurmdbd.conf.example
install -D -m644 contribs/slurm_completion_help/slurm_completion.sh /etc/profile.d/slurm_completion.sh
popd
rm -rf /tmp/slurm*

log_info "Creating slurm user account.."
groupadd -r --gid=1000 slurm
useradd -r -g slurm --uid=1000 slurm

log_info "Setting up slurm directories.."
mkdir /etc/sysconfig/slurm \
    /var/spool/slurmd \
    /var/run/slurmd \
    /var/run/slurmdbd \
    /var/lib/slurmd \
    /var/log/slurm \
    /data

touch /var/lib/slurmd/node_state \
    /var/lib/slurmd/front_end_state \
    /var/lib/slurmd/job_state \
    /var/lib/slurmd/resv_state \
    /var/lib/slurmd/trigger_state \
    /var/lib/slurmd/assoc_mgr_state \
    /var/lib/slurmd/assoc_usage \
    /var/lib/slurmd/qos_usage \
    /var/lib/slurmd/fed_mgr_state

chown -R slurm:slurm /var/*/slurm*

log_info "Creating munge key.."
/sbin/create-munge-key

log_info "Installing performance data collection software.."
dnf install -y pcp

mkdir -p /run/pcp
ln -s /usr/lib/systemd/system/pmlogger.service /etc/systemd/system/multi-user.target.wants/pmlogger.service

log_info "Setting PCP defaults suitable for running in a container.."
echo -e "# Disable Avahi (since it does not run inside the containers)\n-A" >> /etc/pcp/pmcd/pmcd.options

log_info "Configuring PCP logger with suitable container defaults.."
sed -i 's#^LOCALHOSTNAME.*$#LOCALHOSTNAME   y   n   "/home/pcp/$(date +%Y)/$(date +%m)/LOCALHOSTNAME/$(date +%Y)-$(date +%m)-$(date +%d)"   -r -c /etc/pcp/pmlogger/pmlogger-supremm.config#' /etc/pcp/pmlogger/control.d/local

log_info "Installing Jupyter.."
python3 -m venv --without-pip --prompt jupyter/2.1.4 /usr/local/jupyter/2.1.4
source /usr/local/jupyter/2.1.4/bin/activate
curl https://bootstrap.pypa.io/get-pip.py | python

pip install jupyterlab==2.1.4 jupyter-console qtconsole ipywidgets plotly==4.8.2 pandas scikit-learn numpy
deactivate

dnf clean all
rm -rf /var/cache/dnf
