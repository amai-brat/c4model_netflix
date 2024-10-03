#!/bin/sh

docker run -it --rm -p 8080:8080 -v /home/roflan/codes/ucheba/dotnet/course3/structurizr:/usr/local/structurizr --user 1000:1000 structurizr/lite
