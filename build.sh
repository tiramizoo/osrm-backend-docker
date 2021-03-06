#!/bin/sh

if [ $# -eq 0 ] ; then
    # Get the current HEAD gitsha, and use the first 8 chars as a short reference to it
    REV=$(git ls-remote https://github.com/tiramizoo/osrm-backend.git HEAD | cut -f 1 | cut -c1-8 )
    PREFIX="master-"
    echo "No tag/gitsha/branch supplied, using master@${REV}"
else
    # Use whatever value the caller supplied
    REV=$1
    PREFIX=""
fi

docker build -t tiramizoo/osrm-backend:${PREFIX}${REV} --build-arg DOCKER_TAG=${REV} --build-arg BUILD_TYPE=Release .
docker build -t tiramizoo/osrm-backend:${PREFIX}${REV}-debug --build-arg DOCKER_TAG=${REV} --build-arg BUILD_TYPE=Debug .
