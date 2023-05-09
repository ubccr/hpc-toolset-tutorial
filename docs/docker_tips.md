## Docker Tips

This section includes some useful tips on running the HPC Toolset Tutorial.

### Starting/Stopping the HPC Toolset Tutorial

If you have not already done so, clone this repo:

```
$ git clone https://github.com/ubccr/hpc-toolset-tutorial.git
$ cd hpc-toolset-tutorial
```

If you have previously cloned the repo, pull all the latest changes. This is very important as lots
has changed from previous years:

```
$ git pull
```

This step is optional: only run this if you've previously run our tutorial and
need to remove any old containers, volumes, and images. You can also run this
if you need to start completely fresh. NOTE: this will delete all the hpcts
container images and you will need to re-download them:

```
$ ./hpcts cleanup
```

Pull down and start the most recent container images:

```
$ ./hpcts start
```

### If something goes wrong...

First thing to try is stopping the containers, removing the volumes and re-starting:

```
$ ./hpcts destroy
$ ./hpcts start
```

### Docker Documentation

- [Docker](https://docs.docker.com)
- [Install & Start Docker](https://docs.docker.com/engine/install/)
- [Linux & Windows Subsystem for Linux](https://docs.docker.com/engine/install/linux-postinstall/) 
- [MacOS Docker Desktop](https://docs.docker.com/docker-for-mac/troubleshoot/)  

### Helpful Docker commands

```
# Start all HPC Toolset Containers manually
$ docker compose up -d

# Display Tutorial Container Logs
$ docker compose logs -f
$ docker compose logs -f coldfront
$ docker compose logs -f xdmod
$ docker compose logs -f ondemand

# Stop containers 
$ docker compose stop

# Stop containers and remove them
$ docker compose down

# Stop containers,remove them and all volumes
$ docker compose down -v

# Display Docker processes
$ docker ps -a

# Display Docker containers
$ docker container list

# Display Docker images
$ docker image list

# Display Docker volumes
$ docker volume list

# Finding IP address of container
$ docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' coldfront
172.27.0.10
```

### Troubleshooting

General troubleshooting tips to try:

#### Error when starting up tutorial containers

If you get this error when starting the tutorial:

```
ERROR: Couldn't connect to Docker daemon at http+docker://localhost - is it running?
```

Try stopping and starting Docker (restart doesn't usually fix the problem).
Commands for this differ depending on operating system.

If the error persists, try:

```
export DOCKER_HOST=127.0.0.1
```

NOTE: this is only necessary on some systems so don't use it if the previous command works

**Sometimes restarting your operating system is the only solution.**


#### Deleting Docker containers/images/volumes manually

If you want to manually clean up images:  

```
$ docker image list
$ docker image rm XX (XX=image id)
$ docker container list
$ docker container rm XX (XX=container id)
$ docker volume list
$ docker volume rm XX (XX=volume id)
```

If you're getting an error about volumes in use but there is nothing running,
stop docker, manually delete the files, and start docker again.  These commands
are different depending on the operating system so we recommend using your
favorite search provider to locate instructions for this.

[Back to Start](../README.md)
