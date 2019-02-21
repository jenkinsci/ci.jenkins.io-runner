properties([
    durabilityHint('PERFORMANCE_OPTIMIZED'),
    buildDiscarder(logRotator(numToKeepStr: '5')),
])
    
node ("docker") {
    stage("Checkout") {
        checkout scm
    }
    
    stage ("Build") {
        sh "make docker build"
    }
    
    stage("Run demo jobs") {
        sh "make run"
        // TODO: Update the demo to support using the Azure mirror instead of the local Maven volume
        // sh "make demo-plugin"
    }
}
