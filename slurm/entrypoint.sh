#!/bin/bash
set -e

if [ "$1" = "slurmdbd" ]
then
    echo "---> Starting SSSD ..."
    # Sometimes on shutdown pid still exists, so delete it
    rm -f /var/run/sssd.pid
    /sbin/sssd --logger=stderr -d 2 -i 2>&1 &

    echo "---> Starting the MUNGE Authentication service (munged) ..."
    gosu munge /usr/sbin/munged

    echo "---> Starting sshd on the slurmdbd..."
    /usr/sbin/sshd -e

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

    exec gosu slurm /usr/sbin/slurmdbd -Dv
fi

if [ "$1" = "slurmctld" ]
then
    echo "---> Starting SSSD ..."
    # Sometimes on shutdown pid still exists, so delete it
    rm -f /var/run/sssd.pid
    /sbin/sssd --logger=stderr -d 2 -i 2>&1 &

    echo "---> Starting the MUNGE Authentication service (munged) ..."
    gosu munge /usr/sbin/munged

    echo "---> Starting sshd on the slurmctld..."
    /usr/sbin/sshd -e

    echo "---> Waiting for slurmdbd to become active before starting slurmctld ..."

    until 2>/dev/null >/dev/tcp/slurmdbd/6819
    do
        echo "-- slurmdbd is not available.  Sleeping ..."
        sleep 2
    done
    echo "-- slurmdbd is now active ..."

    echo "---> Starting the Slurm Controller Daemon (slurmctld) ..."
    exec gosu slurm /usr/sbin/slurmctld -Dv
fi

if [ "$1" = "slurmd" ]
then
    echo "---> Starting SSSD ..."
    # Sometimes on shutdown pid still exists, so delete it
    rm -f /var/run/sssd.pid
    /sbin/sssd --logger=stderr -d 2 -i 2>&1 &

    echo "---> Starting the MUNGE Authentication service (munged) ..."
    gosu munge /usr/sbin/munged

    echo "---> Starting sshd on the slurmd..."
    /usr/sbin/sshd -e

    echo "---> Waiting for slurmctld to become active before starting slurmd..."

    until 2>/dev/null >/dev/tcp/slurmctld/6817
    do
        echo "-- slurmctld is not available.  Sleeping ..."
        sleep 2
    done
    echo "-- slurmctld is now active ..."

    echo "---> Starting pmcd on the slurmd..."
    /usr/libexec/pcp/lib/pmcd start-systemd

    echo "---> Starting pmlogger on the slurmd.."
    /usr/libexec/pcp/lib/pmlogger start-systemd

    echo "---> Starting the Slurm Node Daemon (slurmd) ..."
    exec /usr/sbin/slurmd -Dv
fi

if [ "$1" = "frontend" ]
then
    echo "---> Starting SSSD ..."
    # Sometimes on shutdown pid still exists, so delete it
    rm -f /var/run/sssd.pid
    /sbin/sssd --logger=stderr -d 2 -i 2>&1 &

    echo "---> Starting the MUNGE Authentication service (munged) ..."
    gosu munge /usr/sbin/munged

    until scontrol ping | grep UP 2>&1 > /dev/null
    do
        echo "-- Waiting for slurmctld to become active ..."
        sleep 2
    done

    accts=$(sacctmgr list -P associations cluster=hpc format=Account,Cluster,User,Fairshare | wc -l)
    if [[ $accts -eq 3 ]]; then
        echo "Creating slurm associations.."
        sacctmgr -i add account staff Cluster=hpc Description=staff
        sacctmgr -i add user hpcadmin DefaultAccount=staff AdminLevel=Admin
        sacctmgr -i add account sfoster Cluster=hpc Description="PI account sfoster"
        sacctmgr -i add user sfoster DefaultAccount=sfoster
        sacctmgr -i add user astewart DefaultAccount=sfoster
        scontrol reconfigure
    fi

    # Add partition associations if they don't exist
    part_accts=$(sacctmgr list -P associations cluster=hpc partition=compute format=User | wc -l)
    if [[ $part_accts -eq 1 ]]; then
        echo "Adding partition associations.."
        sacctmgr -i add user sfoster account=sfoster cluster=hpc partition=compute
        sacctmgr -i add user sfoster account=sfoster cluster=hpc partition=debug
        sacctmgr -i add user astewart account=sfoster cluster=hpc partition=compute
        sacctmgr -i add user astewart account=sfoster cluster=hpc partition=debug
        sacctmgr -i add user hpcadmin account=staff cluster=hpc partition=compute
        sacctmgr -i add user hpcadmin account=staff cluster=hpc partition=debug
        # Ensure default accounts are set correctly after adding partition associations
        sacctmgr -i modify user where name=sfoster set defaultaccount=sfoster
        sacctmgr -i modify user where name=astewart set defaultaccount=sfoster
        sacctmgr -i modify user where name=hpcadmin set defaultaccount=staff
        scontrol reconfigure
    fi

    echo "---> Starting sshd on the frontend..."
    /usr/sbin/sshd -D -e

fi

exec "$@"
