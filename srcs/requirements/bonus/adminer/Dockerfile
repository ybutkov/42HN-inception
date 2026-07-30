FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    php-cli \
    php-mysqli \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

RUN curl -sSL https://github.com/vrana/adminer/releases/download/v5.2.0/adminer-5.2.0.php -o index.php

EXPOSE 8080

CMD ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/html"]