DOCKER_USER := ogarcia
DOCKER_ORGANIZATION := ogarcia
DOCKER_IMAGE := supysonic

docker-image:
	docker build -t $(DOCKER_ORGANIZATION)/$(DOCKER_IMAGE) .

docker-image-test: docker-image
	docker run --name supysonic -d -e SUPYSONIC_RUN_MODE="standalone" -p 5000:5000 $(DOCKER_ORGANIZATION)/$(DOCKER_IMAGE)
	sleep 5
	curl -v -L 'http://localhost:5000/user/login' --data 'user=admin&password=admin'
	docker kill supysonic
	docker rm supysonic

ci-test: docker-image-test

.PHONY: docker-image docker-image-test ci-test
# vim:ft=make
