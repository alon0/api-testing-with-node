pipeline {
    environment {
        GIT_COMMIT_SHORT = sh(
                script: "printf \$(git rev-parse --short ${GIT_COMMIT})",
                returnStdout: true
        )
   }
    agent {
        kubernetes {
            label 'jenkins-agent'
            defaultContainer 'jnlp'
            yaml '''
apiVersion: v1
kind: Pod
metadata:
labels:
  component: ci
spec:
  # Use service account that can deploy to all namespaces
  serviceAccountName: default
  containers:
  - name: docker
    image: docker:latest
    tty: true
    volumeMounts:
    - mountPath: /var/run/docker.sock
      name: docker-sock
    - mountPath: /usr/bin/docker
      name: docker-bin
  volumes:
    - name: docker-sock
      hostPath:
        path: /var/run/docker.sock
    - name: docker-bin
      hostPath:
        path: /usr/bin/docker
'''
        }
    }
    stages {
        stage('Build') {
            agent {
                dockerfile {
                    filename 'Dockerfile'
                    dir '.'
                    label 'api-testing-with-node:${GIT_COMMIT_SHORT}'
                }
            // steps {
            //     script {
            //         def dockerImage = docker.build("api-testing-with-node:${GIT_COMMIT_SHORT}")
            //         dockerImage.push()
            //     }
                // sh 'whereis docker'
                // sh 'docker build -t api-testing-with-node:${GIT_COMMIT_SHORT} .'
            }
        }
        stage('Unit Tests') {
            steps {
                sh 'echo "Unit Tests"'
            }
        }
        stage('Linting') {
            steps {
                sh 'echo "Linting"'
            }
        }
    }
}
