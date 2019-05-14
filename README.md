# aws-jenkins-deploy
Repository that contains the code to deploy Jenkins on EC2

## Getting Started
Just clone the project and execute the ./run.sh script

### Prerequisites
- Ansible installed
- AWS credentials configured
- S3 bucket permisions to upload and dowload files
- Key pair must exist

## Playbook Parameters
Just execute the following command
```
ansible-playbook deploy-service-to-aws.yml --extra-vars "service_name=<val_1> branch_name=<val_2> cf_bucket=<val_3> sh_bucket=<val_4> pem_bucket=<val_5>"
```