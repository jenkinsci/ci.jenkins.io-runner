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
	    -v $(shell pwd)/demo/locale-plugin/repo/:/workspace/ \
	    $(DOCKER_TAG)

.PHONY: demo-plugin-local-lib
demo-plugin-local-lib:
	docker run --rm ${DOCKER_RUN_OPTS} \
		-v ${PIPELINE_LIBRARY_DIR}:/var/jenkins_home/pipeline-library \
	    -v $(shell pwd)/demo/locale-plugin/repo:/workspace/ \
	    $(DOCKER_TAG) 

.PHONY: jfr-profile
jfr-profile:
	mkdir -p war-empty && \
	mkdir -p demo/locale-plugin/work && \
	cd demo/locale-plugin/work && \
	CASC_JENKINS_CONFIG=../../../jenkins-dev.yaml \
	JAVA_OPTS=-XX:StartFlightRecording=disk=true,dumponexit=true,filename=recording.jfr,maxsize=1024m,maxage=1d,settings=profile,path-to-gc-roots=true \
	../../../target/appassembler/bin/jenkinsfile-runner \
	-p ../../../target/plugins/ -w war-empty -f ../repo/Jenkinsfile
