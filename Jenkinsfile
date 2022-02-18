pipeline {
  agent {
    kubernetes {
      label 'api-testing'
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
  volumes:
    - name: docker-sock
      hostPath:
        path: /var/run/docker.sock
"""
}
   }
    stages {
        stage('Build') {
            steps {
                sh 'docker build -t api-testing-with-node:${GIT_COMMIT} .'
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