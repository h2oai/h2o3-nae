OWNER:=h2o3
BRANCH:=$(shell git rev-parse --abbrev-ref HEAD)
REV:=$(shell git rev-parse --short=10 HEAD)

image: Dockerfile
	docker build -t $(OWNER):$(BRANCH) .

tag: image
	docker tag $(OWNER):$(BRANCH) opsh2oai/$(OWNER):$(REV)

push : tag
	docker push opsh2oai/$(OWNER):$(BRANCH) && docker push opsh2oai/$(OWNER):$(REV)
