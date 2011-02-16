#!/bin/bash

if [ -z "$1" ]
then
    LAT=37.331693
fi

if [ -z "$2" ]
then
    LON=-122.030457
fi

curl -b /tmp/session 'http://localhost:8080/api/questions?latitude='$LAT'&longitude='$LON
echo ""
