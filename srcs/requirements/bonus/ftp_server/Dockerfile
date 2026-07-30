FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    vsftpd \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/vsftpd/empty

COPY conf/vsftpd.conf /etc/vsftpd.conf
COPY tools/docker-entrypoint.sh /usr/local/bin/setup-ftp.sh

RUN chmod +x /usr/local/bin/setup-ftp.sh

EXPOSE 21 21100-21110

ENTRYPOINT ["/usr/local/bin/setup-ftp.sh"]
