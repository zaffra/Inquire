#!/bin/bash

if [ -z "$1" ]
then
    echo "question_id = arg 1"
    exit 1
fi

curl -b /tmp/session 'http://localhost:8080/api/answers?question_id='$1
echo ""
