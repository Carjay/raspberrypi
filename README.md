# raspberrypi
Things related to the raspberrypi

The ```docker``` directory contains a Dockerfile suitable for developing on the Pi. The image is located on dockerhub and can be pulled from carjay/raspberry:busterdev.

## Install docker on the Pi
The first step is to install docker on the Pi. This is actually quite simple, just use apt:

```
$ sudo apt install docker.io
```

To be able to run the docker command as a regular user you need to add the "docker" group to this users list of groups.

```
$ sudo usermod -a -G docker <YOUR USERNAME>
```

You now either need to logout and login again for the change to become effective or simply use

```
$ newgrp docker
```

to add the new user group to the existing shell.


Now everything is setup correctly and you can try

```
$ docker run hello-world
```

to see if everything works (it should pull a test image from dockerhub and print some messages).

## Example directory

The ```gstreamertests``` directory contains an example showing how the development image can be used. Simply run
```
$ ./build.sh
```

which will pull the image and build the demo tool.
