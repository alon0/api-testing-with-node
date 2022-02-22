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
                serviceAccountName: jenkins
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
                    - containerPort: 5000
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
            container('test') {
              sh '''
                npm install -g eslint 
                npm install @eslint/create-config
                # npm init @eslint/config
                # Debug
                pwd
                ls -al
                eslint -c .eslintrc.json *.js
              '''
            }
          }
        }
        stage('Docker Build and Upload') {
          steps {
            container('docker') {
              sh '''
                # docker build -t $DOCKERHUB_CREDENTIALS_USR/api-testing:${GIT_COMMIT_SHORT} .
                docker build -t alon0/devops-proj:${GIT_COMMIT_SHORT} .
                echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
                # docker push $DOCKERHUB_CREDENTIALS_USR/api-testing:${GIT_COMMIT_SHORT}
                docker push alon0/devops-proj:${GIT_COMMIT_SHORT}
              ''' 
                }
            }
        }
        stage('Deploy') {
          steps {
            git branch: 'dev',
                url: 'git@github.com:alon0/DevOps-proj.git' 
            sh '''
              helm install -n ci -f k8s/api-testing-with-node/values-ci.yaml api-${BUILD_NUMBER} ./k8s/api-testing-with-node --set image.tag=${GIT_COMMIT_SHORT}
              
            ''' 
              }
        }
    }
}
