
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
                ls -l
                cd 01-vpc
                terraform init -reconfigure
                """
            }
        }
        stage('plan') {
            when {
                expression{
                    params.action == 'Apply'
                }
            }
            steps {
                sh """
                cd 01-vpc
                terraform plan
                """
            }
        }
        stage('Deploy') {
            //using when condition we can control the execution of stages in pipeline
            when {
                expression{
                    params.action == 'Apply'
                }
            }
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
             when {
                expression{
                    params.action == 'Destroy'
                }
            }
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