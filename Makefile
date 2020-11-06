PYTHON_VERSION := 3.8-alpine
SUPYSONIC_VERSION := 194bf5e277c7069b0e8eb36d26017e2b65789738
DOCKER_ORGANIZATION := ogarcia
DOCKER_IMAGE := supysonic
DOCKER_IMAGE_FILENAME ?= $(DOCKER_ORGANIZATION)_$(DOCKER_IMAGE).tar

all: docker-build docker-test

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

docker-build:
	docker build -t $(DOCKER_ORGANIZATION)/$(DOCKER_IMAGE) --build-arg PYTHON_VERSION=$(PYTHON_VERSION) --build-arg SUPYSONIC_VERSION=$(SUPYSONIC_VERSION) .

docker-test:
	docker image inspect $(DOCKER_ORGANIZATION)/$(DOCKER_IMAGE)
	docker run --name $(DOCKER_IMAGE) -d -e SUPYSONIC_RUN_MODE="standalone" -p 5000:5000 $(DOCKER_ORGANIZATION)/$(DOCKER_IMAGE)
	sleep 5
	curl -v -L 'http://localhost:5000/user/login' --data 'user=admin&password=admin'
	docker kill $(DOCKER_IMAGE)
	docker rm $(DOCKER_IMAGE)

docker-save:
	docker image inspect $(DOCKER_ORGANIZATION)/$(DOCKER_IMAGE) > /dev/null 2>&1
	docker save -o $(DOCKER_IMAGE_FILENAME) $(DOCKER_ORGANIZATION)/$(DOCKER_IMAGE)

docker-load:
ifneq ($(wildcard $(DOCKER_IMAGE_FILENAME)),)
	docker load -i $(DOCKER_IMAGE_FILENAME)
endif

dockerhub-push: check-dockerhub-env
	echo "${DOCKERHUB_PASSWORD}" | docker login -u "${DOCKERHUB_USERNAME}" --password-stdin
	docker push $(DOCKER_ORGANIZATION)/$(DOCKER_IMAGE):latest
ifdef CIRCLE_TAG
	docker tag $(DOCKER_ORGANIZATION)/$(DOCKER_IMAGE):latest $(DOCKER_ORGANIZATION)/$(DOCKER_IMAGE):${CIRCLE_TAG}
	docker push $(DOCKER_ORGANIZATION)/$(DOCKER_IMAGE):${CIRCLE_TAG}
endif

quay-push: check-quay-env
	echo "${QUAY_PASSWORD}" | docker login -u "${QUAY_USERNAME}" --password-stdin quay.io
	docker tag $(DOCKER_ORGANIZATION)/$(DOCKER_IMAGE):latest quay.io/$(DOCKER_ORGANIZATION)/$(DOCKER_IMAGE):latest
	docker push quay.io/$(DOCKER_ORGANIZATION)/$(DOCKER_IMAGE):latest
ifdef CIRCLE_TAG
	docker tag $(DOCKER_ORGANIZATION)/$(DOCKER_IMAGE):latest quay.io/$(DOCKER_ORGANIZATION)/$(DOCKER_IMAGE):${CIRCLE_TAG}
	docker push quay.io/$(DOCKER_ORGANIZATION)/$(DOCKER_IMAGE):${CIRCLE_TAG}
endif

.PHONY: all check-dockerhub-env check-quay-env docker-build docker-test docker-save dockerhub-push quay-push
# vim:ft=make
