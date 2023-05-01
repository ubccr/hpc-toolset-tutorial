## Requirements

For this tutorial you will need to have **20GB of free disk space** and git, docker, docker-compose and a web browser installed on your local machine.  This tutorial has been tested on various versions of Linux, MacOS, and Windows 10/11 (using Windows subsystem for Linux) with the following package versions:

- git 2.17+ 
- docker engine version 20.10.12+
- docker compose 2.6.0+ (this is distributed with newer versions of docker and not necessary to install separately)  

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

**NOTE: Make sure the account you're running docker with is in the 'docker' group**

**Windows users:** We do NOT recommend using Docker Desktop with this container environment.  Instead, use Windows subsystem for Linux (WSL) and install Docker within an Ubuntu virtual machine.  [This site](https://nickjanetakis.com/blog/install-docker-in-wsl-2-without-docker-desktop) provides useful information on this method, except docker-compose no longer needs to be installed separately.  Using WSL allows you to follow the docker installation instructions for Linux and this is what is tested by the HPC Toolset Tutorial team.  

### Verify working Docker

```
docker info
```

**This should display your system info along with Docker-specific info.  If there are any errors, stop/start Docker.  Do NOT proceed with the tutorial until you are sure you have a working Docker setup**


## Docker Tips

Some useful info on installing Docker, navigating this tutorial and learning a bit about docker-compose

[Docker Tips](docker_tips.md)  
[Docker Compose Tutorial](https://youtu.be/DX1T-PKHKhg) *Unaffiliated with us but a very good overview of Docker Compose*


## Tutorial Navigation

[Next - Getting Started](getting_started.md)  
[Back to Start](../README.md)
