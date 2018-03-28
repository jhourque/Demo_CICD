#!/bin/bash

cd ../terraform
URL=$(terraform output jenkins_url)
cd -

if [ ! -f jenkins-cli.jar ]
then
        wget $URL/jnlpJars/jenkins-cli.jar
fi

java -jar jenkins-cli.jar -s $URL -ssh -user admin -i ~/.ssh/id_rsa.jenkins -p 50022 list-jobs

java -jar jenkins-cli.jar -s $URL -ssh -user admin -i ~/.ssh/id_rsa.jenkins -p 50022 get-job Dev_pipeline > Dev_pipeline.xml
java -jar jenkins-cli.jar -s $URL -ssh -user admin -i ~/.ssh/id_rsa.jenkins -p 50022 get-job Prod_pipeline > Prod_pipeline.xml
