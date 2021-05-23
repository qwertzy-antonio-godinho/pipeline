pipeline {
  agent {
    dockerfile {
      filename './docker/environments/Dockerfile.Test'
      additionalBuildArgs '--no-cache=true'
    }

  }
  stages {

        stage('Lint Test') {
          steps {
            sh 'pipenv run tox -e lint'
          }
        }

        stage('Test') {
          steps {
            sh 'pipenv run tox -e test'
          }
        }

        stage('Generate Documentation Test') {
          steps {
            sh 'pipenv run tox -e docs'
          }
        }

        stage('Generate Build Test') {
          steps {
            sh 'pipenv run tox -e build'
            archiveArtifacts 'dist/*.*'
          }
        }

  }
  post{
    always {
      junit skipPublishingChecks: true, testResults: 'reports/test-execution-report.xml'
    }
    success {
      publishHTML (target: [
        allowMissing: false,
        alwaysLinkToLastBuild: false,
        keepAll: true,
        reportDir: 'dist/docs/src',
        reportFiles: 'index.html',
        reportName: "Source Documentation"
      ])
      publishHTML (target: [
        allowMissing: false,
        alwaysLinkToLastBuild: false,
        keepAll: true,
        reportDir: 'dist/docs/tests',
        reportFiles: 'index.html',
        reportName: "Tests Documentation"
      ])
    }
  }

}