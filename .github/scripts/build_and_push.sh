#!/bin/bash

set -e

VERSION=$1
IMAGE_NAME=sajadtaj/helloworld

echo "🛠 Building Docker image with tag: $VERSION"

docker build -t $IMAGE_NAME:$VERSION .

echo "🚀 Pushing Docker image to DockerHub..."
docker login -u "${DOCKERHUB_USERNAME}" -p "${DOCKERHUB_TOKEN}"
docker push $IMAGE_NAME:$VERSION
