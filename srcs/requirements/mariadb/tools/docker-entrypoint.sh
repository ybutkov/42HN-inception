#!/bin/bash
set -e

if [ -f "$MARIADB_ROOT_PASSWORD_FILE" ]; then
    MYSQL_ROOT_PASSWORD=$(cat "$MARIADB_ROOT_PASSWORD_FILE")
else
    echo "ERROR: Secret file $MARIADB_ROOT_PASSWORD_FILE not found!" >&2
    exit 1
fi

if [ -f "$MARIADB_ADMIN_PASSWORD_FILE" ]; then
    MYSQL_ADMIN_PASSWORD=$(cat "$MARIADB_ADMIN_PASSWORD_FILE")
else
    echo "ERROR: Secret file $MARIADB_ADMIN_PASSWORD_FILE not found!" >&2
    exit 1
fi

if [ -f "$MARIADB_WP_USER_PASSWORD_FILE" ]; then
    MARIADB_WP_USER_PASSWORD=$(cat "$MARIADB_WP_USER_PASSWORD_FILE")
else
    echo "ERROR: Secret file $MARIADB_WP_USER_PASSWORD_FILE not found!" >&2
    exit 1
fi


if [ -z "$MYSQL_ROOT_PASSWORD" ] || [ -z "$MYSQL_ADMIN_PASSWORD" ] || [ -z "$MARIADB_WP_USER_PASSWORD" ]; then
    echo "ERROR: Secret files found, but one of the passwords is empty!" >&2
    exit 1
fi

mkdir -p /run/mysqld

chown -R mysql:mysql /run/mysqld 
# chown -R mysql:mysql /run/mysqld /var/lib/mysql

if [ ! -f "/var/lib/mysql/.inception_initialized" ]; then

    echo "Init DB..."

    chown -R mysql:mysql /var/lib/mysql

    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null
    
    mysqld --user=mysql --bootstrap << EOF
USE mysql;
FLUSH PRIVILEGES;

ALTER USER 'root'@'localhost'
IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

CREATE USER IF NOT EXISTS '${MARIADB_ADMIN_USER}'@'%'
IDENTIFIED BY '${MYSQL_ADMIN_PASSWORD}';

GRANT ALL PRIVILEGES
ON *.* TO '${MARIADB_ADMIN_USER}'@'%'
WITH GRANT OPTION;

CREATE DATABASE IF NOT EXISTS \`${MARIADB_DATABASE}\`;

CREATE USER IF NOT EXISTS '${MARIADB_WP_USER}'@'%'
IDENTIFIED BY '${MARIADB_WP_USER_PASSWORD}';

GRANT ALL PRIVILEGES 
ON \`${MARIADB_DATABASE}\`.* TO '${MARIADB_WP_USER}'@'%';

CREATE USER 'healthcheck'@'localhost'
IDENTIFIED BY 'health_password';

GRANT USAGE ON *.* TO 'healthcheck'@'localhost';

DROP DATABASE IF EXISTS test;
DROP USER IF EXISTS ''@'localhost';
DROP USER IF EXISTS ''@'${HOSTNAME}';

REVOKE ALL PRIVILEGES ON \`test\`.* FROM PUBLIC;
REVOKE ALL PRIVILEGES ON \`test\_%\`.* FROM PUBLIC;

FLUSH PRIVILEGES;
EOF

    touch /var/lib/mysql/.inception_initialized
    echo "MariaDB setup finished!"
fi

exec mysqld --user=mysql