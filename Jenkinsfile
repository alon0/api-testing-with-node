pipeline {
  agent {
    kubernetes {
      label 'jenkins-agent'
      defaultContainer 'jnlp'
      yaml """
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
"""
}
   }
    stages {
        stage('Build') {
            steps {
                sh 'which docker'
                script {
                    GIT_COMMIT_SHORT=`git rev-parse --short=8 ${GIT_COMMIT}`
                    docker build -t api-testing-with-node:${GIT_COMMIT_SHORT} .
                }
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