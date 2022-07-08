## Requirements

For this tutorial you will need to have **20GB of free disk space** and git, docker, docker-compose and a web browser installed on your local machine.  This tutorial has been tested on various versions of Linux, MacOS, and Windows 10 with the following package versions:

- git 2.17+ (Windows users we recommend:  https://gitforwindows.org/)
- docker engine version 20.10.12+
- docker-compose 2.6.0+

NOTE: For Windows, if you haven't already done so, you will need to configure git not to convert line endings into Windows format.  Run this command using the git-bash shell application before cloning the tutorial repo:

```
git config --global core.autocrlf input
```

The following ports must be open and available:

- 2443
- 3443
- 4443
- 5554
- 6222

If they are not you might see an error like:
`Cannot start service X: Ports are not available`

### Install & Start Docker

https://docs.docker.com/engine/install/

**NOTE: You'll need to make sure the account you're running docker with is in the 'docker' group**

### Install Docker Compose  

https://docs.docker.com/compose/install/

### Verify working Docker

```
docker info
```

**This should display your system info along with Docker-specific info.  If there are any errors, stop/start Docker.  Do NOT proceed with the tutorial until you are sure you have a working Docker setup**


### Error when running 'docker info' or when starting up tutorial containers

If you get this error when starting the tutorial   

```
ERROR: Couldn't connect to Docker daemon at http+docker://localunixsocket - is it running?

or  

ERROR: Couldn't connect to Docker daemon at http+docker://localhost - is it running?
```

Try stopping and starting Docker (restart doesn't usually fix the problem).  Commands for this differ depending on operating system.

If the error persists, try:  

```
export DOCKER_HOST=127.0.0.1
```

NOTE: this is only necessary on some systems so don't use it if the previous command works

## Docker Tips

Some useful info on installing Docker, navigating this tutorial and learning a bit about docker-compose

[Docker Tips](docker_tips.md)  
[Docker Compose Tutorial](https://youtu.be/DX1T-PKHKhg) *Unaffiliated with us but a very good overview of Docker Compose*


## Tutorial Navigation

[Next - Getting Started](getting_started.md)  
[Back to Start](../README.md)
