pipeline {
  agent any

  stages {

    stage('Test Environment Setup') {
      steps {
        script {
          test_env_docker_image = docker.build("pipeline-test-env:latest", '--no-cache=true -f ./docker/environments/Dockerfile.Test .')
        }
      }
    }

    stage('Test Execution') {
      parallel {

        stage('Lint Test') {
          agent any
          steps {
            script {
              test_env_docker_image.inside {
                sh 'pipenv run tox -e lint'
              }
            }
          }
        }

        stage('Run Tests') {
          agent any
          steps {
            script {
              test_env_docker_image.inside {
                sh 'pipenv run tox -e test'
              }
            }
          }
          post{
            always {
              junit skipPublishingChecks: true, testResults: 'reports/test-execution-report.xml'
            }
          }
        }

        stage('Generate Documentation Test') {
          agent any
          steps {
            script {
              test_env_docker_image.inside {
                sh 'pipenv run tox -e docs'
              }
            }
          }
          post{
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

        stage('Build Package Test') {
          agent any
          steps {
            script {
              test_env_docker_image.inside {
                sh 'pipenv run tox -e build'
              }
            }
            archiveArtifacts 'dist/*.*'
          }
          environment {
            DEVPI_INDEX="pipeline"
            DEVPI_REPO="build"
            DEVPI_URL="http://pipeline.devpi"
            DEVPI_PORT="3242"
          }
          post{
            success {
              withCredentials([string(credentialsId: 'devpi-pipeline', variable: 'DEVPI_PASSWORD')]) {
                script {
                  test_env_docker_image.inside() {
                    sh '''
                    devpi use ${DEVPI_URL}:${DEVPI_PORT} --set-cfg
                    devpi login ${DEVPI_INDEX} --password=${DEVPI_PASSWORD}
                    devpi use ${DEVPI_INDEX}/${DEVPI_REPO}
                    devpi upload --formats=* --from-dir dist
                    '''
                  }
                }
              }
            }
          }
        }

      }
    }

    stage('Prod-like Environment Setup') {
      steps {
        script {
          prod_env_docker_image = docker.build("pipeline-prod-env:latest", '--no-cache=true -f ./docker/environments/Dockerfile.Prod .')
        }
      }
    }

    stage('Installation Test') {
      agent any
      steps {
        script {
          prod_env_docker_image.inside {
            sh 'pip install example-functionality'
          }
        }
      }
    }

  }
}