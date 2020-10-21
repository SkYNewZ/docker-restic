#!/usr/bin/env bash

set -x

echo "Building skynewz/restic:latest"
docker buildx build \
--tag skynewz/restic:latest \
--push \
--platform darwin/amd64,linux/amd64,linux/arm/v7,linux/arm/v6,linux/arm64 \
--build-arg RESTIC_VERSION=${RESTIC_VERSION} \
--build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
.

echo "Building skynewz/restic:${RESTIC_VERSION}"
docker buildx build \
--tag skynewz/restic:${RESTIC_VERSION} \
--push \
--platform darwin/amd64,linux/amd64,linux/arm/v7,linux/arm/v6,linux/arm64 \
--build-arg RESTIC_VERSION=$RESTIC_VERSION \
--build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
.