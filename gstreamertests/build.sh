#!/bin/bash

echo "INFO: setting up and building test in container"

docker pull carjay/raspberrypi:busterdev-neutrino
docker run -it --rm -v ${PWD}:/home/docker/sources carjay/raspberrypi:busterdev-neutrino bash -c \
        'cd /home/docker/sources && cmake -G "Unix Makefiles" -B build . && \
         cd build && make && \
         cd .. && ln -sf build/helloworld-gstreamer'

echo "INFO:"
echo "Finished building and symlinking helloworld-gstreamer into the current directory."
echo "Run './helloworld-gstreamer' to play back a default network stream."
echo "To play back a local file instead, use './helloworld-gstreamer file://${PWD}/<localfilename>'"
