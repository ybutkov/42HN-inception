FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    vsftpd \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/vsftpd/empty

COPY conf/vsftpd.conf.template /etc/vsftpd.conf.template
COPY tools/docker-entrypoint.sh /usr/local/bin/setup-ftp.sh
COPY tools/entrypoint-lib.sh /usr/local/lib/

RUN chmod +x /usr/local/bin/setup-ftp.sh

EXPOSE 21 21210-21220

ENTRYPOINT ["/usr/local/bin/setup-ftp.sh"]
