pipeline {
  agent any

  stages {
    stage('Checkout'){
      checkout scm
    }

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
