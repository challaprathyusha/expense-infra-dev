pipeline {
    agent {
        label 'AGENT-1'
    }
    options {
        timeout(time: 1, unit: 'HOURS') 
        disableConcurrentBuilds()
    }
    
    stages {
        stage('Init') {
            steps {
               sh """
               ls -l
            """
            }
        }
        stage('plan') {
            steps {
                sh 'sleep 10'
            }
        }
        stage('Deploy') {
            steps {
                sh 'echo deploy stage in pipeline'
                
            }
        }
    }
    
     post { 
       always { 
            echo 'I will always say Hello again!'
        }
         success { 
            echo 'I will run when pipeline is success'
        }
        failure { 
            echo 'I will run when pipeline is failure'
        }
    }
}