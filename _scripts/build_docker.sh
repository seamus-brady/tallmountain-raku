#!/bin/sh
set -e

# ********************************
# go to project root
# ********************************
cd "${0%/*}"
cd ..

pwd

# ********************************
# get env vars from .env file
# ********************************
echo "Get env vars from .env file..."
export $(grep -v '^#' .env | xargs)
echo $OPENAI_API_KEY

# ********************************
# build image
# ********************************
echo "Building docker image..."
docker build --no-cache --build-arg OPENAI_API_KEY_ARG=$OPENAI_API_KEY -t tallmountain .
