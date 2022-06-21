## Makefile for ORB-SLAM3 docker build
## -----------------------------------

# Release tag
TAG ?= 0.9

# using github container registery
ORG ?= ghcr.io/netdrones
IMAGE ?= orbslam3
DOCKERFILE ?= Dockerfile

BUILD_CONTAINER ?= build_container

## all: download data, build container, run image and build artifacts
all: download build container exec

## download: Download of the dataset
# only if MH01.zip is not present and MH01 not unzipped
.PHONY: download
download: Datasets/EuRoC/MH01

Datasets/EuRoC/MH01: Datasets/EuRoC/MH01.zip
	./download_dataset_sample.sh

## build: creates the build container for cpu
.PHONY: build
build:
	ORG="$(ORG)" IMAGE="$(IMAGE)" DOCKERFILE="$(DOCKERFILE)" ./build_image.sh -t cpu

## build_cuda: creates the build container for nVidis GPU cuda
.PHONY: build_cuda
build_cuda:
	ORG="$(ORG)" IMAGE="$(IMAGE)" DOCKERFILE="$(DOCKERFILE)" ./build_image.sh -t cuda

## container: pull latest image, remove current running container, start a new one and build artifacts
.PHONY: container
container: pull remove start compile

## compile: compile ORB-SLAM3 with build image into host file system
.PHONY: compile
compile:
	COMPILE=true ORG="$(ORG)" IMAGE="$(IMAGE)" "./$(BUILD_CONTAINER)_cpu.sh"

## start: stop any running container, start a new one
.PHONY: start
start:
	START=true ORG="$(ORG)" IMAGE="$(IMAGE)" "./$(BUILD_CONTAINER)_cpu.sh"

## remove: remove container and artifacts
.PHONY: remove
remove:
	REMOVE=true ORG="$(ORG)" IMAGE="$(IMAGE)" "./$(BUILD_CONTAINER)_cpu.sh"

## pull: pull image
.PHONY: pull
pull:
	PULL=true ORG="$(ORG)" IMAGE="$(IMAGE)" "./$(BUILD_CONTAINER)_cpu.sh"


## container_cuda: starts cuda build container to create artifacts in host
.PHONY: container_cuda
container_cuda:
	ORG="$(ORG)" IMAGE="$(IMAGE)" "./$(BUILD_CONTAINER)_cuda.sh"

## exec: enter the running cpu build container and run ROS
.PHONY: exec
exec:
	docker exec -it "$(IMAGE)" bash

## test: test the library
.PHONY: test
test:
	@echo "insert test code here..."

## clean: remove the build directory
.PHONY: clean
clean:
	@echo "insert clear code here..."

## all: build all
.PHONY: all

include ./lib/include.mk
