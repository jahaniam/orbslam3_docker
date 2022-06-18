## Makefile for richtong/lib
##

# Release tag
TAG ?= 0.9

# using github container registery
ORG ?= ghcr.io/netdrones
IMAGE ?= orbslam3
DOCKEFILE ?= Dockerfile_cpu

## build: creates the build container
.PHONY: build
build:
	ORG="$(ORG)" IMAGE="$(IMAGE)" DOCKERFILE="$(DOCKERFILE)" ./build_image.sh

## container: starts build container to create artifacts in host
.PHONY: container
container:
	ORG="$(ORG)" IMAGE="$(IMAGE)" ./build_container_cpu_rich.sh

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
