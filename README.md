# Docker recipes for OSRM

The scripts and dockerfiles here are used to produce OSRM docker images.

The original official scripts https://github.com/Project-OSRM/osrm-backend-docker has been adopted by:
- support debian instead of alpine system
- instead of official osrm-backend the source is from tiramizoo https://github.com/tiramizoo/osrm-backend
(proper osrm-backend version with truck support)

# Usage

```
./build.sh
```

will build the latest `master` code, and tag the image with `osrm/osrm-backend:master-<gitsha>`

```
./build.sh <tag>
```

will build the specified git tag, and tag the docker image as `osrm/osrm-backend:<tag>`

# Get ready docker file
Ready instance has been pushed to https://hub.docker.com/ to repository tiramizoo/osrm-backend 

```
docker pull tiramizoo/osrm-backend:master-114a1df7
```
