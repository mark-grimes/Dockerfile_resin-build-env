# resin-build-env

An image to build [Resin OS](https://resinos.io) images. Mostly taken from [resin-os/resin-yocto-scripts:automation/Dockerfile_yocto-build-env](https://github.com/resin-os/resin-yocto-scripts/blob/master/automation/Dockerfile_yocto-build-env)
but with some minor changes of my own.

To use the container I do:

    docker run --rm -it -v yocto:/work -v yocto-shared:/yocto-shared --privileged markgrimes/resin-build-env

This sets up two docker volumes, one for the build (`yocto`) and a separate one (`yocto-shared`) to store the product of each 
step (the "sstate"). Reusing the sstate will considerably speed up subsequent builds.  Once in the container, start a build with:

    docker daemon 2> /dev/null &
    chown -R builder:builder /work/ /yocto-shared/
    su builder
    cd /work
    git clone --recursive https://github.com/resin-os/resin-raspberrypi.git
    cd resin-raspberrypi
    ./resin-yocto-scripts/build/barys --shared-downloads /yocto-shared/shared-downloads/ --shared-sstate /yocto-shared/shared-sstate/ -m raspberrypi

