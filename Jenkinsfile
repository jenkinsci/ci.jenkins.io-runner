properties([
    durabilityHint('PERFORMANCE_OPTIMIZED'),
    buildDiscarder(logRotator(numToKeepStr: '5')),
])
    
node ("linux") {
    stage("Checkout") {
        checkout scm
    }
    
    stage ("Build") {
        def settingsXml = "${pwd tmp: true}/settings-azure.xml"
        def hasSettingsXml = false
        if (retrieveMavenSettingsFile(settingsXml)) {
           // Running within Jenkins infra
           hasSettingsXml = true
        }
        sh "make clean docker"
        infra.runWithMaven("make build")
    }
    
    stage("Run demo jobs") {
        sh "make run"
        // TODO: Update the demo to support using the Azure mirror instead of the local Maven volume
        // sh "make demo-plugin"
    }
}
