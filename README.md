# aws-jenkins-deploy
Repository that contains the code to deploy Docker services on an EC2 instance

## Getting Started
Just clone the project and execute the ansible-playbook command

### Prerequisites
To execute the deployment you need to have Ansible installed and configure the AWS credentials

## Copy templates to S3 Bucket
To copy the templates to an s3 bucket
```
aws s3 cp ./cloudformation_templates <s3_bucket> --recursive --exclude "*" --include "*.json"
```

## Copy shell scripts to S3 Bucket
To copy the shell scripts to an s3 bucket
```
aws s3 cp ./shells <s3_bucket> --recursive --exclude "*" --include "*.sh"
```

## Running the playbook
Just execute the following command
```
ansible-playbook deploy-service-to-aws.yml --extra-vars "service=jenkins name=root"
```

### Current suported services
- jenkins
- tomcat
- weblogic