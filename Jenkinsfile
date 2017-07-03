pipeline {
  agent any

  stages {
    stage('Build') {
      ansiColor('xterm') {
        steps {
          echo 'Build docker image'
          sh 'make check'
          sh 'make build'
        }
      }
    }

    stage('Deploy') {
      steps {
        echo 'Push to Docker Hub'
      }
    }
  }
}
