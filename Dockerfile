FROM jenkins/jenkinsfile-runner:build-mvncache as jfr-mvncache

FROM jenkins/jenkinsfile-runner:1.0-beta-15 as jfr-base

###
# Build stage
###
FROM maven:3.5.4 as jfr-build
ENV MAVEN_OPTS=-Dmaven.repo.local=/mavenrepo
COPY --from=jfr-mvncache /mavenrepo /mavenrepo
ADD pom.xml /jenkinsfile-runner/pom.xml
RUN cd /jenkinsfile-runner && mvn clean package
# TODO: Should be automated in Parent POM
# Prepare the Jenkins core
RUN mkdir /app && unzip /jenkinsfile-runner/target/war/jenkins.war -d /app/jenkins && \
  rm -rf /app/jenkins/scripts /app/jenkins/jsbundles /app/jenkins/css /app/jenkins/images /app/jenkins/help /app/jenkins/WEB-INF/detached-plugins /app/jenkins/winstone.jar /app/jenkins/WEB-INF/jenkins-cli.jar /app/jenkins/WEB-INF/lib/jna-4.5.2.jar
# Delete HPI files and use the archive directories instead
#RUN echo "Optimizing plugins..." && \
#  cd /jenkinsfile-runner/target/plugins && \
#  rm -rf *.hpi && \
#  for f in * ; do echo "Exploding $f..." && mv "$f" "$f.hpi" ; done;

####
# Production image
####
FROM adoptopenjdk:8u262-b10-jdk-hotspot

LABEL Description="This is a base image for a single-shot ci.jenkins.io demo" Vendor="Oleg Nenashev" Version="0.3"

# Packages
RUN apt-get update && apt-get install -y wget git && rm -rf /var/lib/apt/lists/*

# Maven
ENV MAVEN_VERSION 3.6.3
RUN curl -Lf https://downloads.apache.org/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar -C /opt -xzv
ENV M2_HOME /opt/apache-maven-$MAVEN_VERSION
ENV maven.home $M2_HOME
ENV M2 $M2_HOME/bin
ENV PATH $M2:$PATH

# JDK11
RUN curl -L --show-error "https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.8%2B10/OpenJDK11U-jdk_x64_linux_hotspot_11.0.8_10.tar.gz" --output adoptopenjdk.tar.gz && \
    echo "6e4cead158037cb7747ca47416474d4f408c9126be5b96f9befd532e0a762b47  adoptopenjdk.tar.gz" | sha256sum -c && \
    tar xvzf adoptopenjdk.tar.gz && \
    mkdir -p /usr/lib/jvm && \
    mv "jdk-11.0.8+10/" /usr/lib/jvm/jdk-11 && \
    rm adoptopenjdk.tar.gz

COPY --from=jfr-build /jenkinsfile-runner/target/appassembler /app
COPY --from=jfr-build /jenkinsfile-runner/target/plugins /usr/share/jenkins/ref/plugins
COPY --from=jenkins/jenkinsfile-runner:1.0-beta-15 /app/bin/jenkinsfile-runner-launcher /app/bin/jenkinsfile-runner-launcher
# /app/jenkins is a location of the WAR file. It can be empty in the current packaging
RUN mkdir /app/jenkins

VOLUME /build
VOLUME /usr/share/jenkins/ref/casc

ENV JENKINS_HOME="/usr/share/jenkins/ref/"
ENV JAVA_OPTS="-Djenkins.model.Jenkins.slaveAgentPort=50000 -Djenkins.model.Jenkins.slaveAgentPortEnforce=true -Dhudson.model.LoadStatistics.clock=1000"
ENV CASC_JENKINS_CONFIG /usr/share/jenkins/ref/jenkins.yaml
COPY jenkins.yaml /usr/share/jenkins/ref/jenkins.yaml
COPY init_scripts/src/main/groovy/* /usr/share/jenkins/ref/init.groovy.d/

# Otherwise, JENKINS_HOME is not propagated
#ENTRYPOINT ["/app/bin/jenkinsfile-runner-launcher"]
ENTRYPOINT ["/app/bin/jenkinsfile-runner",\
            "-w", "/app/jenkins",\
            "-p", "/usr/share/jenkins/ref/plugins",\
            "-f", "/workspace/Jenkinsfile",\
            "--runWorkspace", "/build"]
