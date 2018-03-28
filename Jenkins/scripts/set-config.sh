#!/bin/bash

URL=http://127.0.0.1:8080

cd ../terraform
JENKINS_IP=$(terraform output jenkins_ip)
JENKINS_URL=$(terraform output jenkins_url)
cd -

if [ ! -f jenkins-cli.jar ]
then 
	wget $JENKINS_URL/jnlpJars/jenkins-cli.jar
fi

SSH_PUB=$(cat ~/.ssh/id_rsa.jenkins.pub)

# Inject ssh public key in groovy script
cat admin.groovy.skel | sed "s#SSH_PUB#$SSH_PUB#" > admin.groovy

# Upload script on Jenkins VM
scp -i ~/.ssh/id_rsa.jenkins admin.groovy jenkins-cli.jar ~/.ssh/id_rsa.demo ubuntu@$JENKINS_IP:

# upload id_rsa.demo key to /var/lib/jenkins/.ssh
ssh -i ~/.ssh/id_rsa.jenkins ubuntu@$JENKINS_IP "sudo mkdir /var/lib/jenkins/.ssh"
ssh -i ~/.ssh/id_rsa.jenkins ubuntu@$JENKINS_IP "sudo mv /home/ubuntu/id_rsa.demo /var/lib/jenkins/.ssh"
ssh -i ~/.ssh/id_rsa.jenkins ubuntu@$JENKINS_IP "sudo chown -R jenkins:jenkins /var/lib/jenkins/.ssh"

# Run groovy script (create admin account & set security)
ssh -i ~/.ssh/id_rsa.jenkins ubuntu@$JENKINS_IP "cat admin.groovy  | java -jar jenkins-cli.jar -s $URL groovy ="

# Create aws_creds (from AWS_ACCESS_KEY_ID & AWS_SECRET_ACCESS_KEY env vars)
cat XML/aws_creds.xml  |sed "s/AWS_ACCESS_KEY_ID/$AWS_ACCESS_KEY_ID/" |sed "s AWS_SECRET_ACCESS_KEY $AWS_SECRET_ACCESS_KEY " | java -jar jenkins-cli.jar -s $JENKINS_URL -ssh -user admin -i ~/.ssh/id_rsa.jenkins -p 50022 create-credentials-by-xml system::system::jenkins "(global)"

# Create Dev & Prod Pipelines
cat XML/Dev_pipeline.xml |java -jar jenkins-cli.jar -s $JENKINS_URL -ssh -user admin -i ~/.ssh/id_rsa.jenkins -p 50022 create-job Dev_pipeline
cat XML/Prod_pipeline.xml |java -jar jenkins-cli.jar -s $JENKINS_URL -ssh -user admin -i ~/.ssh/id_rsa.jenkins -p 50022 create-job Prod_pipeline


