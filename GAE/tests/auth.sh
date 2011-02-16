#!/bin/bash

curl -c /tmp/session -d"email=abe@zaffra.com" -d"password=password" 'http://localhost:8080/api/auth'
echo ""
