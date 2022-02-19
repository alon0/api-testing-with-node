podTemplate(yaml: '''
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
                - name: node
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
  ) {
  node(POD_LABEL) {
    stage('Build') {
      environment {
        GIT_COMMIT_SHORT = sh(
                script: "printf \$(git rev-parse --short ${GIT_COMMIT})",
                returnStdout: true
        )
        DOCKERHUB_CREDENTIALS=credentials('dockerHub')
      }
      container('docker') {
        sh '''
          env
          docker build -t $DOCKERHUB_CREDENTIALS_USR/api-testing:${GIT_COMMIT_SHORT} .
        '''
      }
        
    }
    stage('Unit Tests') {
      container('node') {
          sh '''
            cd /usr/src/app
            npm test
          '''
      }
    }
    stage('Linting') {
      sh 'echo "Linting"'
    }
    stage('Upload') {
      container('docker') {
          sh '''
            echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
            docker push $DOCKERHUB_CREDENTIALS_USR/api-testing:${GIT_COMMIT_SHORT}
          '''
      }
    }
  }
}
