# Just a Makefile for manual testing
.PHONY: all

ARTIFACT_ID = jenkinsfile-runner-demo
VERSION = 256.0-test
CWP_MAVEN_REPO_PATH=io/jenkins/tools/custom-war-packager/custom-war-packager-cli
CWP_VERSION=2.0-alpha-2
DOCKER_TAG=jenkins4eval/ci.jenkins.io-runner:local-test
PIPELINE_LIBRARY_DIR=/Users/nenashev/Documents/jenkins/infra/pipeline-library/
CWP_OPTS=
DOCKER_RUN_OPTS=-v maven-repo:/root/.m2
# It will not work properly if Jenkins repo is not set, so missing settings is not an option here
MVN_SETTINGS_FILE ?= $(HOME)/.m2/settings.xml

#TODO: Replace snapshot parsing by something more reliable
ifneq (,$(findstring 1.6-2018,$(CWP_VERSION)))
	CWP_MAVEN_REPO=https://repo.jenkins-ci.org/snapshots
	CWP_BASE_VERSION=1.6-SNAPSHOT
else
	CWP_MAVEN_REPO=https://repo.jenkins-ci.org/releases
	CWP_BASE_VERSION=$(CWP_VERSION)
endif

all: clean build

clean:
	rm -rf tmp

.PHONY: docker
docker:
	docker build -t $(DOCKER_TAG) .

build: docker

#docker:
#	docker build -t jenkins/ci.jenkins.io-runner.base .
#
#.build/cwp-cli-${CWP_VERSION}.jar:
#	rm -rf .build
#	mkdir -p .build
#	wget -O .build/cwp-cli-${CWP_VERSION}.jar $(CWP_MAVEN_REPO)/${CWP_MAVEN_REPO_PATH}/${CWP_BASE_VERSION}/custom-war-packager-cli-${CWP_VERSION}-jar-with-dependencies.jar
#	touch .build/cwp-cli-${CWP_VERSION}.jar
#
#build: .build/cwp-cli-${CWP_VERSION}.jar
#	java -jar .build/cwp-cli-${CWP_VERSION}.jar \
#	     -configPath packager-config.yml -version ${VERSION} ${CWP_OPTS} \
#		 -mvnSettingsFile ${MVN_SETTINGS_FILE}

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

.PHONY: jfr-profile
jfr-profile:
	mkdir -p war-empty && \
	mkdir -p demo/locale-plugin/work && \
	cd demo/locale-plugin/work && \
	CASC_JENKINS_CONFIG=../../../jenkins-dev.yaml \
	JAVA_OPTS=-XX:StartFlightRecording=disk=true,dumponexit=true,filename=recording-no-war.jfr,maxsize=1024m,maxage=1d,settings=profile,path-to-gc-roots=true \
	../../../target/appassembler/bin/jenkinsfile-runner \
	-p ../../../target/plugins/ -w war-empty -f ../repo/Jenkinsfile
