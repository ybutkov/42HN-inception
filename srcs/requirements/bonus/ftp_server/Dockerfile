FROM debian:bookworm-slim

ARG VSFTPD_VERSION=3.0.3-13+b2

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    vsftpd=${VSFTPD_VERSION} \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/vsftpd/empty

COPY conf/vsftpd.conf.template /etc/vsftpd.conf.template
COPY tools/docker-entrypoint.sh /usr/local/bin/setup-ftp.sh

RUN chmod +x /usr/local/bin/setup-ftp.sh

EXPOSE 21 21210-21220

ENTRYPOINT ["/usr/local/bin/setup-ftp.sh"]
