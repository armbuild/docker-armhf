#!/bin/bash

set -e

ARM=7
VERSION=1.7.0
OUTPUT_DIR=output
BUILD_DIR="$PWD/docker-$VERSION-arm$ARM-build"
OUTPUT_DIR=$(readlink -f $OUTPUT_DIR)

git clone --branch "v$VERSION" --single-branch https://github.com/docker/docker.git $BUILD_DIR
sed --in-place --regexp-extended "s/FROM[[:space:]]+ubuntu:14.04/FROM armbuild\/ubuntu:14.04/" $BUILD_DIR/Dockerfile

sed --in-place --regexp-extended "s/trusty/vivid/g" $BUILD_DIR/Dockerfile
sed --in-place --regexp-extended "s/14.04/15.04/g" $BUILD_DIR/Dockerfile
sed --in-place --regexp-extended "/s3cmd=1.1.0*/d" $BUILD_DIR/Dockerfile
sed --in-place --regexp-extended "s/ruby1.9.1/ruby2.1/g" $BUILD_DIR/Dockerfile

sed --in-place --regexp-extended "/ENV[[:space:]]+DOCKER_CROSSPLATFORMS/s/^.*$/ENV DOCKER_CROSSPLATFORMS/" $BUILD_DIR/Dockerfile

for ARCH in "linux\/386" "linux\/arm" "darwin\/amd64" "darwin\/386" "freebsd\/amd64" "freebsd\/386" "freebsd\/arm" "WINDOWS\/AMD64"; do
    sed --in-place "/$ARCH/d" $BUILD_DIR/Dockerfile
done

sed --in-place "/ENV DOCKER_CROSSPLATFORMS/s/^.*$/ENV DOCKER_CROSSPLATFORMS linux\/arm/" $BUILD_DIR/Dockerfile

sed --in-place --regexp-extended "s/ENV[[:space:]]+GOARM[[:space:]]+5/ENV GOARM $ARM/" $BUILD_DIR/Dockerfile

sed --in-place "/GOFMT_VERSION/s/^/# /" $BUILD_DIR/Dockerfile

sed --in-place --regexp-extended "/GIT_BRANCH[[:space:]]+:=/s/^.*$/GIT_BRANCH := $VERSION-arm$ARM/" $BUILD_DIR/Makefile

cd $BUILD_DIR
make build
make binary

cp $BUILD_DIR/bundles/$VERSION/binary/docker-$VERSION $OUTPUT_DIR

rm --force --recursive $BUILD_DIR
docker rmi docker:$VERSION-arm$ARM
