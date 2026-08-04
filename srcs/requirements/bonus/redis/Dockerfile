FROM debian:bookworm-slim

ARG REDIS_SERVER_VERSION=5:7.0.15-1~deb12u8

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    redis-server=${REDIS_SERVER_VERSION} \
    && rm -rf /var/lib/apt/lists/* 

RUN mkdir -p /data && chown -R redis:redis /data

COPY conf/redis.cnf /etc/redis/redis.cnf

EXPOSE 6379

USER redis

CMD ["redis-server", "/etc/redis/redis.cnf"]