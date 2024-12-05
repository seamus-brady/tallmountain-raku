#!/bin/sh
set -e

# ********************************
# go to project root
# ********************************
cd "${0%/*}"
cd ..

echo "Running docker image..."

docker run --rm --name tallmountain --env-file .env -p 10000:10000 tallmountain:latest
