pipeline {
    agent {
        label 'AGENT-1'
    }
    options {
        timeout(time: 1, unit: 'HOURS') 
        disableConcurrentBuilds()
        ansiColor('xterm')
    }
    parameters {
        choice(name: 'action', choices: ['Apply', 'Destroy'], description: 'Pick something')
    }

    stages {
        stage('Init') {
            steps {
                sh """
                cd 01-vpc
                terraform init -reconfigure
                """
            }
        }
        stage('plan') {
            steps {
                sh """
                cd 01-vpc
                terraform plan
                """
            }
        }
        stage('Deploy') {
            // if we want to proceed to next stage based on previous stage 
            input {
                message "Should we continue?"
                ok "Yes, we should."
            }
             steps {
                sh """
                cd 01-vpc
                terraform apply -auto-approve
                """
            }
        }

        stage('Destroy') {
            // if we want to proceed to next stage based on previous stage 
            input {
                message "Should we continue?"
                ok "Yes, we should."
            }
             steps {
                sh """
                cd 01-vpc
                terraform destroy -auto-approve
                """
            }
        }
    }


    post { 
        always { 
            echo 'I will always say Hello again!'
            deleteDir()
        }
        success { 
            echo 'I will run when pipeline is success'
        }
        failure { 
            echo 'I will run when pipeline is failure'
        }
    }
}