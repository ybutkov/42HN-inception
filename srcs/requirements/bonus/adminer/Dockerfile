FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    php-cli \
    php-mysqli \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

ARG ADMINER_VERSION=5.2.0
ARG ADMINER_SHA256=d6ae5bfa46263ab2ee16e80d66fc6d5300bc38361210a54019354e192714d73e

RUN curl -sSL "https://github.com/vrana/adminer/releases/download/v${ADMINER_VERSION}/adminer-${ADMINER_VERSION}.php" -o index.php && \
    echo "${ADMINER_SHA256}  index.php" | sha256sum -c -

EXPOSE 8080

RUN useradd -m adminer
USER adminer

CMD ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/html"]