properties([
    durabilityHint('PERFORMANCE_OPTIMIZED'),
    buildDiscarder(logRotator(numToKeepStr: '5')),
])
    
node ("docker") {
  checkout scm
  sh "make docker"
  sh "make run"
  // TODO: Update te demo to support using the Azure mirror instead of the local Maven volume
  // sh "make demo-plugin"
}
