#!/bin/bash -e

BRANCH_NAME=''
COMMIT_HASH=''
CFT_BUCKET=''

checkout() {
    git pull
    git checkout $1
    BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
    COMMIT_HASH=$(git rev-parse --verify HEAD)
    CFT_BUCKET="ae-$BRANCH_NAME-environment-templates"
}

synch_files() {
    if aws s3 ls "s3://$1" 2>&1 | grep -q 'NoSuchBucket' ;
    then
        echo "Creating $1 bucket with versioning configuration enabled"
        aws s3api create-bucket --bucket $1 --region us-east-1
        aws s3api put-bucket-versioning --bucket $1 --versioning-configuration Status=Enabled
    fi

    echo "Uploading $3 to $1 bucket"
    aws s3 sync $2 s3://$1/

    echo "Grant public access to templates inside $3 bucket"
    for file in $2/* 
    do
        aws s3api put-object-acl --bucket $1 --key $(basename $file) --acl public-read
    done
}

run_playbook(){
    ansible-playbook deploy-environment.yml --extra-vars "branch_name=$1 commit_hash=$2 cf_bucket=$3"
}

# Body
checkout $BRANCH_NAME
synch_files $CFT_BUCKET "cloudformation_templates" "cloudformation templates"
run_playbook $BRANCH_NAME $COMMIT_HASH $CFT_BUCKET