#!/usr/bin/env bash

set -e

#
# When Startup Container script
#
DB_USER=${DB_USER:-root}
DB_PASS=${DB_PASS:-admin}

MARIADB_NEW=true
#
#  MariaDB setup
#
firstrun_maria() {

	# First install mariadb
	if [[ ! -d ${DATA_DIR}/mysql ]]; then
	    echo "===> MariaDB not install..."

        echo "===> Initializing maria database... "
	   	mysql_install_db --user=root --ldata=${DATA_DIR}
        echo "===> System databases initialized..."

	   	# Start mariadb
        /usr/bin/mysqld_safe --user root > /dev/null 2>&1 &
        #/etc/init.d/mysql start 
        echo "===> Waiting for MariaDB to start..."

		STA=1
		while [[ STA -ne 0 ]]; do
            printf "."
			sleep 5
			mysql -uroot -e "status" > /dev/null 2>&1
			STA=$?
		done
        echo "===> Start OK..."

		# 1. Create a localhost-only admin account
		mysql -e "CREATE USER '$DB_USER'@'%' IDENTIFIED BY '$DB_PASS'"
		mysql -e "CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS'"
		mysql -e "CREATE USER '$DB_USER'@'127.0.0.1' IDENTIFIED BY '$DB_PASS'"
		mysql -e "GRANT ALL PRIVILEGES ON *.* TO '$DB_USER'@'%' WITH GRANT OPTION "
		mysql -e "GRANT ALL PRIVILEGES ON *.* TO '$DB_USER'@'%' IDENTIFIED BY '$DB_PASS'"
        echo "===> Create localhost completed..."

		# shutdown mariadb to wait for supervisor
		mysqladmin -u root shutdown

	else
        if [[ -e ${DATA_DIR}/mysql.sock ]]; then
            rm -f ${DATA_DIR}/mysql.sock
        fi

        MARIADB_NEW=false

	   	echo "===> Using an existing volume of MariaDB"
	fi
}


if [[ ! -e ${DATA_DIR}/firstrun ]]; then
	# config mariadb
	firstrun_maria
    touch ${DATA_DIR}/firstrun
else
	# Cleanup previous mariadb sockets
	if [[ -e ${DATA_DIR}/mysql.sock ]]; then
		rm -f ${DATA_DIR}/mysql.sock
	fi
fi


exec /usr/bin/mysqld_safe
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'admin'"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY 'admin'"