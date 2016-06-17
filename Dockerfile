#FROM ubuntu:14.04
FROM jackluo/ubuntu
MAINTAINER jackluo jackluo <net.webjoy@gmail.com>

RUN DEBIAN_FRONTEND=noninteractive

# Update apt-get local index
RUN apt-get -qq update

# Install
RUN apt-get -y --force-yes install wget curl git unzip supervisor g++ make nginx mysql-server mysql-client redis-server php5-cli php5-fpm php5-dev php5-mysql php5-curl php5-intl php5-mcrypt php5-memcache php5-imap php5-sqlite php5-gd libfreetype6 libfreetype6-dev libssl-dev openssl php5-imagick php5-mongo 



RUN bash -c "wget http://getcomposer.org/composer.phar && mv composer.phar /usr/local/bin/composer && chmod +x /usr/local/bin/composer"

# PHP Redis
RUN mkdir -p /tmp/php-redis
WORKDIR /tmp/php-redis
RUN wget https://github.com/phpredis/phpredis/archive/2.2.5.zip; unzip 2.2.5.zip
WORKDIR /tmp/php-redis/phpredis-2.2.5
RUN /usr/bin/phpize; ./configure; make; make install
RUN echo "extension=redis.so" > /etc/php5/mods-available/redis.ini
RUN php5enmod redis

RUN mkdir -p /tmp/ssdb
WORKDIR /tmp/ssdb
COPY ssdb-master.zip /tmp/ssdb/
RUN unzip ssdb-master.zip
WORKDIR /tmp/ssdb/ssdb-master
RUN make
RUN sudo make install

# SSDB conf
RUN sed -i -e"s/127.0.0.1/0.0.0.0/" /usr/local/ssdb/ssdb.conf
RUN sudo rm -rf /tmp/*

# Redis conf
RUN sed -i -e"s/^bind\s*127.0.0.1/bind 0.0.0.0/" /etc/redis/redis.conf


# MySQL conf             = 
RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf
RUN sed -i -e"s/^user\s*=\s*mysql/user = root/" /etc/mysql/my.cnf
# PHP conf
RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php5/fpm/php.ini
RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php5/cli/php.ini
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/fpm/php.ini
RUN sed -i "s/;daemonize = yes/daemonize = no/" /etc/php5/fpm/php-fpm.conf
ENV DATA_DIR /var/lib/mysql

# nginx conf
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf

ADD files/default /etc/nginx/sites-available/default
ADD files/supervisord.conf /etc/supervisor/supervisord.conf
ADD files/php-fpm.conf /etc/php5/fpm/php-fpm.conf
ADD files/start.sh /usr/local/bin/start.sh
#mysql 
ADD files/mysql.sh /usr/local/bin/mysql.sh
RUN mkdir -p /tmp/node
WORKDIR /var/multrix
#RUN chown www-data:www-data /var/multrix
RUN sed -i -e"s/^user\s*www-data/user root/" /etc/nginx/nginx.conf
RUN service mysql start && service redis-server start && mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'admin'"

# Volumes
VOLUME /var/multrix
VOLUME /etc/nginx/sites-enabled
VOLUME /var/lib/mysql
VOLUME /var/log/

# Expose ports
EXPOSE 80
EXPOSE 3306
EXPOSE 443

# Default command for container, start supervisor
CMD ["supervisord", "--nodaemon"]
#CMD ["sudo","/usr/local/ssdb/ssdb-server","-d","/usr/local/ssdb/ssdb.conf"]
#CMD ["service", "mysql", "start"]
#CMD ["service", "redis-server", "start"]
#CMD ["service", "php5-fpm", "start"]
#CMD ["service", "nginx", "start"]
#CMD ["sudo","/bin/bash","/usr/local/bin/start.sh"]
