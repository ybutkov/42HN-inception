FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    redis-server \
    && rm -rf /var/lib/apt/lists/* 

RUN mkdir -p /data && chown -R redis:redis /data

COPY conf/redis.cnf /etc/redis/redis.cnf

EXPOSE 6379

USER redis

CMD ["redis-server", "/etc/redis/redis.cnf"]