#!/bin/bash
set -e

if [ "$1" = "slurmdbd" ]
then
    echo "---> Starting SSSD ..."
    /sbin/sssd --logger=stderr -d 3 -i 2>&1 &

    echo "---> Starting the MUNGE Authentication service (munged) ..."
    gosu munge /usr/sbin/munged

    echo "---> Starting the Slurm Database Daemon (slurmdbd) ..."

    {
        . /etc/slurm/slurmdbd.conf
        until echo "SELECT 1" | mysql -h $StorageHost -u$StorageUser -p$StoragePass 2>&1 > /dev/null
        do
            echo "-- Waiting for database to become active ..."
            sleep 2
        done
    }
    echo "-- Database is now active ..."

    echo "---> Starting sshd on the slurmdbd..."
    /usr/sbin/sshd -e

    exec gosu slurm /usr/sbin/slurmdbd -Dv
fi

if [ "$1" = "slurmctld" ]
then
    echo "---> Starting SSSD ..."
    /sbin/sssd --logger=stderr -d 3 -i 2>&1 &

    echo "---> Starting the MUNGE Authentication service (munged) ..."
    gosu munge /usr/sbin/munged

    echo "---> Waiting for slurmdbd to become active before starting slurmctld ..."

    until 2>/dev/null >/dev/tcp/slurmdbd/6819
    do
        echo "-- slurmdbd is not available.  Sleeping ..."
        sleep 2
    done
    echo "-- slurmdbd is now active ..."

    echo "---> Starting sshd on the slurmctld..."
    /usr/sbin/sshd -e

    echo "---> Starting the Slurm Controller Daemon (slurmctld) ..."
    exec gosu slurm /usr/sbin/slurmctld -Dv
fi

if [ "$1" = "slurmd" ]
then
    echo "---> Starting SSSD ..."
    /sbin/sssd --logger=stderr -d 3 -i 2>&1 &

    echo "---> Starting the MUNGE Authentication service (munged) ..."
    gosu munge /usr/sbin/munged

    echo "---> Waiting for slurmctld to become active before starting slurmd..."

    until 2>/dev/null >/dev/tcp/slurmctld/6817
    do
        echo "-- slurmctld is not available.  Sleeping ..."
        sleep 2
    done
    echo "-- slurmctld is now active ..."

    echo "---> Starting sshd on the slurmd..."
    /usr/sbin/sshd -e

    echo "---> Starting the Slurm Node Daemon (slurmd) ..."
    exec /usr/sbin/slurmd -Dv
fi

if [ "$1" = "frontend" ]
then
    echo "---> Starting SSSD ..."
    /sbin/sssd --logger=stderr -d 3 -i 2>&1 &

    echo "---> Starting the MUNGE Authentication service (munged) ..."
    gosu munge /usr/sbin/munged

    until scontrol ping | grep UP 2>&1 > /dev/null
    do
        echo "-- Waiting for slurmctld to become active ..."
        sleep 2
    done

    accts=$(sacctmgr list -P associations cluster=hpc format=Account,Cluster,User,Fairshare | wc -l)
    if [[ $accts -eq 3 ]]; then
        #------------------------
        # Run xdmod-setup
        #------------------------
        echo "Creating slurm associations.."
        sacctmgr -i add account staff Cluster=hpc Description=staff
        sacctmgr -i add user hpcadmin DefaultAccount=staff AdminLevel=Admin;
        sacctmgr -i add account sfoster Cluster=hpc Description="PI account sfoster"
        sacctmgr -i add user sfoster DefaultAccount=sfoster;
        sacctmgr -i add user astewart DefaultAccount=sfoster;
    fi

    echo "---> Starting sshd on the frontend..."
    /usr/sbin/sshd -D -e
fi

exec "$@"
