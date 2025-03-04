#!/bin/bash
set -e

trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

log_info() {
  printf "\n\e[0;35m $1\e[0m\n\n"
}

SLURM_VERSION=${SLURM_VERSION:-24.11.1}
WEBSOCKIFY_VERSION=${WEBSOCKIFY_VERSION:-0.12.0}
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
    python3-numpy \
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
#pip3 install numpy
#python3 setup.py install
python3 -m pip install .
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
popd
rm -rf /tmp/slurm*

log_info "Creating slurm user account.."
groupadd -r --gid=1000 slurm
useradd -r -g slurm --uid=1000 slurm

log_info "Setting up slurm directories.."
mkdir -p /etc/sysconfig/slurm \
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
ln -s /etc/pam.d/sshd /etc/pam.d/slurm

log_info "Creating munge key.."
/sbin/create-munge-key

log_info "Installing Jupyter.."
#python3 -m venv --without-pip --prompt jupyter/4.3.5 /usr/local/jupyter/4.3.5
python3 -m venv /usr/local/jupyter/4.3.5 --prompt jupyter/4.3.5
source /usr/local/jupyter/4.3.5/bin/activate

pip install jupyterlab==4.3.5 notebook jupyter-console qtconsole ipywidgets plotly==5.24.1 pandas scikit-learn numpy
deactivate

dnf clean all
rm -rf /var/cache/dnf
