#!/bin/sh
set -e

# ********************************
# go to project root
# ********************************
cd "${0%/*}"
cd ..

echo "Running docker image..."

docker run --rm tallmountain
