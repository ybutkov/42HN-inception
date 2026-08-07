FROM debian:bookworm-slim

ARG PHP_VERSION=8.2
ARG WP_CLI_VERSION=2.10.0

ENV PHP_VERSION=${PHP_VERSION}

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        php${PHP_VERSION}-fpm \
        php${PHP_VERSION}-mysql \
        php${PHP_VERSION}-curl \
        php${PHP_VERSION}-gd \
        php${PHP_VERSION}-xml \
        php${PHP_VERSION}-mbstring \
        php${PHP_VERSION}-zip \
        php${PHP_VERSION}-intl \
        php${PHP_VERSION}-redis \
        mariadb-client \
        curl \
		ca-certificates \
        unzip && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fsSL \
        --retry 5 \
        --retry-delay 2 \
        "https://github.com/wp-cli/wp-cli/releases/download/v${WP_CLI_VERSION}/wp-cli-${WP_CLI_VERSION}.phar" \
        -o /usr/local/bin/wp && \
    chmod +x /usr/local/bin/wp

COPY conf/www.conf /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf

COPY tools/docker-entrypoint.sh /usr/local/bin/
COPY tools/entrypoint-lib.sh /usr/local/lib/

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["docker-entrypoint.sh"]