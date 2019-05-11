#!/bin/bash -e

# Attributes
BRANCH_NAME='master'
SERVICE_NAME='jenkins'
CFT_BUCKET='ae-cloudformation-templates'
SH_BUCKET='ae-shell-scripts'

# Functions
checkout() {
    echo "Checkout $1 branch from git repo"
    git pull
}

synch_files() {
    BUCKET=$1
    LOCAL_FOLDER=$2
    MESSAGE=$3
    echo "Sync $MESSAGE with S3 bucket"
    aws s3 sync $LOCAL_FOLDER s3://$BUCKET/

    echo "Grant public access to $MESSAGE"
    for file in $LOCAL_FOLDER/* 
    do
        aws s3api put-object-acl --bucket $BUCKET --key $(basename $file) --acl public-read
    done
}

run_playbook(){
    ansible-playbook deploy-service-to-aws.yml --extra-vars "service_name=$1 branch_name=$2 cf_bucket=$3 sh_bucket=$4"
}

# Body
checkout $BRANCH_NAME
synch_files $CFT_BUCKET "cloudformation_templates" "cloudformation templates"
synch_files $SH_BUCKET "shells" "shell scripts"
run_playbook $SERVICE_NAME $BRANCH_NAME $CFT_BUCKET $SH_BUCKET