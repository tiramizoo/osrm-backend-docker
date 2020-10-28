# Based on https://github.com/Project-OSRM/osrm-backend/blob/master/docker/Dockerfile
FROM debian:stretch-slim as builder
ARG DOCKER_TAG
# This is passed to cmake for osrm-backend.  All other dependencies are built in
# release mode.
ARG BUILD_TYPE=Release

RUN mkdir -p /src && mkdir -p /opt
COPY . /src
WORKDIR /src

RUN apt-get update && \
    apt-get -y --no-install-recommends install cmake make git gcc g++ libbz2-dev libxml2-dev ca-certificates \
    libzip-dev libboost1.62-all-dev lua5.2 liblua5.2-dev libtbb-dev -o APT::Install-Suggests=0 -o APT::Install-Recommends=0

RUN NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) && \
    echo "Building OSRM ${DOCKER_TAG}" && \
    git clone https://github.com/tiramizoo/osrm-backend.git && \
    cd osrm-backend && \
    mkdir -p build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=${BUILD_TYPE} -DENABLE_LTO=On .. && \
    make -j${NPROC} install && \
    cd ../profiles && \
    cp -r * /opt && \
    strip /usr/local/bin/* && \
    rm -rf /src /usr/local/lib/libosrm*

# Multistage build to reduce image size - https://docs.docker.com/engine/userguide/eng-image/multistage-build/#use-multi-stage-builds
# Only the content below ends up in the image, this helps remove /src from the image (which is large)
FROM debian:stretch-slim as runstage
RUN mkdir -p /src  && mkdir -p /opt
RUN apt-get update && \
    apt-get install -y --no-install-recommends libboost-program-options1.62.0 libboost-regex1.62.0 \
        libboost-date-time1.62.0 libboost-chrono1.62.0 libboost-filesystem1.62.0 \
        libboost-iostreams1.62.0 libboost-thread1.62.0 expat liblua5.2-0 libtbb2 &&\
    rm -rf /var/lib/apt/lists/*
COPY --from=builder /usr/local /usr/local
COPY --from=builder /opt /opt
RUN /usr/local/bin/osrm-extract --help && \
    /usr/local/bin/osrm-routed --help && \
    /usr/local/bin/osrm-contract --help && \
    /usr/local/bin/osrm-partition --help && \
    /usr/local/bin/osrm-customize --help
WORKDIR /opt

EXPOSE 5000
