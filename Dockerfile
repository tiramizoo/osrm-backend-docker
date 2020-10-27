# OSRM processing tools, server and profile

FROM debian:stretch

# This can be a gitsha, tag, or branch - anything that works with `git checkout`
ARG OSRM_VERSION

# This is passed to cmake for osrm-backend.  All other dependencies are built in
# release mode.
ARG BUILD_TYPE=Release

RUN apt update \
  && DEBIAN_FRONTEND=noninteractive apt install -y \
  git g++ cmake libboost-dev libboost-filesystem-dev libboost-thread-dev \
  libboost-system-dev libboost-regex-dev libxml2-dev libsparsehash-dev libbz2-dev \
  zlib1g-dev libzip-dev libgomp1 liblua5.3-dev \
  pkg-config libgdal-dev libboost-program-options-dev libboost-iostreams-dev \
  libboost-test-dev libtbb-dev libexpat1-dev

RUN NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) && \
  echo "Building OSRM ${OSRM_VERSION}" && \
  git clone https://github.com/tiramizoo/osrm-backend.git && \
  cd osrm-backend && \
  mkdir build && \
  cd build && \
  cmake -DCMAKE_BUILD_TYPE=${BUILD_TYPE} -DENABLE_LTO=On .. && \
  make -j${NPROC} install

EXPOSE 5000
