#!/bin/bash

service redis-server start
service mysql start
service php5-fpm start
service nginx start
#/usr/local/ssdb/ssdb-server -d /usr/local/ssdb/ssdb.conf