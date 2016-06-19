#!/usr/bin/env bash

docker stop $(docker ps -a)
docker rm $(docker ps -a)
docker build -t jackluo/ngt .
docker run -d --privileged=true --name ng -p 80:80 -v $(pwd)/test/www:/var/multrix -v $(pwd)/test/config:/etc/nginx/sites-enabled -v $(pwd)/test/data:/var/lib/mysql -p 3306:3306 jackluo/ngt
docker exec -it ng /bin/bash
