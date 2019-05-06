#!/bin/bash -xe
# Install Docker
sudo yum update -y
sudo amazon-linux-extras install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user
su - $USER

# Login to a docker account
docker login -u <user> -p <password>

# Install weblogic
docker pull store/oracle/weblogic:12.2.1.3
touch domain.properties
echo "username=myadminusername" >> domain.properties
echo "password=W3bl0g1c_P4ssW0rd" >> domain.properties
docker run -d -p 7001:7001 -p 9002:9002  -v $PWD:/u01/oracle/properties store/oracle/weblogic:12.2.1.3
logout

#Weblogic URL https://localhost:9002/console/login/LoginForm.jsp