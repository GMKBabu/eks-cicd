/*
    This is an example pipeline that implement full CI/CD for a simple static web site packed in a Docker image.
    The pipeline is made up of 6 main steps
    1. Git clone and setup
    2. Build and local tests
    3. Publish Docker and Helm
    4. Deploy to dev and test
    5. Deploy to staging and test
    6. Optionally deploy to production and test
	usermod -aG docker jenkins
    usermod -aG root jenkins
	chmod 664 /var/run/docker.sock
But none of them work for me, I tried:

chmod 777 /var/run/docker.sock
 */

pipeline {
    // In this example, all is built and run from the master
	agent any

    environment {
        GITHUB_URL = "https://github.com/GMKBabu/eks-cicd.git"
        GITHUB_CREDENTIALS_ID = "0b61464e-dd11-4760-b30a-f988490eb429"
        GITHUB_BRANCH_NAME = 'master'
        CUSTOM_TAG = $(date)
        AWS_DEFAULT_REGION = 'us-east-1'
        AWS_ACCOUNT_ID = "504263020452"
        IMAGE_REPO_NAME = "eks"
        TEST_LOCAL_PORT = "80"
		CUSTOM_BUILD_NUMBER = "DEV-PRD-${BUILD_NUMBER}"
		ID = "${IMAGE_REPO_NAME}"
		IMAGE_NAME = "${IMAGE_REPO_NAME}:${CUSTOM_TAG}"
    }
    triggers {
    //Run Polling of GitHub every minute everyday of the week
        pollSCM ('* * * * *')
        //cron ('0 0 * * 1-5')}
    // Pipeline stages
    }
    options {
	    buildDiscarder(logRotator(numToKeepStr: '5', artifactDaysToKeepStr: '3', artifactNumToKeepStr: '1'))
        timeout(time: 60, unit: 'MINUTES')
    }
    stages {
             stage("GITHUB_code_checkout") {
        steps {
		   // using for checkout the code from github
		 checkout([$class: 'GitSCM', branches: [[name: "*/${GITHUB_BRANCH_NAME}"]],doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], \
	       userRemoteConfigs: [[credentialsId: "${GITHUB_CREDENTIALS_ID}", url: "${GITHUB_URL}"]]])
	   script {
	       currentBuild.displayName = "${CUSTOM_BUILD_NUMBER}"
	     }
        }
        }
        ////////// Step 2 //////////
        stage('Build Docker Image and Test') {
            steps {
                echo "Building application and Docker image"
                sh "docker build -t $IMAGE_NAME  ${WORKSPACE}/."

                echo "Running Test"

                // Kill container in case there is a leftover
                sh "[ -z \"\$(docker ps -a | grep ${ID} 2>/dev/null)\" ] || docker rm -f ${ID}"

                echo "Starting ${IMAGE_REPO_NAME} container"
                sh "docker run --detach --name ${ID} --rm --publish ${TEST_LOCAL_PORT}:80 ${IMAGE_NAME}"


            }
        }

        // Run the 3 tests on the currently running ACME Docker container
        stage('Local tests') {
            steps {
			    sh '''
				    host_ip=$(hostname -i)
				    curl -aG http://$host_ip:80
				'''
                        
                }
        }
        ////////// Step 3 //////////
		
        stage("Publish Docker Image") {
            steps {
                sh "echo Stop and remove container"
                sh 'docker stop "${ID}"'
				sh "echo login to ecr repository"
				sh '(eval \$(aws ecr get-login  --no-include-email --region "${AWS_DEFAULT_REGION}"))'
				sh 'echo Pushing "${IMAGE_NAME}" image to registry'
				sh "echo change the docker image tag name"
				sh 'docker tag "${IMAGE_NAME}" "${AWS_ACCOUNT_ID}".dkr.ecr."${AWS_DEFAULT_REGION}".amazonaws.com/"${IMAGE_NAME}"'
                sh "echo Pushing the Docker image...  "
				sh 'docker push "${AWS_ACCOUNT_ID}".dkr.ecr."${AWS_DEFAULT_REGION}".amazonaws.com/"${IMAGE_NAME}"'
            }
        }
    }
}
