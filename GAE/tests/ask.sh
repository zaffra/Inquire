#!/bin/bash

curl -b /tmp/session -X POST -d"question=This is my question" -d"latitude=0" -d"longitude=0" 'http://localhost:8080/api/ask'
echo ""
