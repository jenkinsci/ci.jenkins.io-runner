ci.jenkins.io-runner
===

[![GitHub release (latest by date including pre-releases)](https://img.shields.io/github/v/release/jenkinsci/ci.jenkins.io-runner?include_prereleases&label=changelog)](https://github.com/jenkinsci/ci.jenkins.io-runner/releases/latest)
[![](https://images.microbadger.com/badges/image/onenashev/ci.jenkins.io-runner.svg)](https://microbadger.com/images/onenashev/ci.jenkins.io-runner "Get your own image badge on microbadger.com")
[![Gitter](https://badges.gitter.im/jenkinsci/jenkinsfile-runner.svg)](https://gitter.im/jenkinsci/jenkinsfile-runner)

This project offers environment for running Jenkinsfile instances from ci.jenkins.io locally.
It is powered by [Jenkinsfile Runner](https://github.com/jenkinsci/jenkinsfile-runner) and the experimental [JFR Maven packaging flow](https://github.com/jenkinsci/jenkinsfile-runner/tree/master/packaging-parent-pom) introduced in 1.0-beta-16.
If you want a classic runtime Jenkins master with agents, 
checkout [my Jenkins Configuration-as-code demo](https://github.com/oleg-nenashev/demo-jenkins-config-as-code).

The runner can execute `buildPlugin()` builds and some other commands from
the [Jenkins Pipeline Library](https://github.com/jenkins-infra/pipeline-library).
In particular, it is possible to run builds against multiple JDK and Jenkins core version combinations.

See the _Limitations_ section below for some of known limitations.

### Quickstart

1. Checkout this repo
2. Run `make docker` to build the base image
3. Run `make run` to run a simple demo
4. Run `make demo-plugin` to run a demo of the plugin build

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

This repository uses [Dependabot](https://dependabot.com/) to track dependencies and to propose updates.
Many plugin and library dependencies actually come from Bills of Materials supplied by the JFR packaging parent POM:
[Jenkins Core BOM](https://github.com/jenkinsci/jenkins/tree/master/bom) and
[Jenkins Plugin BOM](https://github.com/jenkinsci/bom).
It reduces the number of moving parts by consuming the cross-verified plugin versions.

#### Debugging Jenkinsfile Runner

To debug the execution, you can pass the `JFR_LOCAL_WORKSPACE=true` environment variable to the image.
It will make the builder to execute Pipeline directly.
It is also possible to debug Jenkinsfile Runner and Groovy init hooks by passing the remote debug options and exposing the debug port:

```
	docker run --rm -v maven-repo:/root/.m2 \
	    -v $(pwd)/demo/locale-plugin/:/workspace/ \
	    -p 5005:5005 -e JAVA_OPTS="-agentlib:jdwp=transport=dt_socket,server=y,address=5005,suspend=y" \
	    onenashev/ci.jenkins.io-runner
```

#### Profiling Jenkinsfile Runner

This repository supports profiling of Jenkinsfile Runner with Java Flight Recorder.
Due to performance reasons, profiling happens on a local machine instead of the Docker containers.

To run profiling on a Unix machine:

* Build ci.jenkins.io-runner locally via `mvn clean package`
* Run `make jfr-profile` and wait till completion
* Retrieve the `demo/locale-plugin/work/recording.jfr` file with Java Flight Recorder dump
* Use performance analysis tools to analyze the Java Flight Recorder dump (e.g. IntelligIDEA, JDK Mission Control in AdoptOpenJDK).
  CPU and memory usage analysis can be done with the existing tools.

### Limitations

This project has just started, so it has some downsides being compared 
to the runtime Pipeline Development instance [here](https://github.com/oleg-nenashev/demo-jenkins-config-as-code).
All of the limitations below can be improved in the future.

* A custom fork of Jenkins Pipeline Library is needed to run it
  * Follow https://github.com/jenkins-infra/pipeline-library/pull/78
* `ci.jenkins.io-runner` is a single-container package with only 1 executor
* Only JDK8 and JDK11 are provided in the image
* Windows steps are not supported
* Docker image is pretty big, because it bundles two versions of JDK
