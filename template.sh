#!/usr/bin/env bash

#mkdir -vp  test/{data,log,www,config}
mkdir -p test/log
mkdir -p test/www
mkdir -p test/config
mkdir -p test/data
touch test/config/www.conf
default=`cat << EOF
server {\n
\t    listen 80 default_server;\n
\t    listen [::]:80 default_server ipv6only=on;\n
\n
\t    root /var/multrix;\n
\t    index index.html index.htm index.php;\n
\n
\t    # Make site accessible from http://localhost/
\t    server_name localhost;\n
\n
\t    location / {\n
\t        # 如果找不到真实存在的文件，把请求分发至 index.php
\t\t        try_files $uri $uri/ /index.php?$args;\n
\t    }\n
\n
\t    # PHP\n
\t    location ~ \.php$ {\n
\t        fastcgi_buffer_size 128k;\n
\t        fastcgi_buffers 32 32k;\n
\t        try_files $uri =404;\n
\t        fastcgi_pass   unix:/var/run/php5-fpm.sock;\n
\t        fastcgi_index  index.php;\n
\t        fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;\n
\t        fastcgi_param PATH_INFO $fastcgi_script_name;\n
\t        include fastcgi_params;\n
\t    }\n
\n
}\n
\n
EOF
`
echo $default > test/config/www.conf
touch test/www/index.php
echo "<?php echo phpinfo(); ?>" > test/www/index.php




