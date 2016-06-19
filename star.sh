#!/usr/bin/env bash

docker stop $(docker ps -a)
docker rm $(docker ps -a)
docker build -t jackluo/ngt .
docker run -d --privileged=true --name ng -p 80:80 -v $(pwd)/www:/var/multrix -v $(pwd)/config:/etc/nginx/sites-enabled -v $(pwd)/data:/var/lib/mysql -v $(pwd)/log:/var/log -p 3306:3306 jackluo/ngt
docker exec -it ng /bin/bash
