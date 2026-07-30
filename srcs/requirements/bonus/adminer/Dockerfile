FROM debian:bookworm

ARG PHP_VERSION=8.2
ARG PHP_FPM=php-fpm${PHP_VERSION}

ARG ADMINER_VERSION=5.2.0
ARG ADMINER_SHA256=d6ae5bfa46263ab2ee16e80d66fc6d5300bc38361210a54019354e192714d73e

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        php${PHP_VERSION}-fpm \
        php${PHP_VERSION}-mysql \
        curl \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN useradd --no-create-home adminer

RUN mkdir -p /run/php

WORKDIR /var/www/html

RUN curl -sSL "https://github.com/vrana/adminer/releases/download/v${ADMINER_VERSION}/adminer-${ADMINER_VERSION}.php" -o index.php && \
    echo "${ADMINER_SHA256}  index.php" | sha256sum -c - && \
    chown -R adminer:adminer /var/www/html

COPY conf/www.conf /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf

EXPOSE 9000

CMD ["php-fpm8.2", "-F"]