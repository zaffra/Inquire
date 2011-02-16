#!/bin/bash

if [ -z "$1" ]
then
    echo "First arg = answer_id"
    exit 1
fi

curl -b /tmp/session -X POST -d"answer_id=$1" 'http://localhost:8080/api/accept'
echo ""
