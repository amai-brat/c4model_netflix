#!/bin/sh

docker run -it --rm -p 8080:8080 -v ./:/usr/local/structurizr --user 1000:1000 structurizr/lite
