#!/bin/bash
set -e
set -x

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
# echo $OPENAI_API_KEY

# ********************************
# build image
# ********************************
echo "Building docker image..."
start=$(date +%s)
# actual build
docker build --build-arg OPENAI_API_KEY_ARG="$OPENAI_API_KEY" -t tallmountain .
end=$(date +%s)
duration=$((end - start))
minutes=$((duration / 60))
seconds=$((duration % 60))
echo "Build completed"
echo "Time taken: $minutes minutes and $seconds seconds"
