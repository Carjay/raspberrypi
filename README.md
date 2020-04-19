# raspberrypi
Things related to the raspberrypi

The ```docker``` directory contains a Dockerfile suitable for developing on the Pi. The image is located on dockerhub and can be pulled from carjay/raspberrypi:busterdev.

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

## Neutrino directory

The ```neutrino``` directory contains two scripts that should make it easy to build Neutrino for the Raspberry Pi. They are meant to be used on the current Raspbian Buster installation (since this is what the current Docker images use as well).

### prepare_and_build.sh

If run without arguments this script first clones all necessary repositories and then builds Neutrino and its dependencies.

All installed build output can be found in a directory called ```buildoutput``` (the "prefix" dir in autoconf terms).
Build artifacts will be put in the source directories.

The script has a lot of command line parameters that can be listed with ```./prepare_and_build.sh --help```.

Most importantly you can select to run only part of the full build process. For example to trigger only the Neutrino build, run ```./prepare_and_build.sh -t neutrino-build```

### run_dependency_check.py

A little helper script that tries to identify missing packages on the Raspberry Pi host which would keep neutrino from running.

If packages are missing then it will offer to install them using ```apt```. Afterwards you can simply run neutrino and it should just work.
