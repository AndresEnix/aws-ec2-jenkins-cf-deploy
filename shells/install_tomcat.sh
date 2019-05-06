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
docker pull tomcat
docker run -d -it --rm -p 8080:8080 tomcat:8.0
logout

#Weblogic URL http://localhost:8080