#!/bin/bash

email="abe@zaffra.com"
if [ -n "$1" ]; then
    email=$1
fi

curl -d"email=$email" -d"password=password" 'http://localhost:8080/api/register'
echo ""
