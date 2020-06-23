# HPC Toolset Tutorial

Tutorial for installing and configuring XDMoD, OnDemand, and ColdFront: an HPC center
management toolset.

TODO: write me

[Requirements](https://github.com/ubccr/hpc-toolset-tutorial#requirements)

[Overview](https://github.com/ubccr/hpc-toolset-tutorial#overview)

[Getting Started](https://github.com/ubccr/hpc-toolset-tutorial#getting-started)

[Accessing the Applications](https://github.com/ubccr/hpc-toolset-tutorial#accessing-the-applications)

* [User Accounts](https://github.com/ubccr/hpc-toolset-tutorial#user-accounts)
* [ColdFront](https://github.com/ubccr/hpc-toolset-tutorial#coldfront)
* [OnDemand](https://github.com/ubccr/hpc-toolset-tutorial#ondemand)
* [XDMoD](https://github.com/ubccr/hpc-toolset-tutorial#xdmod)
* [Cluster Frontend](https://github.com/ubccr/hpc-toolset-tutorial#cluster-frontend)
* [Slurm](https://github.com/ubccr/hpc-toolset-tutorial#slurm)

[Docker Tips](https://github.com/ubccr/hpc-toolset-tutorial#finding-ip-address-of-container)

[Acknowledgements](https://github.com/ubccr/hpc-toolset-tutorial#acknowledgments)

## <a name="requirements"></a>Requirements

For this tutorial you will need to have docker installed on your local machine.  This has been tested on Linux, MacOS, and Windows 10:

- docker version 19.03.8+
- docker-compose 1.25.2+

NOTE: For Windows, if you haven't already done so, you will need to configure git not to convert line endings into Windows format.  Run this command before cloning the tutorial repo:
```
git config --global core.autocrlf input
```


## Overview

In this tutorial we present three open source projects that form a core set of
utilities commonly installed at High Performance Computing (HPC) centers. 

An overview of the containers in the cluster:

![Container Overview](docs/HPC-Toolset-sm.png)

## Getting started

There are two ways to start the multi-container HPC Toolset cluster using docker-compose.  The first shown here will pull pre-made containers from Docker Hub. We recommend this if you want to save time on the building process and have a fast internet connection to pull down the images from Docker Hub:

```
$ git clone git@github.com:ubccr/hpc-toolset-tutorial.git
$ cd hpc-toolset-tutorial
$ docker-compose pull
Pulling base      ... done
Pulling mysql     ... done
Pulling slurmdbd  ... done
Pulling slurmctld ... done
Pulling c1        ... done
Pulling c2        ... done
Pulling frontend  ... done
Pulling coldfront ... done
Pulling ondemand  ... done
Pulling xdmod     ... done
$ 
```

This second option creates the containers, installs all the applications, configures and sets up accounts.  We recommend this if you'd like to see all that goes on during the install/setup procedures and especially if you have a slow internet connection.  When first building the container images, the above command can take anywhere from 10-20 minutes to complete, depending on your local system resources, as it will compile slurm from source and install required packages and the three applications: ColdFront, XDMoD, and OnDemand. 

```
$ git clone git@github.com:ubccr/hpc-toolset-tutorial.git
$ cd hpc-toolset-tutorial
$ docker-compose up -d
```

NOTE: Windows users will get several pop-up messages from Docker Desktop during this process asking to allow local system access to the Docker containers.  Please click the "Share it" button:
![](https://github.com/ubccr/hpc-toolset-tutorial/blob/master/docs/windows_sharing.PNG)




Once docker-compose finishes you can check the status of the containers:

```
$ docker-compose logs -f
mysql        | 200620  4:03:42 [Note] Event Scheduler: Loaded 0 events
mysql        | 200620  4:03:42 [Note] mysqld: ready for connections.
frontend     | ---> Starting the MUNGE Authentication service (munged) ...
frontend     | ---> Starting sshd on the frontend...
c1           | slurmd: Munge credential signature plugin loaded
c1           | slurmd: CPUs=1 Boards=1 Sockets=1 Cores=1 Threads=1 Memory=15575 TmpDisk=229951 Uptime=43696 CPUSpecList=(null) FeaturesAvail=(null) FeaturesActive=(null)
c2           | slurmd: debug:  AcctGatherEnergy NONE plugin loaded
coldfront    | -- Waiting for database to become active ...
coldfront    | -- Initializing coldfront database...
ondemand     | ---> Starting ondemand httpd24...
slurmdbd     | slurmdbd: debug2: DBD_NODE_STATE_UP: NODE:c1 REASON:(null) TIME:1592625828
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
Creating c2                            ... done
Creating frontend                      ... done
Creating c1                            ... done
Creating ondemand                      ... done
Creating xdmod                         ... done
Creating coldfront                     ... done

 Coldfront URL: https://localhost:2443


 OnDemand URL: https://localhost:3443


 XDMoD URL: https://localhost:4443
```
NOTE:  Despite seeing this output with URLs, the processes on these containers may not be fully running yet.  Depending on the speed of your computer, starting up the processes may take a few minutes.  Use the above command to check the docker logs if the websites are not yet displaying.


## Accessing the Applications

Now that your containers have been created and applications launched, you can login to them using your browser and via SSH.

### User Accounts

By default, all containers have local user accounts created. You can login with
to the containers via ssh, login to Coldfront and OnDemand with the same user
credentials. Default password for all accounts: ilovelinux

- hpcadmin
- cgray (password: test123)
- sfoster
- csimmons
- astewart

### Coldfront

Login to Coldfront and setup allocations.

Point your browser at the Coldfront container https://localhost:2443

You can login with user: admin password: admin

You can also login with any of the local system accounts that were created.

### OnDemand

Login to OnDemand

Point your browser at the OnDemand container https://localhost:3443

You can login with any of the local system accounts that were created. Click on
"Clusters" and then "HPC Cluster Shell Access" and you should have a login
shell on the frontend container.

### XDMoD

Login to XDMoD

Point your browser at the XDMoD container https://localhost:4443

You can login with user: admin password: admin

### Cluster Frontend

Login to frontend with SSH:
```
ssh -p 6222 hpcadmin@localhost
```

### Slurm

ssh into the frontend and run a job:

```
$ ssh -p 6222 cgray@127.0.0.1

[cgray@frontend ~]$ sinfo
PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
normal*      up 5-00:00:00      2   idle c[1-2]

[cgray@frontend ~]$ srun -N1 hostname
c1

[cgray@frontend ~]$ sbatch --wrap="uptime"
Submitted batch job 3

[cgray@frontend ~]$ ls
slurm-3.out

[cgray@frontend ~]$ cat slurm-3.out
 04:11:15 up 12:15,  0 users,  load average: 0.03, 0.29, 0.37

# Test you can ssh into the first compute node from the frontend.
[cgray@frontend ~]$ ssh c1

[cgray@c1 ~]$ ls
slurm-3.out
```

## Docker Tips

Some things you might find useful while using this setup:

### Finding IP address of container

```
$ docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' coldfront
172.27.0.10
```

### Shutting down

To stop the containers:
```
$ ./hpcts stop
or
$ docker-compose stop
```

To tear down all containers and remove volumes:

```
$ ./hpcts clean
```

This will run these commands:
```
$ docker-compose stop
$ docker-compose rm -f
$ docker-compose down -v
```

### Starting everything up again

```
$ ./hpcts start
or 
$ docker-compose up -d
```


## Acknowledgments

The multi-container Slurm cluster using docker-compose is loosely based on the
following:

- https://github.com/giovtorres/slurm-docker-cluster
- https://github.com/OSC/ood-images/tree/master/docker-with-slurm

## License

This tutorial is released under the GPLv3 license. See the LICENSE file.
