FROM debian:buster

# we need to add the raspberrypi GPG key which uses
# "apt-key adv" and this in return requires gnupg
RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y gnupg
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 82B129927FA3303E
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 9165938D90FDDD2E

# switch to raspbian repository (since we need the raspberry pi specific packages)
# (original is kept if is needed at some point)
COPY raspi.list /etc/apt/sources.list.d/raspi.list
RUN mv /etc/apt/sources.list /etc/apt/sources.list.orig
COPY sources.list /etc/apt/sources.list

RUN apt update && DEBIAN_FRONTEND=noninteractive apt upgrade -y
RUN DEBIAN_FRONTEND=noninteractive \
                apt install -y build-essential \
                               cmake mc ninja-build \
                               sudo git vim \
                               autoconf libtool-bin

# clean up (for some reason debian-keyring is no longer necessary afterwards)
RUN apt autoremove -y

# https://superuser.com/questions/715722/how-to-do-dpkg-reconfigure-dash-as-bash-automatically/1064247
# make /bin/sh symlink to bash instead of dash:
RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive \
    dpkg-reconfigure dash

# as a final step create a default user (will get uid 1000) in case we want to work inside the container
RUN useradd docker && echo "docker:docker" | chpasswd
RUN mkdir -p /home/docker && chown -R docker:docker /home/docker
WORKDIR /home/docker

# add docker user to sudoers
RUN usermod -a -G sudo docker

# get rid of the "To run a command as administrator (user "root"), use "sudo <command>". [...]" message at startup
RUN touch /home/docker/.sudo_as_admin_successful
