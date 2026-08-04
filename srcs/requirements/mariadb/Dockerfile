FROM debian:bookworm-slim

ARG MARIADB_VERSION=1:10.11.18-0+deb12u1

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    mariadb-server=${MARIADB_VERSION} && \
    mkdir -p /run/mysqld && \
    chown -R mysql:mysql /run/mysqld && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/lib/mysql/*

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/docker-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 3306

ENTRYPOINT ["docker-entrypoint.sh"]