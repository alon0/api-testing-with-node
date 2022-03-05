pipeline {
  environment {
      ARGOCD_SERVER="argocd-server"
    }
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
          # - name: helm
          #   image: "alpine/helm:latest"
          #   tty: true
          #   command: ["tail", "-f", "/dev/null"]
          - name: kubectl
            image: "sulemanhasib43/eks" #"bitnami/kubectl:latest"
            tty: true
            command: ["cat"]
          - name: test
            image: node
            tty: true
          - name: argocd-cli
            image: argoproj/argocli
            tty: true
            command: ["cat"]
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
        container('argocd-cli') {
          // git credentialsId: 'git',
          //     branch: 'dev',
          //     url: 'git@github.com:alon0/DevOps-proj.git' 
          sh '''
            ARGOCD_SERVER=$ARGOCD_SERVER argocd app create api-${BUILD_NUMBER} \
              --repo 'git@github.com:alon0/DevOps-Proj.git' --path k8s/api-testing-with-node \
              --values values-dep.yaml --dest-server https://kubernetes.default.svc \
              --dest-namespace api-${BUILD_NUMBER} --sync-option CreateNamespace=true \
              --project default --revision dev \
              --parameter image.tag=stable-${GIT_COMMIT_SHORT} --upsert
          ''' 
          }
        container('kubectl') {
          sh '''
            NODE_PORT=$(kubectl get --namespace api-${BUILD_NUMBER} -o jsonpath="{.spec.ports[0].nodePort}" services api-${BUILD_NUMBER}-api-testing-with-node)
            NODE_IP=$(kubectl get nodes --namespace api-${BUILD_NUMBER} -o jsonpath="{.items[0].status.addresses[0].address}")
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
