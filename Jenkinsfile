pipeline {
  environment {
    GIT_COMMIT_SHORT = sh(
      script: "printf \$(git rev-parse --short ${GIT_COMMIT})",
      returnStdout: true
    )
    DOCKERHUB_CREDENTIALS=credentials('dockerHub')
    BACKEND_API="DEFAULT"
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
          - name: helm
            image: "alpine/helm:latest"
            tty: true
            command: ["tail", "-f", "/dev/null"]
          - name: kubectl
            image: "sulemanhasib43/eks" #"bitnami/kubectl:latest"
            tty: true
            command: ["cat"]
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
            eslint -c .eslintrc.json *.js
          '''
        }
      }
    }
    stage('Docker Build and Upload') {
      steps {
        container('docker') {
          sh '''
            docker build -t alon0/devops-proj:${GIT_COMMIT_SHORT} .
            echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
            docker push alon0/devops-proj:${GIT_COMMIT_SHORT}
          ''' 
            }
        }
    }
    stage('Deploy') {
      steps {
        container('helm') {
          git credentialsId: 'git',
              branch: 'dev',
              url: 'git@github.com:alon0/DevOps-proj.git' 
          sh '''
            helm install -n ci -f k8s/api-testing-with-node/values-ci.yaml build-${BUILD_NUMBER} ./k8s/api-testing-with-node --set image.tag=${GIT_COMMIT_SHORT}
          ''' 
          }
        container('kubectl') {
          sh '''
            NODE_PORT=$(kubectl get --namespace ci -o jsonpath="{.spec.ports[0].nodePort}" services build-${BUILD_NUMBER}-api-testing-with-node)
            NODE_IP=$(kubectl get nodes --namespace ci -o jsonpath="{.items[0].status.addresses[0].address}")
            BACKEND_API=`echo http://$NODE_IP:$NODE_PORT`
          '''
        }
      }
    }
  }
  post {
    success {
        echo 'executing api-testing-with-node-qa'
        build job: 'api-testing-with-node-qa', parameters: [string(name: 'BACKEND_API', value: '${BACKEND_API}')]
    }
  }
}
