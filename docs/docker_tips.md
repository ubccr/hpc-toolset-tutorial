## Docker Tips

Some things you might find useful while using this setup:

### Install & Start Docker
https://docs.docker.com/engine/install/

**NOTE: You'll need to make sure the account you're running docker with is in the 'docker' group**

### Install Docker Compose  
https://docs.docker.com/compose/install/

### Verify working Docker
`docker info`  
*This should display your system info along with Docker-specific info.  If there are any errors, stop/start Docker*


### Error when starting up tutorial containers

If you get this error when running `docker-compose up -d`  
`ERROR: Couldn't connect to Docker daemon at http+docker://localunixsocket - is it running?`  

Try stopping and starting Docker (restart doesn't usually fix the problem)  
`sudo systemctl stop docker  
sudo systemctl start docker`

If the error persists, try:  
`export DOCKER_HOST=127.0.0.1`  
NOTE: this is only necessary on some systems so don't use it if the previous command works

### Display Docker processes
`docker ps -a`

### Display Docker containers
`docker container list`

### Display Docker images
`docker image list`



### Shutting down the tutorial containers
**NOTE: This is the preferred method to stop/start or tear down the tutorial setup as the containers rely on each other and stopping, starting or deleting them individually usually has unintended side effects**

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

### Deleting Docker images
If you really want to clean up images and start fresh:  
`docker image list`  
`docker image rm XX` (XX=image id)

### Finding IP address of container

```
$ docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' coldfront
172.27.0.10
```
[Back to Start](../README.md)
