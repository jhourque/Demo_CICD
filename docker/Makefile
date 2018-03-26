VERSION ?= latest
BUILD_DATE := $(shell date +%F)
DOCKER_TAG ?= website:$(VERSION)
REPO=$(shell cd ../terraform/static && terraform output ecr_app_url)

all: build tag push

build:
	docker build \
		--build-arg VERSION=$(VERSION) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		-t $(DOCKER_TAG) .

tag:
	docker tag $(DOCKER_TAG) $(REPO):$(VERSION)

push:
	@docker push $(REPO):$(VERSION)

clean:
	@docker rmi $(DOCKER_TAG) $(REPO):$(VERSION)
