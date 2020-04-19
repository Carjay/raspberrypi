#!/bin/bash

set -e # stop on error

DOCKERIMAGE=carjay/raspberrypi:busterdev-neutrino
DOCKERWORKDIR=${PWD} # path inside the container, must be the same path as the external one,
                     # else the binaries will not run out of the prefix
                     # because they would have the wrong absolute path embedded
GITHUB_PREFIX=https://github.com/
DEVELOPERMODE=0
PARTIAL=""
# this is where all compile artifacts will go to
PREFIXDIR="${DOCKERWORKDIR}/buildoutput"
BUILDCORES=0
SKIP_PULL=0 # if not 0 skips the pull check at the beginning

if [ $# -gt 0 ]; then
    while [ ! -z "$1" ]; do
        case "$1" in
            -d | --developermode)
                DEVELOPERMODE=1
                shift
                ;;
            -p | --prefixdirectory)
                # just try to catch the most obvious, paths starting with "/" and ".."
                if [[ "$2" =~ ^(/|\.\.) ]]; then
                    echo "ERROR: --prefixdirectory must be inside of \"${PWD}\""
                    exit  1
                else
                    PREFIXDIR=${DOCKERWORKDIR}/$2
                fi
                shift 2
                ;;
            -c | --cores)
                BUILDCORES=$2
                shift 2
                ;;
            -t | --target)
                PARTIAL=$2
                shift 2
                ;;
            --no-pull)
                SKIP_PULL=1
                shift
                ;;
            -h | --help | *)
                EXITSTATUS=0
                if [ "$1" != "-h" ] && [ "$1" != "--help" ]; then
                    echo "ERROR: Unknown option '$1'"
                    echo
                    EXITSTATUS=1
                fi
                echo "Usage: $0 [<options>]"
                echo "       Default is to prepare and build everything"
                echo "       Options:"
                echo "       -h, --help: print this help"
                echo "       -d, --developermode: clone repositories in developer mode"
                echo "           (i.e. check out with SSH instead of HTTPS)"
                echo "       -p, --prefixdirectory: directory inside of \"${PWD}\" where the build"
                echo "                     output should go, defaults to \"buildoutput\""
                echo "                     The directory will be created if it does not exist yet."
                echo "                     Note that this can NOT be used to set a relative or absolute path"
                echo "                     since the docker container is limited to the current working directory."
                echo "       -c, --cores: set the number of processor cores to use, default is to calculate the number automatically"
                echo "       -t, --target: only execute a single target of the script, use one of:"
                echo "       --no-pull: skip pulling the image from the registry (speeds things up a bit but image must be present locally)."
                echo "           clone:                clone all repositories"
                echo
                echo "           dvbsi-configure:      configure dvbsi"
                echo "           libstb-hal-configure: configure libstb-hal"
                echo "           neutrino-configure:   configure neutrino"
                echo
                echo "           dvbsi-build:          build (and install) dvbsi"
                echo "           libstb-hal-build:     build (and install) libstb-hal"
                echo "           neutrino-build:       build (and install) neutrino"
                echo

                exit ${EXITSTATUS}
                ;;
        esac
    done
fi

function dockerexec() {
    # first argument is the directory where to execute docker
    # second argument is the command to execute
    local DOCKERSETUP="docker run -it --rm --workdir ${DOCKERWORKDIR} --user $(id -u):$(id -g) -v $1:${DOCKERWORKDIR} ${DOCKERIMAGE} bash -c"

    # use an array to keep bash from splitting up the second argument (which needs to be a single argument for "bash -c")
    CMD=( $DOCKERSETUP "$2" )
    echo ${CMD[@]}
    "${CMD[@]}"
}

STARTTIME=$(date +%s)

if [ ${SKIP_PULL} -ne 1 ]; then
    # make sure we have the latest image
    echo "Checking if local docker image is up-to-date"
    docker pull carjay/raspberrypi:busterdev-neutrino
    echo
fi

if [ "${DEVELOPERMODE}" -ne 0 ]; then
    echo "Developer mod e, using SSH instead of HTTPS"
    GITHUB_PREFIX=git@github.com:
fi

if [ ! -z "${PARTIAL}" ]; then
    echo "As requested, only running target ${PARTIAL}"
    echo
fi

if [ -z "${PARTIAL}" ] || [ "${PARTIAL}" == "clone" ]; then
    echo "Cloning needed repositories if necessary."
    if [ ! -e library-dvbsi ]; then
        echo "    Checking out library-dvbsi"
        git clone ${GITHUB_PREFIX}tuxbox-neutrino/library-dvbsi.git
    else
        echo "    library-dvbsi directory exists, skipping"
    fi

    if [ ! -e libstb-hal ]; then
        echo "    Checking out libstb-hal"
        git clone ${GITHUB_PREFIX}Carjay/libstb-hal.git
    else
        echo "    libstb-hal directory exists, skipping"
    fi

    if [ ! -e neutrino-mp ]; then
        echo "    Checking out neutrino-mp"
        git clone ${GITHUB_PREFIX}Carjay/neutrino-mp.git
    else
        echo "    neutrino-mp directory exists, skipping"
    fi
fi


if [ -z "${PARTIAL}" ] || [[ "${PARTIAL}" =~ .*-build ]]; then
    if [ ${BUILDCORES} -eq 0 ]; then # not set from commandline so do some calculations
        BUILDCORES=`nproc`
        MEGSINSTALLED=$(free -m | awk '/^Mem:/{print $2}')
        if [ ${BUILDCORES} -lt 1 ]; then
            BUILDCORES = 1
        fi
        if [ ${BUILDCORES} -gt 1 ]; then
            # see if we have enough RAM to support that many builds in parallel
            CORES_ESTIMATE=$((${MEGSINSTALLED}/800)) # assume each core could take up to 800 MB
            if [ ${CORES_ESTIMATE} -lt ${BUILDCORES} ]; then
                BUILDCORES=${CORES_ESTIMATE}
            fi
        fi
    fi
    echo "Build will use ${BUILDCORES} cores (system has $(nproc) cores and ${MEGSINSTALLED} MByte of RAM)"
fi

# libdvbsi++
if [ -z "${PARTIAL}" ] || [ "${PARTIAL}" == "dvbsi-configure" ]; then
    echo "Configuring library-dvbsi"
    dockerexec "${PWD}" "cd ${DOCKERWORKDIR}/library-dvbsi && \
                            ./autogen.sh && \
                            ./configure --prefix=${PREFIXDIR}"
fi
if [ -z "${PARTIAL}" ] || [ "${PARTIAL}" == "dvbsi-build" ]; then
    echo "Building libdvbsi++"
    dockerexec "${PWD}" "cd ${DOCKERWORKDIR}/library-dvbsi && \
                            make -j ${BUILDCORES} && \
                            make install"
fi

# libstb-hal
if [ -z "${PARTIAL}" ] || [ "${PARTIAL}" == "libstb-hal-configure" ]; then
    echo "Configuring libstb-hal"
    dockerexec "${PWD}" "cd ${DOCKERWORKDIR}/libstb-hal && \
                            ./autogen.sh && \
                            ./configure --prefix=${PREFIXDIR}"
fi
if [ -z "${PARTIAL}" ] || [ "${PARTIAL}" == "libstb-hal-build" ]; then
    echo "Building libstb-hal"
    dockerexec "${PWD}" "cd ${DOCKERWORKDIR}/libstb-hal && \
                            make -j ${BUILDCORES} && \
                            make install"
fi

# neutrino
if [ -z "${PARTIAL}" ] || [ "${PARTIAL}" == "neutrino-configure" ]; then
    echo "Configuring neutrino"
    dockerexec "${PWD}" "cd ${DOCKERWORKDIR}/neutrino-mp && \
                            ./autogen.sh && \
                            ./configure --prefix=${PREFIXDIR} \
                            --with-boxtype=generic \
                            --with-boxmodel=raspi \
                            --with-stb-hal-includes=${PREFIXDIR}/include/libstb-hal \
                            --enable-giflib \
                            CXXFLAGS=-I${PREFIXDIR}/include \
                            LDFLAGS=-L${PREFIXDIR}/lib \
                            "
fi
if [ -z "${PARTIAL}" ] || [ "${PARTIAL}" == "neutrino-build" ]; then
    echo "Building neutrino"
    dockerexec "${PWD}" "cd ${DOCKERWORKDIR}/neutrino-mp && \
                            make -j ${BUILDCORES} && \
                            make install"
fi

# some stats
FINISHTIME=$(date +%s)
DIFF=$((${FINISHTIME}-${STARTTIME}))
echo
echo "Finished, took ${DIFF}s"

if [ -z "${PARTIAL}" ] || [ "${PARTIAL}" == "neutrino-build" ]; then
    echo
    echo "Neutrino can be found at ${PREFIXDIR}/bin/neutrino"
    echo "You may want to run the run_dependency_check.py script to make sure you have all dependencies installed"
fi
