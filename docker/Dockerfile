FROM debian:buster

# we need to add the raspberrypi GPG key which uses
# "apt-key adv" and this in return requires gnupg
RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y gnupg
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 82B129927FA3303E
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 9165938D90FDDD2E

# switch to raspbian repository (since we need the raspberry pi specific packages)
# (original is kept if is needed at some point
COPY raspi.list /etc/apt/sources.list.d/raspi.list
RUN mv /etc/apt/sources.list /etc/apt/sources.list.orig
COPY sources.list /etc/apt/sources.list

RUN apt update && DEBIAN_FRONTEND=noninteractive apt upgrade -y
RUN DEBIAN_FRONTEND=noninteractive \
                apt install -y build-essential \
                               cmake mc ninja-build \
                               sudo git vim \
                               autoconf libtool-bin

# clean up
RUN apt autoremove -y

# https://superuser.com/questions/715722/how-to-do-dpkg-reconfigure-dash-as-bash-automatically/1064247
# make /bin/sh symlink to bash instead of dash:
RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive \
    dpkg-reconfigure dash


# GStreamer stuff
RUN DEBIAN_FRONTEND=noninteractive \
                apt install -y libgstreamer1.0-dev

# Neutrino specific dependencies

# Nothing to install for libdvbsi++.
# libstb-hal needs:
RUN apt install -y \
     libclutter-gtk-1.0-dev \
     libswscale-dev \
     libopenthreads-dev \
     libao-dev \
     libavformat-dev \
     libraspberrypi-dev

# (both libopenthreads-dev and libao-dev are missing from the configure checks)
# i.e. it will try to compile even though they are not present on the system
# libraspberrypi-dev is of course specific for the raspberry Pi. There are some checks
# in configure.ac but they simply seem to assume a fallback directory.

# and the build dependencies for Neutrino
# some are repeated here (for example libavformat-dev) but this way we know what we need
# (and apt will simply notice that the dependencies have already been installed)

RUN apt install -y \
    libid3tag0-dev \
    libmad0-dev \
    libogg-dev \
    libswresample-dev \
    libcurl4-gnutls-dev \
    libavformat-dev \
    libsigc++-2.0-dev \
    liblua5.2-dev \
    libfreetype6-dev \
    libgif-dev \
    libjpeg62-turbo-dev \
    libvorbis-dev \
    libflac-dev \
    libopenthreads-dev \
    libclutter-gtk-1.0-dev \
    libswscale-dev \
    libao-dev

# (careful, it needs to be lua 5.2, e.g. lua50 is not recent enough and lua 5.3 is not detected properly by the configure script)
# not all of these dependencies are detected by the configure script if they are missing (think everything below libgif-dev)

# as a final step create a default user (will get uid 1000) in case we want to work inside the container
RUN useradd docker && echo "docker:docker" | chpasswd
RUN mkdir -p /home/docker && chown -R docker:docker /home/docker
WORKDIR /home/docker

# add docker user to sudoers
RUN usermod -a -G sudo docker

USER docker
# get rid of the "To run a command as administrator (user "root"), use "sudo <command>". [...]" message at startup
RUN touch /home/docker/.sudo_as_admin_successful
