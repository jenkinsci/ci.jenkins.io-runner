ci.jenkins.io-runner
===

This project offers environment for running Jenkinsfile instances from ci.jenkins.io locally.
It is powered by [Jenkinsfile Runner](https://github.com/jenkinsci/jenkinsfile-runner)
and [Custom WAR Packager](https://github.com/jenkinsci/custom-war-packager).

The runner can execute `buildPlugin()` builds and some other commands from
the [Jenkins Pipeline Library](https://github.com/jenkins-infra/pipeline-library).
In particular, it is possible to run builds against multiple JDK and Jenkins core version combinations.

See the _Limitations_ section below for some of known limitations.

### Quickstart

1. Checkout this repo
2. Run `make docker` to build the base image
3. Run `make clean build` to build the Jenkinsfile Runner image
4. Run `make run` to run a simple demo
5. Run `make demo-plugin` to run a demo of the plugin build

### Usage

The runner can be invoked against a workspace which contains a `Jenkinsfile`
and, if needed, the project's sourcecode.

```
	docker run --rm -v maven-repo:/root/.m2 \
	    -v $(pwd)/demo/locale-plugin/:/workspace/ \
	    onenashev/ci.jenkins.io-runner
```

### Developing Jenkins Pipeline Library

Jenkins Pipeline library may be passed from a volume so that it is possible to test a local snapshot.

```
	docker run --rm -v maven-repo:/root/.m2 \
	    -v ${MY_PIPELINE_LIBRARY_DIR}:/var/jenkins_home/pipeline-library \
	    -v $(pwd)/demo/locale-plugin/:/workspace/ \
	    onenashev/ci.jenkins.io-runner
```

### Developer notes

#### Upgrade management

Current versions of Custom WAR Packager are not good at preventing 
upper bound conflicts between plugins ([JENKINS-51068](https://issues.jenkins-ci.org/browse/JENKINS-51068)).
In order to work it around, this repository uses `pom.xml` as an input instead of defining plugins in YAML directly.
So it is possible to ensure that the plugin set is OK just by running `mvn clean verify`.

As a second advantage,
usage of pom.xml allows using [Dependabot](https://dependabot.com/) to track dependencies and to propose updates.
This dependency management is quite dangerous, because there is no CI created for this repository so far.

#### Debugging Jenkinsfile Runner

To debug the execution, you can pass the `JFR_LOCAL_WORKSPACE=true` environment variable to the image.
It will make the builder to execute Pipeline directly 

### Limitations

* A custom fork of Jenkins Pipeline Library is needed to run it
  * Follow https://github.com/jenkins-infra/pipeline-library/pull/78
* `ci.jenkins.io-runner` is a single-container package with only 1 executor
* Only JDK8 and JDK11 are provided in the image
* Windows steps are not supported
* Docker-in-Docker is not supported. Steps like `runATH()` and `runPCT()` will not work
* The runner uses the recent Debian version, and hence it is affected by
  [SUREFIRE-1588](https://issues.apache.org/jira/browse/SUREFIRE-1588).
  Plugin POM 3.28 or above should be used to run the build successfully

