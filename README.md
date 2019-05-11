# aws-jenkins-deploy
Repository that contains the code to deploy Jenkins on EC2

## Getting Started
Just clone the project and execute the ./run.sh script

### Prerequisites
To execute the deployment you need to have Ansible installed and configure the AWS credentials

## Playbook Parameters
Just execute the following command
```
ansible-playbook deploy-service-to-aws.yml --extra-vars "service_name=<val_1> branch_name=<val_2> cf_bucket=<val_3> sh_bucket=<val_4>"
```