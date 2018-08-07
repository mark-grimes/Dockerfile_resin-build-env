FROM ubuntu:16.04

# Install the following utilities (required by poky)
RUN apt-get update && apt-get install -y build-essential chrpath curl diffstat gcc-multilib gawk git-core locales \
                                         texinfo unzip wget xterm cpio file python python3 openssh-client iputils-ping iproute2 \
                                         && rm -rf /var/lib/apt/lists/*

# Set the locale to UTF-8 for bulding with poky morty
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8

# Additional host packages required by resin
RUN apt-get update && apt-get install -y apt-transport-https && rm -rf /var/lib/apt/lists/*
RUN curl --silent https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
ARG NODE_VERSION=node_8.x
ARG DISTRO=xenial
RUN echo "deb https://deb.nodesource.com/$NODE_VERSION $DISTRO main" | tee /etc/apt/sources.list.d/nodesource.list &&\
  echo "deb-src https://deb.nodesource.com/$NODE_VERSION $DISTRO main" | tee -a /etc/apt/sources.list.d/nodesource.list
RUN apt-get update && apt-get install -y jq nodejs sudo && rm -rf /var/lib/apt/lists/*

# Install docker
# https://github.com/docker/docker/blob/master/project/PACKAGERS.md#runtime-dependencies
RUN apt-get update && apt-get install -y iptables procps e2fsprogs xfsprogs xz-utils git kmod && rm -rf /var/lib/apt/lists/*
ARG DOCKER_VERSION=1.10.1
ARG DOCKER_SHA256=de4057057acd259ec38b5244a40d806993e2ca219e9869ace133fad0e09cedf2
VOLUME /var/lib/docker
RUN wget -q -O /usr/bin/docker https://get.docker.com/builds/Linux/x86_64/docker-${DOCKER_VERSION} && chmod +x /usr/bin/docker \
    && echo "${DOCKER_SHA256}" /usr/bin/docker | sha256sum -c -

COPY prepare-and-start.sh /

RUN groupadd -g 1000 builder \
    && groupadd docker \
    && useradd -m -u 1000 -g 1000 -G docker builder

# on start, need to run "docker daemon 2> /dev/null &"
# then barys command sudo'd to the builder user, e.g.
#    sudo -H -u builder ./resin-yocto-scripts/build/barys -r --shared-downloads $(pwd)/shared-downloads/ --shared-sstate $(pwd)/shared-sstate/ -m raspberrypi3

WORKDIR /yocto/resin-board
