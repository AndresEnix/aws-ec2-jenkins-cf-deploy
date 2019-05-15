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
ansible-playbook deploy-environment.yml --extra-vars "branch_name=$1 commit_hash=$2 cf_bucket=$3"
```