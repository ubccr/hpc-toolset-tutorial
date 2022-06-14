# slurm.conf
#
# See the slurm.conf man page for more information.
#
ClusterName=hpc
ControlMachine=slurmctld
ControlAddr=slurmctld
SlurmUser=slurm
SlurmctldPort=6817
SlurmdPort=6818
AuthType=auth/munge
StateSaveLocation=/var/lib/slurmd
SlurmdSpoolDir=/var/spool/slurmd
SwitchType=switch/none
MpiDefault=none
SlurmctldPidFile=/var/run/slurmd/slurmctld.pid
SlurmdPidFile=/var/run/slurmd/slurmd.pid
ProctrackType=proctrack/linuxproc
ReturnToService=0

# These are example prolog and epilog scripts that show how it is possible
# to initiate performance data collection at the start and end of each
# job.
Prolog=/usr/local/bin/slurm-prolog.sh
Epilog=/usr/local/bin/slurm-epilog.sh

#
# TIMERS
SlurmctldTimeout=300
SlurmdTimeout=300
InactiveLimit=0
MinJobAge=300
KillWait=30
Waittime=0

#
# SCHEDULING
SchedulerType=sched/backfill
SelectType=select/cons_res
SelectTypeParameters=CR_CPU_Memory

#
# LOGGING
SlurmctldDebug=info
SlurmctldLogFile=/var/log/slurm/slurmctld.log
SlurmdDebug=info
SlurmdLogFile=/var/log/slurm/slurmd.log
JobCompType=jobcomp/filetxt
JobCompLoc=/var/log/slurm/jobcomp.log

#
# ACCOUNTING
JobAcctGatherType=jobacct_gather/linux
JobAcctGatherFrequency=30
AccountingStorageType=accounting_storage/slurmdbd
AccountingStorageHost=slurmdbd
AccountingStorageEnforce=associations,limits,qos
AccountingStoreFlags=job_comment

#
# COMPUTE NODES
NodeName=cpn[01-02] RealMemory=1000 State=UNKNOWN


# PARTITIONS
PartitionName=compute Default=yes Nodes=cpn[01-02] Priority=50 DefMemPerCPU=500 Shared=NO MaxNodes=2 MaxTime=5-00:00:00 DefaultTime=5-00:00:00 State=UP
PartitionName=debug Nodes=cpn[01-02] Priority=50 DefMemPerCPU=500 Shared=NO MaxNodes=2 MaxTime=5-00:00:00 DefaultTime=5-00:00:00 State=UP
