#!/bin/bash -e

# Attributes
BRANCH_NAME='master'
COMMIT_HASH=''
SERVICE_NAME='jenkins'
CFT_BUCKET='ae-cloudformation-templates'
SH_BUCKET='ae-shell-scripts'
PEM_BUCKET='ae-key-pairs'

# $1 = Branch name
checkout() {
    git pull
    git checkout $1
    COMMIT_HASH=$(git rev-parse --verify HEAD)
}

# $1 = S3 bucket
# $2 = Local folder
# $3 = Display name
synch_files() {
    echo "Sync $3 with S3 bucket"
    aws s3 sync $2 s3://$1/

    echo "Grant public access to $3"
    for file in $2/* 
    do
        aws s3api put-object-acl --bucket $1 --key $(basename $file) --acl public-read
    done
}

run_playbook(){
    ansible-playbook deploy-service.yml --extra-vars "service_name=$1 branch_name=$2 commit_hash=$3 cf_bucket=$4 sh_bucket=$5"
}

# $1 = S3 bucket
# $2 = Local folder
download_pems(){
    mkdir -p -m 777 $2
    aws s3 sync s3://$1 $2
    find . -name '*.pem' -exec chmod 400 {} \;
}

clean_environment(){
    rm -rf $1
}

# Body
checkout $BRANCH_NAME
synch_files $CFT_BUCKET "cloudformation_templates" "cloudformation templates"
synch_files $SH_BUCKET "shells" "shell scripts"
run_playbook $SERVICE_NAME $BRANCH_NAME $COMMIT_HASH $CFT_BUCKET $SH_BUCKET
download_pems $PEM_BUCKET "key_pairs"
clean_environment "key_pairs"