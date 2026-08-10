#!/bin/bash

set -Eeuo pipefail

source /usr/local/lib/entrypoint-lib.sh

require_env DOMAIN_NAME
require_env FTP_USER
require_env FTP_PASSWORD_FILE

FTP_PASSWORD=$(read_secret "$FTP_PASSWORD_FILE")

if ! id "$FTP_USER" >/dev/null 2>&1; then
    useradd -m -d /var/www/html -s /bin/sh "$FTP_USER"
    echo "$FTP_USER:$FTP_PASSWORD" | chpasswd
    usermod -aG www-data "$FTP_USER"
fi

chown -R "$FTP_USER":www-data /var/www/html

find /var/www/html -type d -exec chmod 2775 {} +
find /var/www/html -type f -exec chmod 0664 {} +

sed "s|\${FTP_PASV_ADDRESS}|${DOMAIN_NAME}|g" \
    /etc/vsftpd.conf.template \
    > /etc/vsftpd.conf

echo "FTP server initialized for user $FTP_USER"

exec vsftpd /etc/vsftpd.conf