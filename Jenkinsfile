properties([
    durabilityHint('PERFORMANCE_OPTIMIZED'),
    buildDiscarder(logRotator(numToKeepStr: '5')),
])
    
node ("linux") {
    def settingsXml = "${pwd tmp: true}/settings-azure.xml"
    def hasSettingsXml = false
    stage("Checkout") {
        checkout scm
        if (infra.retrieveMavenSettingsFile(settingsXml)) {
           // Running within Jenkins infra
           hasSettingsXml = true
        }
    }
    
    stage ("Build") {
        sh "make clean docker"
        
        def makeCommand = "make build"
        if (hasSettingsXml) {
            makeCommand += " -e MVN_SETTINGS_FILE='${settingsXml}'"
        }
        infra.runWithMaven(makeCommand)
    }
    
    stage("Run demo jobs") {
        def runOptions = ""
        if (hasSettingsXml) {
            runOptions += " -e DOCKER_RUN_OPTS='-v ${settingsXml}:/root/.m2/settings.xml:ro'"
        }
        
        stage("Smoke test") {
          sh "make run ${runOptions}"
        }
        stage("Plugin build") {
          sh "make demo-plugin ${runOptions}"
        }
    }
}
