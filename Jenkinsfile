/*
    This is an example pipeline that implement full CI/CD for a simple static web site packed in a Docker image.
    The pipeline is made up of 6 main steps
    1. Git clone and setup
    2. Build and local tests
    3. Publish Docker and Helm
    4. Deploy to dev and test
    5. Deploy to staging and test
    6. Optionally deploy to production and test
 */

pipeline {
    // In this example, all is built and run from the master
    options {
        timeout(time: 60, unit: 'MINUTES')
    }
    environment {
        GITHUB_URL = "https://github.com/GMKBabu/eks-cicd.git"
        GITHUB_CREDENTIALS_ID = "0b61464e-dd11-4760-b30a-f988490eb429"
        GITHUB_BRANCH_NAME = 'master'
        CUSTOM_TAG = $(date)
        AWS_DEFAULT_REGION = 'us-east-1'
        AWS_ACCOUNT_ID = "504263020452"
        IMAGE_REPO_NAME = "eks"
        TEST_LOCAL_PORT = "80"
    }
    triggers {
    //Run Polling of GitHub every minute everyday of the week
        pollSCM ('* * * * *')
        //cron ('0 0 * * 1-5')}
    // Pipeline stages
    }
    agent any
    stages {
        ////////// Step 1 //////////
        stage('Git Code Checkout') {
            steps {
                echo "Check out gic code"
                git branch: ${GITHUB_BRANCH_NAME},
                        credentialsId: ${GITHUB_CREDENTIALS_ID},
                        url: ${GITHUB_URL}
                //// Validate kubectl
                sh "kubectl cluster-info"



                // Define a unique name for the tests container and helm release
                script {
                    ID = "${IMAGE_REPO_NAME}:${CUSTOM_TAG}"
                    echo "Global ID set to ${ID}"
                }
            }
        }
        ////////// Step 2 //////////
        stage('Build Docker Image and Test') {
            steps {
                echo "Building application and Docker image"
                sh "docker build -t $ID  ${WORKSPACE}/Dockerfile"

                echo "Running Test"

                // Kill container in case there is a leftover
                sh "[ -z \"\$(docker ps -a | grep ${ID} 2>/dev/null)\" ] || docker rm -f ${ID}"

                echo "Starting ${IMAGE_REPO_NAME} container"
                sh "docker run --detach --name ${ID} --rm --publish ${TEST_LOCAL_PORT}:80 ${id}"

                script {
                    host_ip = sh(returnStdout: true, script: '/sbin/ip route | awk \'/default/ { print $3 ":${TEST_LOCAL_PORT}" }\'')
                }

            }
        }
        
        // Run the 3 tests on the currently running ACME Docker container
        stage('Local tests') {
            parallel {
                stage('Curl http_code') {
                    steps {
                        curlRun ("http://${host_ip}", 'http_code')
                    }
                }
                stage('Curl total_time') {
                    steps {
                        curlRun ("http://${host_ip}", 'total_time')
                    }
                }
                stage('Curl size_download') {
                    steps {
                        curlRun ("http://${host_ip}", 'size_download')
                    }
                }
            }
        }
        ////////// Step 3 //////////
        stage("Publish Docker Image") {
            steps {
                echo "Stop and remove container"
                sh "docker stop ${ID}"
                
                echo "Pushing ${ID} image to registry"
                script {
                    echo "login to ecr repository"
                    sh "$(aws ecr get-login --no-include-email --region ${AWS_DEFAULT_REGION})"
                    
                    echo "change the docker image tag name"
                    sh "docker tag ${ID} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ID}"

                    echo "Pushing the Docker image...  "
                    sh "docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ID}"
                }
            }
        }
    }
}
