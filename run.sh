#!/bin/bash -e

BRANCH_NAME=''
COMMIT_HASH=''
CFT_BASE_NAME='ae-templates-for'
PEM_BASE_NAME='ae-keys-for'
CFT_BUCKET=''
PEM_BUCKET=''
AWS_REGION='us-east-1'

checkout() {
    BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
    echo "[INFO] Checking out branch '$BRANCH_NAME' in order to obtain the latest changes"
    git checkout $BRANCH_NAME
    git pull
    COMMIT_HASH=$(git rev-parse --verify HEAD)
    CFT_BUCKET="$CFT_BASE_NAME-$BRANCH_NAME-environment"
    PEM_BUCKET="$PEM_BASE_NAME-$BRANCH_NAME-environment"
    echo "[INFO] Check out done"
    echo "[INFO]      BRANCH_NAME : $BRANCH_NAME"
    echo "[INFO]      COMMIT_HASH : $COMMIT_HASH"
    echo "[INFO]      CFT_BUCKET  : $CFT_BUCKET"
    echo "[INFO]      PEM_BUCKET  : $PEM_BUCKET"
}

synch_files() {
    if aws s3 ls "s3://$1" 2>&1 | grep -q 'NoSuchBucket' ;
    then
        echo "[INFO] Creating bucket $1"
        aws s3api create-bucket --bucket $1 --region $AWS_REGION
        echo "[INFO] Enabling versioning configuration for $1 bucket"
        aws s3api put-bucket-versioning --bucket $1 --versioning-configuration Status=Enabled
    fi

    echo "[INFO] Uploading files from '$2' folder to '$1' bucket"
    aws s3 sync $2 s3://$1/

    if $3 ;
    then
        echo "[INFO] Granting public access to objects inside '$1' bucket"
        for file in $2/* 
        do
            aws s3api put-object-acl --bucket $1 --key $(basename $file) --acl public-read
        done
    else
        echo "[INFO] Files inside '$1' bucket don't have public access"
    fi
}

create_environment_key() {
    if aws ec2 describe-key-pairs --key-name "$1" 2>&1 | grep -q 'InvalidKeyPair.NotFound' ;
    then
        echo "[INFO] Creating key '$1' inside '$2' folder"
        mkdir -p -m 777 $2
        aws ec2 create-key-pair --key-name $1 --query 'KeyMaterial' --output text > ./$2/$1.pem
        synch_files $PEM_BUCKET $2 false
        echo "[INFO] Deleting '$2' folder"
        rm -rf $2
    else
        echo "[WARNING] The key '$1' already exist in the AWS account, please verify that it is inside the '$3' bucket"
    fi
}

run_playbook(){
    ansible-playbook build-environment.yml --extra-vars "branch_name=$1 commit_hash=$2 cf_bucket=$3 aws_region=$4"
}

# Body
checkout
synch_files $CFT_BUCKET "cloudformation_templates" true
create_environment_key "$BRANCH_NAME-key" "keys" $PEM_BUCKET
run_playbook $BRANCH_NAME $COMMIT_HASH $CFT_BUCKET $AWS_REGION