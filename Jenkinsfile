pipeline {
    environment {
        GIT_COMMIT_SHORT = sh(
                script: "printf \$(git rev-parse --short ${GIT_COMMIT})",
                returnStdout: true
        )
        DOCKERHUB_CREDENTIALS=credentials('dockerHub')
   }
    agent {
        kubernetes {
            // label 'jenkins-agent'
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
                - name: source-code
                  image: node
                  tty: true
                  ports:
                    - container: 5000
                - name: test
                  image: node
                  tty: true
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
        steps {
          container('source-code') {
            sh '''
              npm install
              npm start &
              #docker build -t api-testing:latest .
            '''
          // sh '''
          //   cd k8s
          //   kubectl apply -f namespace.yaml 
          //   kubectl -n ci apply -f deployment.yaml service.yaml
          // '''
          }
        }
      }
      stage('Unit Tests') {
        steps {
          container('test') {
            sh '''
              npm install -g mocha chai
              make test
            '''
          }
        }
      }
        stage('Linting') {
            steps {
                sh 'echo "Linting"'
            }
        }
        stage('Upload') {
            steps {
                container('docker') {
                    sh """
                                echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
                                docker push $DOCKERHUB_CREDENTIALS_USR/api-testing:${GIT_COMMIT_SHORT}
                                                        """
                }
            }
        }
    }
}
