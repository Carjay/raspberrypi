FROM debian:buster

RUN apt update && DEBIAN_FRONTEND=noninteractive apt upgrade -y
RUN DEBIAN_FRONTEND=noninteractive \
                apt install -y build-essential \
                               cmake mc strace gdb \
                               libgstreamer1.0-dev \
                               ninja-build sudo

# create a default user (will get uid 1000)
RUN useradd docker && echo "docker:docker" | chpasswd
RUN mkdir -p /home/docker && chown -R docker:docker /home/docker
WORKDIR /home/docker

# add docker user to sudoers
RUN usermod -a -G sudo docker

USER docker
# get rid of the "To run a command as administrator (user "root"), use "sudo <command>". [...]" message at startup
RUN touch /home/docker/.sudo_as_admin_successful
