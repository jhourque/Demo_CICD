cd ../terraform
URL=$(terraform output jenkins_url)
cd -

if [ ! -f jenkins-cli.jar ]
then
        wget $URL/jnlpJars/jenkins-cli.jar
fi

java -jar jenkins-cli.jar -s $URL -ssh -user admin -i ~/.ssh/id_rsa.jenkins -p 50022 get-credentials-as-xml system::system::jenkins "(global)" aws_creds > aws_creds.xml
