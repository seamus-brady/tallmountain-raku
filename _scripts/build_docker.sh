#!/bin/sh
set -e

# ********************************
# go to project root
# ********************************
cd "${0%/*}"
cd ..

echo "Building docker image..."

docker build -t tallmountain .
