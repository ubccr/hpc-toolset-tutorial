#!/bin/bash
set -e

trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

log_info() {
  printf "\n\e[0;35m $1\e[0m\n\n"
}

source /build/base.config

GOSU_VERSION=${GOSU_VERSION:-1.12}

#------------------------
# Install base packages
#------------------------
log_info "Installing base packages.."
yum install -y \
    openssh-server \
    sudo \
    epel-release \
    wget \
    vim

#------------------------
# Generate ssh host keys
#------------------------
log_info "Generating ssh host keys.."
ssh-keygen -t rsa -N '' -f /etc/ssh/ssh_host_rsa_key
ssh-keygen -t ecdsa -N '' -f /etc/ssh/ssh_host_ecdsa_key
ssh-keygen -t ed25519 -N '' -f /etc/ssh/ssh_host_ed25519_key
chgrp ssh_keys /etc/ssh/ssh_host_rsa_key
chgrp ssh_keys /etc/ssh/ssh_host_ecdsa_key
chgrp ssh_keys /etc/ssh/ssh_host_ed25519_key

#------------------------
# Setup user accounts
#------------------------

idnumber=1000
for uid in hpcadmin $USERS
do
    log_info "Creating $uid user account with uidnumber $idnumber.."
    passvar="PASSWD_$uid"
    passwd=${!passvar:-ilovelinux}
    groupadd --gid $idnumber $uid
    useradd  --gid $idnumber --uid $idnumber $uid
    echo -n $passwd  | passwd --stdin $uid
	install -d -o $uid -g $uid -m 0700 /home/$uid/.ssh
    sudo -u $uid ssh-keygen -b 2048 -t rsa -f /home/$uid/.ssh/id_rsa -q -N ""
    install -o $uid -g $uid -m 0600 /home/$uid/.ssh/id_rsa.pub /home/$uid/.ssh/authorized_keys
	sudo -u $uid tee /home/$uid/.ssh/config <<EOF
Host *
   StrictHostKeyChecking no
   UserKnownHostsFile=/dev/null
EOF
	chmod 0600 /home/$uid/.ssh/config

    idnumber=$((idnumber + 1))
done

sudo tee /etc/sudoers.d/90-hpcadmin <<EOF
# User rules for hpcadmin
hpcadmin ALL=(ALL) NOPASSWD:ALL
EOF
chmod 0440 /etc/sudoers.d/90-hpcadmin

#------------------------
# Install gosu
#------------------------
log_info "Installing gosu.."
wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64"
chmod +x /usr/local/bin/gosu
gosu nobody true
