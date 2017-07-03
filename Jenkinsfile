pipeline {
  agent any

  options {
    buildDiscarder logRotator(daysToKeepStr: '10')
    timeout(time: 10, unit: 'MINUTES')
    ansiColor('xterm')
  }

  stages {
    stage('Build') {
      steps {
        echo 'Build docker image'
        sh 'make check'
        sh 'make build'
      }
    }

    stage('Deploy') {
      steps {
        echo 'Push to Docker Hub'
      }
    }
  }
}
