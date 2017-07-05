pipeline {
  agent any

  options {
    buildDiscarder logRotator(daysToKeepStr: '30')
    timeout(time: 10, unit: 'MINUTES')
    ansiColor('xterm')
  }

  stages {
    stage('Build') {
      steps {
        echo 'Build Docker image'
        sh 'make check'
        sh 'make build'
      }
    }

    stage('Deploy') {
      steps {
        echo 'Push to Docker Hub'
      }
    }

    stage('Clean') {
      steps {
        echo 'Clean Docker images'
        sh 'make clean-docker'
        sh 'make clean'
      }
    }
  }
}
