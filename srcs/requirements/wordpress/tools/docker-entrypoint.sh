#!/bin/bash
set -e

source /usr/local/lib/entrypoint-lib.sh

require_env DOMAIN_NAME
require_env WP_DB_NAME
require_env WP_DB_USER
require_env WP_DB_PASSWORD_FILE
require_env WP_DB_HOST
require_env WP_ADMIN_USER
require_env WP_ADMIN_EMAIL
require_env WP_USER
require_env WP_USER_EMAIL


DB_PASSWORD=$(read_secret "$WP_DB_PASSWORD_FILE")
WP_ADMIN_PASSWORD=$(read_secret "$WP_ADMIN_PASSWORD_FILE")
WP_USER_PASSWORD=$(read_secret "$WP_USER_PASSWORD_FILE")

cd /var/www/html

if [ ! -f "wp-config.php" ]; then
    echo "Creating wp-config.php and installing WordPress..."
    wp core download --allow-root

    wp config create \
        --dbname="$WP_DB_NAME" \
        --dbuser="$WP_DB_USER" \
        --dbpass="$DB_PASSWORD" \
        --dbhost="$WP_DB_HOST" \
        --allow-root

    echo "Installing WordPress core..."
    wp core install \
        --url="https://$DOMAIN_NAME" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email \
        --allow-root

    echo "Creating regular user..."
    wp user create \
        "$WP_USER" \
        "$WP_USER_EMAIL" \
        --user_pass="$WP_USER_PASSWORD" \
        --role=author \
        --allow-root

    echo "Configuring Redis Object Cache..."
    wp config set WP_REDIS_HOST redis --allow-root
    wp config set WP_REDIS_PORT 6379 --raw --allow-root
    wp plugin install redis-cache --activate --allow-root
    wp redis enable --allow-root

    chown -R www-data:www-data /var/www/html

    echo "WordPress installation finished!"
else
    echo "wp-config.php already exists, skipping installation."
fi

mkdir -p /run/php

exec php-fpm${PHP_VERSION} -F