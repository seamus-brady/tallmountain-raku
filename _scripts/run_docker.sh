#!/bin/bash
set -e
# set -x

# ********************************
# go to project root
# ********************************
cd "${0%/*}"
cd ..

echo "Running docker image..."

docker run --rm --env-file .env -p 10000:10000 tallmountain:latest run-app
