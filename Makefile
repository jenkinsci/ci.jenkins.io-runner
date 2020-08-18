# Just a Makefile for manual testing
.PHONY: all

DOCKER_TAG=jenkins4eval/ci.jenkins.io-runner:local-test
PIPELINE_LIBRARY_DIR=/Users/nenashev/Documents/jenkins/infra/pipeline-library/
DOCKER_RUN_OPTS=-v maven-repo:/root/.m2

all: clean build

clean:
	rm -rf tmp

.PHONY: docker
docker:
	docker build -t $(DOCKER_TAG) .

build: docker

.PHONY: run
run:
	docker run --rm ${DOCKER_RUN_OPTS} \
	    -v $(shell pwd)/demo/simple/:/workspace/ \
	    $(DOCKER_TAG) 

.PHONY: demo-plugin
demo-plugin:
	docker run --rm ${DOCKER_RUN_OPTS} \
	    -v $(shell pwd)/demo/locale-plugin/:/workspace/ \
	    $(DOCKER_TAG)

.PHONY: demo-plugin-local-lib
demo-plugin-local-lib:
	docker run --rm ${DOCKER_RUN_OPTS} \
		-v ${PIPELINE_LIBRARY_DIR}:/var/jenkins_home/pipeline-library \
	    -v $(shell pwd)/demo/locale-plugin/:/workspace/ \
	    $(DOCKER_TAG) 
