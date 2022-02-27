pipeline {
  // environment {
  //   // DOCKERHUB_CREDENTIALS=credentials('dockerHub')
  //   // BACKEND_API="Default"
  // }
  agent {
    kubernetes {
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
    stage('Deploy') {
      steps {
        container('helm') {
          git credentialsId: 'git',
              branch: 'dev',
              url: 'git@github.com:alon0/DevOps-proj.git' 
          sh '''
            helm upgrade -i --force -n deployment -f k8s/api-testing-with-node/values-dep.yaml deployment ./k8s/api-testing-with-node --set image.tag=stable-${GIT_COMMIT_SHORT}
          ''' 
          }
        container('kubectl') {
          sh '''
            NODE_PORT=$(kubectl get --namespace deployment -o jsonpath="{.spec.ports[0].nodePort}" services deployment-api-testing-with-node)
            NODE_IP=$(kubectl get nodes --namespace deployment -o jsonpath="{.items[0].status.addresses[0].address}")
            BACKEND_API=`echo http://$NODE_IP:$NODE_PORT`
            echo $BACKEND_API > url.env
          '''
        }
      }
    }
    stage('Execute QA Tests') {
      steps {
        container('test') {
          checkout([$class: 'GitSCM', branches: [[name: 'dev']], extensions: [], userRemoteConfigs: [[credentialsId: 'git', url: 'git@github.com:alon0/api-testing-with-node-qa.git']]])
          sh '''
            export BACKEND_API=`cat url.env`
            npm install
            npm install -g mocha chai
            npm test
          '''
        }
      }
    }
  }
}
