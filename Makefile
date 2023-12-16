IMAGE=$(shell basename $(PWD))
export BUILDTAG:=$(shell date +%Y%m%d.%H%M%S)

# only for testing!
export USER=jumper
export PASS=123
export TOTP=LT2MSLFXAW7YT4Z65RVCAO2VFU


all: image

image:
	docker build --build-arg BUILDTAG=$(BUILDTAG) --build-arg USER=$(USER) -t $(IMAGE) .
	docker tag $(IMAGE) $(DOCKER_REGISTRY)/$(IMAGE):$(BUILDTAG)
	docker push $(DOCKER_REGISTRY)/$(IMAGE):$(BUILDTAG)

imagerun:
	docker build -t $(IMAGE) .
	-docker stop $(IMAGE)
	docker run -it -p 2222:22 --name $(IMAGE) --rm -e USER=$(USER) -e PASS=$(PASS) -e TOTP=$(TOTP) $(IMAGE)

.PHONY: all image imagerun
