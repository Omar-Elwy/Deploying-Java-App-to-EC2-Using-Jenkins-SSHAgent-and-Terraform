#!/usr/bin/env groovy

library identifier: 'jenkins-shared-library@master', retriever: modernSCM(
    [$class: 'GitSCMSource',
     remote: 'https://gitlab.com/nanuchi/jenkins-shared-library.git',
     credentialsId: 'gitlab-credentials'
    ]
)
pipeline {
    agent any
    tools {
        maven 'Maven'
    }
    environment {
        IMAGE_NAME = 'nanajanashia/demo-app:java-maven-2.0'
    }
    stages {
        stage('build app') {
            steps {
               script {
                  echo 'building application jar...'
                  buildJar()
               }
            }
        }
        stage('build image') {
            steps {
                script {
                   echo 'building docker image...'
                   buildImage(env.IMAGE_NAME)

                   // dockerlogin on jenkins to push image to docker private repo
                   dockerLogin()
                   dockerPush(env.IMAGE_NAME)
                }
            }
        }
        stage('provision server') {
            environment {

                /*credentils that we already created on jenkins UI from AWS*/
                /* Terraform Provider needs them to be able to connect to AWS
                and create the EC2 instance*/
                AWS_ACCESS_KEY_ID = credentials('jenkins_aws_access_key_id')
                AWS_SECRET_ACCESS_KEY = credentials('jenkins_aws_secret_access_key')
                // Terrafrom environment variable to override existing default value
                TF_VAR_env_prefix = 'test'
            }
            steps {
                script {
                    dir('terraform') {   // to go to the terraform folder that we created inside the project..
                        sh "terraform init"
                        sh "terraform apply --auto-approve"

                        /* we are putting the value of that output to a jenkins environment variable
                        to keep the EC2 public IP address, as we gonna use it when SSHing
                        to th eserver to opy the files and excute them there*/
                        EC2_PUBLIC_IP = sh(
                            script: "terraform output ec2_public_ip",
                            returnStdout: true  // this print the value to a standardoutput and save it to that variable EC2_PUBLIC_IP## 
                        ).trim() // trim to remove any spaces before or after to get clean text..
                    }
                }
            }
        }
        stage('deploy') {
            
            /* environment variable to read the credentials created
            in jenkins server UI credntials, to be able to use it
            here in jenkins file*/
            /*El line dh hygble el credintials m3 b3d bs brdo autmatically
            befsl el username fe var w el password fe var zy ma hst5dmhm
            t7t delw2te w ana bnade el (server.cmds.sh).....*/
            environment {
                DOCKER_CREDS = credentials('docker-hub-repo')
            }
            steps {
                script {
                   echo "waiting for EC2 server to initialize" 
                   sleep(time: 90, unit: "SECONDS") // server takes time to initialize after TF file got excuted..                

                   echo 'deploying docker image to EC2...'
                   echo "${EC2_PUBLIC_IP}" 
                                	     // homa dl el etcryto automatically mn el env var                          
                   def shellCmd = "bash ./server-cmds.sh ${IMAGE_NAME} ${DOCKER_CREDS_USR} ${DOCKER_CREDS_PSW}"
                   def ec2Instance = "ec2-user@${EC2_PUBLIC_IP}"

                   sshagent(['server-ssh-key']) {
                       sh "scp -o StrictHostKeyChecking=no server-cmds.sh ${ec2Instance}:/home/ec2-user"
                       sh "scp -o StrictHostKeyChecking=no docker-compose.yaml ${ec2Instance}:/home/ec2-user"
                       sh "ssh -o StrictHostKeyChecking=no ${ec2Instance} ${shellCmd}"
                   }
                }
            }
        }
    }
}
