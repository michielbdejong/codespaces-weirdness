#!/bin/bash
set -e

echo building base image
cd servers/owncloud
docker build -t owncloud .

echo building oc1
cd ../oc1
docker build --no-cache -t oc1 .

echo building oc2
cd ../oc2
docker build --no-cache -t oc2 .

echo Did the oc2 image get built with the correct env var for HOST?
docker run -it oc2 env | grep HOST=
