#!/bin/bash
set -Eeuo pipefail

source /usr/local/lib/entrypoint-lib.sh

WP_PATH="/var/www/html"

wp_cli() {
    wp --allow-root --path="$WP_PATH" "$@"
}

load_WP_secrets() {
    DB_PASSWORD=$(read_secret "$WP_DB_PASSWORD_FILE")
    WP_ADMIN_PASSWORD=$(read_secret "$WP_ADMIN_PASSWORD_FILE")
    WP_USER_PASSWORD=$(read_secret "$WP_USER_PASSWORD_FILE")
}

validate_WP_environment() {
    require_env DOMAIN_NAME

    require_env WP_DB_NAME
    require_env WP_DB_USER
    require_env WP_DB_HOST
    require_env WP_DB_PASSWORD_FILE

    require_env WP_ADMIN_USER
    require_env WP_ADMIN_EMAIL

    require_env WP_USER
    require_env WP_USER_EMAIL
}

install_wordpress() {
    info "Downloading WordPress..."

    wp_cli core download

    info "Creating wp-config.php..."

    wp_cli config create \
        --dbname="$WP_DB_NAME" \
        --dbuser="$WP_DB_USER" \
        --dbpass="$DB_PASSWORD" \
        --dbhost="$WP_DB_HOST"

    info "Installing WordPress..."

    wp_cli core install \
        --url="https://$DOMAIN_NAME" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email
}

create_user() {
    info "Creating regular user..."

    wp_cli user create \
        "$WP_USER" \
        "$WP_USER_EMAIL" \
        --user_pass="$WP_USER_PASSWORD" \
        --role=author
}

configure_redis() {
    info "Configuring Redis..."

    wp_cli config set WP_REDIS_HOST redis
    wp_cli config set WP_REDIS_PORT 6379 --raw

    wp_cli plugin install redis-cache --activate
    wp_cli redis enable
}

fix_permissions() {
    chown -R www-data:www-data "$WP_PATH"
}

start_php() {
    mkdir -p /run/php

    if [ "${1:-}" = "php-fpm" ]; then
        shift
        exec "php-fpm${PHP_VERSION}" "$@"
    fi

    exec "$@"
}

###############################################################################
# Main
###############################################################################

validate_WP_environment
load_WP_secrets

if [ ! -f "$WP_PATH/wp-config.php" ] || ! wp_cli core is-installed >/dev/null 2>&1; then

    install_wordpress
    create_user
    configure_redis
    fix_permissions

    info "WordPress installation finished!"
else
    info "WordPress already installed."
fi

start_php "$@"
