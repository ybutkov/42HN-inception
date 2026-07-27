#!/bin/bash
set -e

if [ -f "$DB_PASSWORD_FILE" ]; then
    MYSQL_PASSWORD=$(cat "$DB_PASSWORD_FILE")
fi

if [ -f "$DB_ADMIN_PASSWORD_FILE" ]; then
    MYSQL_ROOT_PASSWORD=$(cat "$DB_ADMIN_PASSWORD_FILE")
fi

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

if [ ! -d "/var/lib/mysql/mysql" ]; then

    echo "Init DB..."
    chown -R mysql:mysql /var/lib/mysql
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null

    mysqld --user=mysql --bootstrap << EOF
USE mysql;
FLUSH PRIVILEGES;

ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

FLUSH PRIVILEGES;
EOF

    echo "MariaDB setup finished!"
fi

exec mysqld --user=mysql