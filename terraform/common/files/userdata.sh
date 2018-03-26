#!/bin/bash

sudo apt-get update

sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update

sudo apt-get install -y --allow-unauthenticated docker-ce

sudo usermod -aG docker ubuntu

#sudo apt-get install -y mysql-client

sudo apt-get install -y awscli

eval $(aws ecr get-login --region=${REGION}|sed 's/-e none//')

rm -rf /tmp/application.properties
echo "ddbtable=${TABLE}" > /tmp/application.properties
echo "region=${REGION}" >> /tmp/application.properties

docker run -d -p 8080:80 -v /tmp/application.properties:/var/www/html/application.properties ${REPO}
