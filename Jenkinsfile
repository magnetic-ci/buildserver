pipeline {
  agent any
  stages {
    stage('Build') {
      echo 'Build docker image'
      sh 'make check'
      sh 'make build'
    }

    stage('Deploy') {
      echo 'Push to Docker Hub'
    }
  }
}
