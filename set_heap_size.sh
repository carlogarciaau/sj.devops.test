#!/bin/bash

HEAP_SIZE=$1
REQUESTS_LIMITS=$2

docker build --build-arg HEAP_SIZE=${HEAP_SIZE} -t devops:test
sed -i "s/\{\{MEMORY\}\}/${REQUESTS_LIMITS}/g" ../hello-world-deploy.yaml
kubectl apply -f ../hello-world-deploy.yaml

