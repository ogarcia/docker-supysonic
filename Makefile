ALPINE_VERSION := 3.19.1
PYTHON_VERSION := 3.12.1-alpine3.19
SUPYSONIC_VERSION := 1feaae76377f40a509a5633de71fb35786d0dd5c
CONTAINER_ORGANIZATION := ogarcia
CONTAINER_IMAGE := supysonic
CONTAINER_ARCHITECTURES := linux/amd64,linux/arm/v7,linux/arm64
CONTAINER_TAG ?= base
TAGS := -t $(CONTAINER_ORGANIZATION)/$(CONTAINER_IMAGE):master-$(CONTAINER_TAG)
TAGS += -t quay.io/$(CONTAINER_ORGANIZATION)/$(CONTAINER_IMAGE):master-$(CONTAINER_TAG)
TAGS += -t ghcr.io/$(CONTAINER_ORGANIZATION)/$(CONTAINER_IMAGE):master-$(CONTAINER_TAG)
ifdef CIRCLE_TAG
	TAGS := -t $(CONTAINER_ORGANIZATION)/$(CONTAINER_IMAGE):$(CONTAINER_TAG)
	TAGS += -t quay.io/$(CONTAINER_ORGANIZATION)/$(CONTAINER_IMAGE):$(CONTAINER_TAG)
	TAGS += -t ghcr.io/$(CONTAINER_ORGANIZATION)/$(CONTAINER_IMAGE):$(CONTAINER_TAG)
	TAGS += -t $(CONTAINER_ORGANIZATION)/$(CONTAINER_IMAGE):${CIRCLE_TAG}-$(CONTAINER_TAG)
	TAGS += -t quay.io/$(CONTAINER_ORGANIZATION)/$(CONTAINER_IMAGE):${CIRCLE_TAG}-$(CONTAINER_TAG)
	TAGS += -t ghcr.io/$(CONTAINER_ORGANIZATION)/$(CONTAINER_IMAGE):${CIRCLE_TAG}-$(CONTAINER_TAG)
	ifeq ($(CONTAINER_TAG),base)
		TAGS += -t $(CONTAINER_ORGANIZATION)/$(CONTAINER_IMAGE):latest
		TAGS += -t quay.io/$(CONTAINER_ORGANIZATION)/$(CONTAINER_IMAGE):latest
		TAGS += -t ghcr.io/$(CONTAINER_ORGANIZATION)/$(CONTAINER_IMAGE):latest
	endif
endif

all: docker-build

check-dockerhub-env:
ifndef DOCKERHUB_USERNAME
	$(error DOCKERHUB_USERNAME is undefined)
endif
ifndef DOCKERHUB_PASSWORD
	$(error DOCKERHUB_PASSWORD is undefined)
endif

check-quay-env:
ifndef QUAY_USERNAME
	$(error QUAY_USERNAME is undefined)
endif
ifndef QUAY_PASSWORD
	$(error QUAY_PASSWORD is undefined)
endif

check-github-registry-env:
ifndef GITHUB_REGISTRY_USERNAME
	$(error GITHUB_REGISTRY_USERNAME is undefined)
endif
ifndef GITHUB_REGISTRY_PASSWORD
	$(error GITHUB_REGISTRY_PASSWORD is undefined)
endif

docker-build:
	docker build -t $(CONTAINER_ORGANIZATION)/$(CONTAINER_IMAGE):$(CONTAINER_TAG) --build-arg ALPINE_VERSION=$(ALPINE_VERSION) --build-arg PYTHON_VERSION=$(PYTHON_VERSION) --build-arg SUPYSONIC_VERSION=$(SUPYSONIC_VERSION) --build-arg CONTAINER_TAG=$(CONTAINER_TAG) --build-arg EXTRA_PACKAGES="$(shell cat tags/$(CONTAINER_TAG)-packages)" .

docker-buildx:
	docker buildx build -t $(CONTAINER_ORGANIZATION)/$(CONTAINER_IMAGE):$(CONTAINER_TAG) --platform $(CONTAINER_ARCHITECTURES) --build-arg ALPINE_VERSION=$(ALPINE_VERSION) --build-arg PYTHON_VERSION=$(PYTHON_VERSION) --build-arg SUPYSONIC_VERSION=$(SUPYSONIC_VERSION) --build-arg CONTAINER_TAG=$(CONTAINER_TAG) --build-arg EXTRA_PACKAGES="$(shell cat tags/$(CONTAINER_TAG)-packages)" .

container-buildx-push: check-dockerhub-env check-quay-env check-github-registry-env
	echo "${DOCKERHUB_PASSWORD}" | docker login -u "${DOCKERHUB_USERNAME}" --password-stdin
	echo "${QUAY_PASSWORD}" | docker login -u "${QUAY_USERNAME}" --password-stdin quay.io
	echo "${GITHUB_REGISTRY_PASSWORD}" | docker login -u "${GITHUB_REGISTRY_USERNAME}" --password-stdin ghcr.io
	docker buildx build $(TAGS) --platform $(CONTAINER_ARCHITECTURES) --build-arg ALPINE_VERSION=$(ALPINE_VERSION) --build-arg PYTHON_VERSION=$(PYTHON_VERSION) --build-arg SUPYSONIC_VERSION=$(SUPYSONIC_VERSION) --build-arg CONTAINER_TAG=$(CONTAINER_TAG) --build-arg EXTRA_PACKAGES="$(shell cat tags/$(CONTAINER_TAG)-packages)" --push .

.PHONY: all check-dockerhub-env check-quay-env check-github-registry-env container-build container-buildx container-buildx-push
# vim:ft=make
