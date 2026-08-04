FROM debian:bookworm-slim

ARG PORTAINER_VERSION=2.43.0
ARG APACHE2_UTILS_VERSION=2.4.68-1~deb12u1
ARG PORTAINER_SHA256=d769c3639cf11e298e2d1ea93290a6f50144cded0cfe3f6cd60166ec3e2259f5

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    tar \
    apache2-utils=${APACHE2_UTILS_VERSION} && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fsSL "https://github.com/portainer/portainer/releases/download/${PORTAINER_VERSION}/portainer-${PORTAINER_VERSION}-linux-amd64.tar.gz" \
    -o /tmp/portainer.tar.gz && \
    echo "${PORTAINER_SHA256}  /tmp/portainer.tar.gz" | sha256sum -c - && \
    tar -xzf /tmp/portainer.tar.gz -C /usr/local && \
    rm /tmp/portainer.tar.gz

COPY tools/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["docker-entrypoint.sh"]
