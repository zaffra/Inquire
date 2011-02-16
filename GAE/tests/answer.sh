#!/bin/bash

if [ -z "$1" ]
then
    echo "First arg = question_id"
    exit 1
fi

curl -b /tmp/session -X POST -d"question_id=$1" -d"answer=This is my answer." -d"latitude=0" -d"longitude=0" 'http://localhost:8080/api/answer'
echo ""
