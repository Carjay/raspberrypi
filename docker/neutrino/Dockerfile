FROM carjay/raspberrypi:busterdev-base

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

USER docker
