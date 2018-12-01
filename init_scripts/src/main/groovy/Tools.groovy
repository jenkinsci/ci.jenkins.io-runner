
import jenkins.model.Jenkins
import hudson.model.JDK
import hudson.tasks.Maven.MavenInstallation;
import hudson.tasks.Maven

println("== Configuring tools...")
// By default we offer no JDK7, Nodes should override
JDK jdk7 = new JDK("jdk7", "/non/existent/JVM")
// Java 8 should be a default Java, because we require it for Jenkins 2.60.1+
JDK jdk8 = new JDK("jdk8", "")
JDK jdk11 = new JDK("jdk11", "/usr/lib/jvm/java-11-opendjdk-amd64")
Jenkins.instance.getDescriptorByType(JDK.DescriptorImpl.class).setInstallations(jdk7, jdk8, jdk11)

MavenInstallation mvn = new MavenInstallation("mvn", null)
Jenkins.instance.getDescriptorByType(Maven.DescriptorImpl.class).setInstallations(mvn)
