include .env
CONTAINER_ORGANIZATION := connectical
CONTAINER_IMAGE := supysonic
CONTAINER_ARCHITECTURES := linux/amd64,linux/arm64,linux/arm/v7
CONTAINER_TAG ?= base

all: build

build:
	docker build -t $(CONTAINER_ORGANIZATION)/$(CONTAINER_IMAGE):$(CONTAINER_TAG) --build-arg ALPINE_VERSION=$(ALPINE_VERSION) --build-arg PYTHON_VERSION=$(PYTHON_VERSION) --build-arg SUPYSONIC_VERSION=$(SUPYSONIC_VERSION) --build-arg CONTAINER_TAG=$(CONTAINER_TAG) --build-arg EXTRA_PACKAGES="$(shell cat tags/$(CONTAINER_TAG)-packages)" .

build-multiarch:
	docker buildx build -t $(CONTAINER_ORGANIZATION)/$(CONTAINER_IMAGE):$(CONTAINER_TAG) --platform $(CONTAINER_ARCHITECTURES) --build-arg ALPINE_VERSION=$(ALPINE_VERSION) --build-arg PYTHON_VERSION=$(PYTHON_VERSION) --build-arg SUPYSONIC_VERSION=$(SUPYSONIC_VERSION) --build-arg CONTAINER_TAG=$(CONTAINER_TAG) --build-arg EXTRA_PACKAGES="$(shell cat tags/$(CONTAINER_TAG)-packages)" .

.PHONY: all build build-multiarch
# vim:ft=make
