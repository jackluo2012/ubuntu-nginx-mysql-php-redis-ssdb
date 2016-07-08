#!/usr/bin/env bash

if [ $# != 1 ] ; then 
echo " 请输入一个创建的网站目录" 
exit 1; 
fi 
webdir=$1

#mkdir -vp  test/{data,log,www,config}
mkdir -p $webdir/log
mkdir -p $webdir/www
mkdir -p $webdir/config
mkdir -p $webdir/data
touch $webdir/config/www.conf

echo "网站配置文件创建中..."

echo 'server {\n' >> $webdir/config/www.conf
echo '\t    listen 80 default_server;\n' >> $webdir/config/www.conf
echo '\t    listen [::]:80 default_server ipv6only=on;\n' >> $webdir/config/www.conf
echo '\t    root /var/multrix;\n' >> $webdir/config/www.conf
echo '\t    index index.html index.htm index.php;\n' >> $webdir/config/www.conf
echo '\t    # Make site accessible from http://localhost/' >> $webdir/config/www.conf
echo '\t    server_name localhost;\n' >> $webdir/config/www.conf
echo '\t    location / {\n' >> $webdir/config/www.conf
echo '\t        # 如果找不到真实存在的文件，把请求分发至 index.php' >> $webdir/config/www.conf
echo '\t\t        try_files $uri $uri/ /index.php?$args;\n' >> $webdir/config/www.conf
echo '\t    }\n' >> $webdir/config/www.conf
echo '\t    # PHP\n' >> $webdir/config/www.conf
echo '\t    location ~ \.php$ {\n' >> $webdir/config/www.conf
echo '\t        fastcgi_buffer_size 128k;\n' >> $webdir/config/www.conf
echo '\t        fastcgi_buffers 32 32k;\n' >> $webdir/config/www.conf
echo '\t        try_files $uri =404;\n' >> $webdir/config/www.conf
echo '\t        fastcgi_pass   unix:/var/run/php5-fpm.sock;\n' >> $webdir/config/www.conf
echo '\t        fastcgi_index  index.php;\n' >> $webdir/config/www.conf
echo '\t        fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;\n' >> $webdir/config/www.conf
echo '\t        fastcgi_param PATH_INFO $fastcgi_script_name;\n' >> $webdir/config/www.conf
echo '\t        include fastcgi_params;\n' >> $webdir/config/www.conf
echo '\t    	}\n' >> $webdir/config/www.conf
echo '}\n' >> $webdir/config/www.conf

touch $webdir/www/index.php
echo "网站配置文件创建完成..."
echo "<?php echo phpinfo(); ?>" > $webdir/www/index.php

echo "生成启动脚本..."
starbs=`cat << EOF
#!/usr/bin/env bash \n
docker stop $(docker ps -a) \n
docker rm $(docker ps -a)\n
docker run -d --name ng -v $(pwd)/www:/var/multrix -v $(pwd)/config:/etc/nginx/sites-enabled -v $(pwd)/data:/var/lib/mysql -p 3306:3306  -p 80:80 jackluo/ng \n
docker exec -it ng /bin/bash \n
\n
EOF
`
touch $webdir/start.sh
echo '#!/usr/bin/env bash \n' > $webdir/start.sh
echo 'docker stop $(docker ps -a) \n' >> $webdir/start.sh
echo 'docker rm $(docker ps -a)\n' >>  $webdir/start.sh
echo 'docker run -d --name ng -v $(pwd)/www:/var/multrix -v $(pwd)/config:/etc/nginx/sites-enabled -v $(pwd)/data:/var/lib/mysql -p 3306:3306  -p 80:80 jackluo/ng \n' >> $webdir/start.sh
echo 'docker exec -it ng /bin/bash \n' >> $webdir/start.sh

echo "生成启动脚本完成..."










