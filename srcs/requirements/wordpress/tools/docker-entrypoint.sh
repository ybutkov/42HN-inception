#!/bin/bash
set -e

if [ -f "$WP_DB_PASSWORD_FILE" ]; then
    DB_PASSWORD=$(cat "$WP_DB_PASSWORD_FILE")
else
    echo "ERROR: Secret file $WP_DB_PASSWORD_FILE not found!" >&2
    exit 1
fi

if [ -f "$WP_ADMIN_PASSWORD_FILE" ]; then
    WP_ADMIN_PASSWORD=$(cat "$WP_ADMIN_PASSWORD_FILE")
else
    echo "ERROR: Secret file $WP_ADMIN_PASSWORD_FILE not found!" >&2
    exit 1
fi

if [ -f "$WP_USER_PASSWORD_FILE" ]; then
    WP_USER_PASSWORD=$(cat "$WP_USER_PASSWORD_FILE")
else
    echo "ERROR: Secret file $WP_USER_PASSWORD_FILE not found!" >&2
    exit 1
fi

if [ -z "$DB_PASSWORD" ] || [ -z "$WP_ADMIN_PASSWORD" ] || [ -z "$WP_USER_PASSWORD" ]; then
    echo "ERROR: One or more secret files are empty!" >&2
    exit 1
fi

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

    chown -R www-data:www-data /var/www/html

    echo "WordPress installation finished!"
else
    echo "wp-config.php already exists, skipping installation."
fi

mkdir -p /run/php

exec php-fpm8.2 -F