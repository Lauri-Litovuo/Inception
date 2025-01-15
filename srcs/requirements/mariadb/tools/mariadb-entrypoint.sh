#!/bin/bash

#Making script stop if there is errors
set -e

FIRST_RUN_FLAG="/etc/.firstrun"
VOLUME_INIT_FLAG="/var/lib/mysql/.firstmount"

#Adding dynamic configrations on the first container run..
if [ ! -e "$FIRST_RUN_FLAG" ]; then
	echo "Configuring MariaDB server for the first run"
	if ! grep -q "bind-address=0.0.0.0" /etc/my.cnf.d/mariadb-server.cnf; then
	cat << EOF >> /etc/my.cnf.d/mariadb-server.cnf
[mysqld]
bind-address=0.0.0.0
skip-networking=0
EOF
	touch "$FIRST_RUN_FLAG"
fi

#Initializing the db dir if not initialized already
if [ ! -e "$VOLUME_INIT_FLAG" ]; then
	echo "Mariadb dir init.."
	mysql_install_db --user=mysql --datadir=/var/lib/mysql --skip-test-db >/dev/null 2>&1

	echo "Starting temp MariaDB server.."
	mysqld_safe --skip-networking > /var/log/mariadb_temp.log 2>&1 &
	mysqld_pid=$!

	#Wait for the server to be ready
	echo "Waiting for MariaDB to start..."
	timeout=30
	elapsed=0
	until mysqladmin ping --silent; do
		sleep 1
		elapsed=$((elapsed + 1))
		if [ $elapsed -ge $timeout ]; then
			echo "Error: MariaDB server failed to start within $timeout seconds."
			exit 1
		fi
	done

    echo "Setting up initial SQLdatabase and user accounts..."
    mysql --protocol=socket -u root <<-EOF
        FLUSH PRIVILEGES;
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

        CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
        CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';

        -- Clean up default users and test databases for security
        DELETE FROM mysql.user WHERE User='';
        DROP DATABASE IF EXISTS test;
        DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

        FLUSH PRIVILEGES;
EOF

    #Shutting down the temporary server
    echo "Shutting down temporary MariaDB server..."
    if ! mysqladmin shutdown; then
		echo "Error: Failed to shut down temp MariaDB server."
		exit 1
	fi

    #Making volume init flag
    touch "$VOLUME_INIT_FLAG"
fi

# Start the MariaDB server
echo "Starting MariaDB server..."
exec mysqld_safe

