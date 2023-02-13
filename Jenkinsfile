properties([
    durabilityHint('PERFORMANCE_OPTIMIZED'),
    buildDiscarder(logRotator(numToKeepStr: '5')),
])

timeout(time: 2, unit: 'HOURS') {
    node ("linux") {
        stage("Checkout") {
            checkout scm
        }

        stage ("Build") {
            def makeCommand = "make clean build"
            infra.runWithMaven(makeCommand)
        }

        stage("Run demo jobs") {
            stage("Smoke test") {
              sh "make run"
            }
            stage("Plugin build") {
              sh "make demo-plugin"
            }
        }
    }
} 
