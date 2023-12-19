IMAGE=$(shell basename $(PWD))
export BUILDTAG:=$(shell date +%Y%m%d.%H%M%S)

# only for testing!
# export JUMPHOST=jumpcontainer
# export JUMPUSER=jumper
# export JUMPPASS=123
# export JUMPTOTP=LT2MSLFXAW7YT4Z65RVCAO2VFU
# export JUMPKEY=ssh-rsa ABC...= user@laptop

all: image

image:
	docker build --build-arg BUILDTAG=$(BUILDTAG) -t $(IMAGE) .
	docker tag $(IMAGE) $(DOCKER_REGISTRY)/$(IMAGE):$(BUILDTAG)
	docker push $(DOCKER_REGISTRY)/$(IMAGE):$(BUILDTAG)
	docker tag $(IMAGE) $(DOCKER_REGISTRY)/$(IMAGE):latest
	docker push $(DOCKER_REGISTRY)/$(IMAGE):latest

imagerun:
	docker build --build-arg BUILDTAG=$(BUILDTAG) -t $(IMAGE) .
	-docker stop $(IMAGE)
	docker run -it -p 2222:2222 --name $(IMAGE) --rm \
	 -e JUMPHOST=$(JUMPHOST) -e JUMPUSER=$(JUMPUSER) -e JUMPPASS=$(JUMPPASS) \
	 -e JUMPTOTP=$(JUMPTOTP) -e JUMPKEY="$(JUMPKEY)" -e BUILDTAG=$(BUILDTAG) \
	 $(IMAGE)

.PHONY: all image imagerun
