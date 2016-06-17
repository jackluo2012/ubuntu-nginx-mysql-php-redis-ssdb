#!/usr/bin/env bash

docker stop $(docker ps -a)
docker rm $(docker ps -a)
docker build -t jackluo/ngt .
docker run -d --name ng -p 80:80 -p 3306:3306 jackluo/ngt
docker exec -it ng /bin/bash
