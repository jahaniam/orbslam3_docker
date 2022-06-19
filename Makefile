## Makefile for richtong/lib
##

# Release tag
TAG ?= 0.9

# using github container registery
ORG ?= ghcr.io/netdrones
IMAGE ?= orbslam3
DOCKERFILE ?= Dockerfile_rich
BUILD_CONTAINER ?= build_container_rich

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

## container: starts cpu build container to create artifacts in host
.PHONY: container
container:
	ORG="$(ORG)" IMAGE="$(IMAGE)" "./$(BUILD_CONTAINER)_cpu.sh"


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
