#!/usr/bin/env bash

set -e

JQ="jq --raw-output --exit-status"

configure_aws_cli(){
    aws --version
    aws configure set default.region us-east-1
    aws configure set default.output json
}

deploy_image() {
    # get the authorization code and login to aws ecr
    eval $(aws ecr get-login --region us-east-1)
    docker push $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/reversible:$CIRCLE_SHA1
}

make_task_def(){
    task_template='[
        {
            "name": "reversible-app",
            "image": "%s.dkr.ecr.us-east-1.amazonaws.com/reversible:%s",
            "essential": true,
            "memory": 300,
            "cpu": 1,
            "portMappings": [
                {
                    "containerPort": "80",
                    "hostPort": "80",
                    "protocol": "tcp"
                }
            ]
        }
    ]'
    
    task_def=$(printf "$task_template" $AWS_ACCOUNT_ID $CIRCLE_SHA1)
}

register_definition() {

    if revision=$(aws ecs register-task-definition --cli-input-json "$task_def" --family $family | $JQ '.taskDefinition.taskDefinitionArn'); then
        echo "Revision: $revision"
    else
        echo "Failed to register task definition"
        return 1
    fi

}

deploy_cluster() {
    
    
    make_task_def
    register_definition
    

    if [[ $(aws ecs update-service --cluster $cluster_name --service $service_name --task-definition $revision | \
                   $JQ '.service.taskDefinition') != $revision ]]; then
        echo "Error updating service."
        return 1
    fi

    for attempt in {1..30}; do
        if stale=$(aws ecs describe-services --cluster $cluster_name --services $service_name | \
                       $JQ ".services[0].deployments | .[] | select(.taskDefinition != \"$revision\") | .taskDefinition"); then
            echo "Waiting for stale deployments:"
            echo "$stale"
            sleep 5
        else
            echo "Deployed!"
            return 0
        fi
    done
    echo "Service update took too long."
    return 1

}

family=reversible-task-family
service_name=reversible-service
cluster_name=reversible-cluster

configure_aws_cli
deploy_image
deploy_cluster