IMAGE=$(shell basename $(PWD))
export BUILDTAG:=$(shell date +%Y%m%d.%H%M%S)

# only for testing!
#export JUMPUSER=jumper
#export JUMPPASS=123
#export JUMPTOTP=LT2MSLFXAW7YT4Z65RVCAO2VFU

all: image

image:
	docker build --build-arg BUILDTAG=$(BUILDTAG) --build-arg JUMPUSER=$(JUMPUSER) -t $(IMAGE) .
	docker tag $(IMAGE) $(DOCKER_REGISTRY)/$(IMAGE):$(BUILDTAG)
	docker push $(DOCKER_REGISTRY)/$(IMAGE):$(BUILDTAG)

imagerun:
	docker build -t $(IMAGE) .
	-docker stop $(IMAGE)
	docker run -it -p 2222:22 --name $(IMAGE) --rm -e JUMPUSER=$(JUMPUSER) -e JUMPPASS=$(JUMPPASS) -e JUMPTOTP=$(JUMPTOTP) $(IMAGE)

.PHONY: all image imagerun
