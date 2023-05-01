## Overview

In this tutorial we present three open source projects that form a core set of utilities commonly installed at High Performance Computing (HPC) centers.

An overview of the containers in the cluster:

![Container Overview](HPC-Toolset-sm.png)

## Requirements

If you haven't already installed and tested the required packages, please refer to the [requirements page](requirements.md)

## Getting started

You will need to clone the tutorial repo and then run the helper script.  The initial clone of the repo may take 5-10 minutes.  The first time running the helper script, you'll be downloading all the containers from Docker Hub.  This can take quite a long time depending on your network speed.  The images total approximately 20GB in size.  Once the containers are downloaded, they are started and the services launched.  For point of reference: on a recent test from a home fiber optic network with client connected over wifi this download and container startup process took 12 minutes.  


### Clone Repo and Start Containers

```
$ git clone https://github.com/ubccr/hpc-toolset-tutorial.git
$ cd hpc-toolset-tutorial
$ ./hpcts start
Fetching latest HPC Toolset Images..

[+] Running 12/12
 - base Pulled                                                                              5.2s
 - ondemand Pulled                                                                          5.3s
 - cpn01 Pulled                                                                             5.3s
 - cpn02 Pulled                                                                             5.1s
 - mongodb Pulled                                                                           5.2s
 - xdmod Pulled                                                                             5.1s
 - ldap Pulled                                                                              5.2s
 - mysql Pulled                                                                             5.2s
 - coldfront Pulled                                                                         5.2s
 - frontend Pulled                                                                          5.2s
 - slurmdbd Pulled                                                                          5.1s
 - slurmctld Pulled                                                                         5.2s

Starting HPC Toolset Cluster..

[+] Running 23/23
 - Network hpc-toolset-tutorial_compute              Created                                0.1s
 - Volume "hpc-toolset-tutorial_etc_slurm"           Created                                0.0s
 - Volume "hpc-toolset-tutorial_cpn02_slurmd_state"  Created                                0.0s
 - Volume "hpc-toolset-tutorial_slurmdbd_state"      Created                                0.0s
 - Volume "hpc-toolset-tutorial_slurmctld_state"     Created                                0.0s
 - Volume "hpc-toolset-tutorial_data_db"             Created                                0.0s
 - Volume "hpc-toolset-tutorial_home"                Created                                0.0s
 - Volume "hpc-toolset-tutorial_var_lib_mysql"       Created                                0.0s
 - Volume "hpc-toolset-tutorial_srv_www"             Created                                0.0s
 - Volume "hpc-toolset-tutorial_cpn01_slurmd_state"  Created                                0.0s
 - Volume "hpc-toolset-tutorial_etc_munge"           Created                                0.0s
 - Container mongodb                                 Started                               12.0s
 - Container mysql                                   Started                               11.9s
 - Container ldap                                    Started                               11.8s
 - Container hpc-toolset-tutorial-base-1             Started                               12.3s
 - Container slurmdbd                                Started                               13.2s
 - Container slurmctld                               Started                               13.0s
 - Container frontend                                Started                               15.2s
 - Container cpn02                                   Started                               14.2s
 - Container cpn01                                   Started                               15.2s
 - Container ondemand                                Started                               15.2s
 - Container coldfront                               Started                               15.7s
 - Container xdmod                                   Started                               15.5s

 Coldfront URL: https://localhost:2443


 OnDemand URL: https://localhost:3443


 XDMoD URL: https://localhost:4443


 Login to frontend: ssh -p 6222 hpcadmin@localhost

```

**NOTE:  Despite seeing this output with URLs, the processes on these containers may not be fully running yet.  Depending on the speed of your computer, starting up the processes may take a few minutes (or even up to 10 minutes).  Use the command below to check the docker logs if the websites are not yet displaying.**



### Docker Logs

Once the helper script finishes you can check the status of the containers:

```
$ docker-compose logs -f
mysql        | 200620  4:03:42 [Note] Event Scheduler: Loaded 0 events
mysql        | 200620  4:03:42 [Note] mysqld: ready for connections.
frontend     | ---> Starting the MUNGE Authentication service (munged) ...
frontend     | ---> Starting sshd on the frontend...
cpn01        | slurmd: Munge credential signature plugin loaded
cpn01        | slurmd: CPUs=1 Boards=1 Sockets=1 Cores=1 Threads=1 Memory=15575 TmpDisk=229951 Uptime=43696 CPUSpecList=(null) FeaturesAvail=(null) FeaturesActive=(null)
cpn02        | slurmd: debug:  AcctGatherEnergy NONE plugin loaded
coldfront    | -- Waiting for database to become active ...
coldfront    | -- Initializing coldfront database...
ondemand     | ---> Starting ondemand httpd24...
slurmdbd     | slurmdbd: debug2: DBD_NODE_STATE_UP: NODE:cpn01 REASON:(null) TIME:1592625828
slurmctld    | slurmctld: SchedulerParameters=default_queue_depth=100,max_rpc_cnt=0,max_sched_time=2,partition_job_depth=0,sched_max_job_start=0,sched_min_interval=2
xdmod        | 2020-06-21 19:23:48 [notice] xdmod-ingestor end (process_end_time: 2020-06-21 19:23:48)
xdmod        | ---> Starting XDMoD...
```

## Something still not right?

Please see our [troubleshooting section](docker_tips.md) for more info.

If errors are showing up in the logs or the services have not all started, check to see which images have been downloaded and which containers are running.  This is what you should see:  
![](containers_images.PNG)  

If not, run the 'destroy' option of the helper script to shut everything down and remove all volumes.  Then start everything back up again:  

```
$ ./hpcts destroy
$ docker container list
(Should show no containers)

$ docker volume list
(Should show no volumes)
```

If either of the above do, you should run the corresponding remove command:  

```
$ docker container rm [ContainerID]
$ docker volume rm [VolumeName]
```

Then start it all up again:  

```
./hpcts start
```

Since you already downloaded all the images, this command will only startup the containers and services which only takes a few minutes.  

To completely start over and re-download all images, run the cleanup script and then startup script:  

```
$ ./hpcts cleanup
$ ./hpcts start
```
NOTE:  The cleanup script removes ALL containers, images and volumes except the mongo and mariadb images.  If you're getting database errors we recommend you remove these manually with these docker commands:  

```
$ docker image list  
$ docker image rm [IMAGE IDs for mongo and mariadb images]  
$ ./hpcts start  
```

## Tutorial Navigation
[Next - Accessing the Applications](applications.md)  
[Docker Tips](docker_tips.md)  
[Back to Start](../README.md)
