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

[Back to Start](../README.md)
