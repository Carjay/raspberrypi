# raspberrypi
Things related to the raspberrypi

The docker directory contains a Dockerfile suitable for developing on the Pi.

## Install docker on the Pi
To install docker simply run

```
$ apt install docker.io
```

To be able to run docker as a regular user you need to add the "docker" group to this users list of groups.

```
$ sudo usermod -a -G docker <YOUR USERNAME>
```

You now either need to logout and login for the change to become effective or simply use

```
$ newgrp docker
```

to add the new user group to the existing shell.


Now try

```
$ docker run hello-world
```

and see if everything works.
