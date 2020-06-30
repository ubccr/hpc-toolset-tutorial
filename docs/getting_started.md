## Overview

In this tutorial we present three open source projects that form a core set of
utilities commonly installed at High Performance Computing (HPC) centers.

An overview of the containers in the cluster:

![Container Overview](HPC-Toolset-sm.png)


## Getting started

There are two ways to start the multi-container HPC Toolset cluster using docker-compose.  The first shown here will pull pre-made containers from Docker Hub. We recommend this if you want to save time on the building process and have a fast internet connection to pull down the images from Docker Hub:

```
$ git clone https://github.com/ubccr/hpc-toolset-tutorial.git
$ cd hpc-toolset-tutorial
$ docker-compose pull
Pulling base      ... done
Pulling mysql     ... done
Pulling slurmdbd  ... done
Pulling slurmctld ... done
Pulling cpn01     ... done
Pulling cpn02     ... done
Pulling frontend  ... done
Pulling coldfront ... done
Pulling ondemand  ... done
Pulling xdmod     ... done
$
```

This second option creates the containers, installs all the applications, configures and sets up accounts.  We recommend this if you'd like to see all that goes on during the install/setup procedures and especially if you have a slow internet connection.  When first building the container images, the above command can take anywhere from 10-20 minutes to complete, depending on your local system resources, as it will compile slurm from source and install required packages and the three applications: ColdFront, XDMoD, and OnDemand.

```
$ git clone https://github.com/ubccr/hpc-toolset-tutorial.git
$ cd hpc-toolset-tutorial
$ docker-compose up -d
```

NOTE: Windows users will get several pop-up messages from Docker Desktop during this process asking to allow local system access to the Docker containers.  Please click the "Share it" button:
![](windows_sharing.PNG)




Once docker-compose finishes you can check the status of the containers:

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


You can also use the helper bash script: `hpcts` to stop and start cluster:

```
./hpcts start

 Starting HPC Toolset Cluster..

Creating network "hpcts-tutorial_default" with the default driver
Creating network "hpcts-tutorial_compute" with the default driver
Creating volume "hpcts-tutorial_etc_munge" with default driver
Creating volume "hpcts-tutorial_etc_slurm" with default driver
Creating volume "hpcts-tutorial_home" with default driver
Creating volume "hpcts-tutorial_var_lib_mysql" with default driver
Creating volume "hpcts-tutorial_srv_www" with default driver
Creating hpcts-tutorial_base_1 ... done
Creating mysql                         ... done
Creating slurmdbd                      ... done
Creating slurmctld                     ... done
Creating cpn02                         ... done
Creating frontend                      ... done
Creating cpn01                         ... done
Creating ondemand                      ... done
Creating xdmod                         ... done
Creating coldfront                     ... done

 Coldfront URL: https://localhost:2443


 OnDemand URL: https://localhost:3443


 XDMoD URL: https://localhost:4443
```
NOTE:  Despite seeing this output with URLs, the processes on these containers may not be fully running yet.  Depending on the speed of your computer, starting up the processes may take a few minutes.  Use the above command to check the docker logs if the websites are not yet displaying.


## Tutorial Navigation
[Next - Accessing the Applications](applications.md)  
[Back to Start](../README.md)
