#!/usr/bin/env bash

mkdir -vp  test/{data,log,www,config}
touch test/config/www.conf
default=`cat << EOF
server { \n
    listen 80;\n
    server_name localhost; \n
\n
    root /data/www/BotoStar/cms;\n
    index index.html index.htm index.php;\n
\n
    location / {\n
        try_files $uri $uri/ /index.php;\n
    }\n
\n
    location ~ \.php$ {\n
        try_files $uri =404;\n
\n
	fastcgi_pass unix:/var/run/php-fpm.sock;\n
        include fastcgi_params;\n
        fastcgi_param  SCRIPT_FILENAME $document_root/index.php;\n
    }\n
    location ~* \.(jpg|jpeg|gif|png|css|js|ico|xml)$ {\n
        access_log        off;\n
        log_not_found     off;\n
        expires           5d;\n
    }\n
    error_log /data/log/err.log;\n
    access_log /data/log/acc.log;\n
    # deny access to . files, for security\n
    #\n
    location ~ /\. {\n
            access_log off;\n
            log_not_found off; \n
            deny all;\n
    }\n
}\n
EOF
`
echo $default > test/config/www.conf




