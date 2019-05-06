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
docker pull jenkins
docker run -d -p 8080:8080 -p 50000:50000 -v $PWD/var/jenkins_home jenkins
logout

#Weblogic URL http://localhost:8080