#!groovy

node('node') {
  currentBuild.result = "SUCCESS"

  try {

    stage('Checkout') {
      checkout scm
    }

    stage('Build') {
      echo 'Build docker image'
      sh 'make check'
      sh 'make build'
    }

    stage('Deploy') {
      echo 'Push to Docker Hub'
    }
  }
  catch (err) {
    currentBuild.result = "FAILURE"
    throw err
  }
}
