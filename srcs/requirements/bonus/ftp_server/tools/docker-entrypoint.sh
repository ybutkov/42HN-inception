#!/bin/sh

set -Eeuo pipefail

source /usr/local/lib/entrypoint-lib.sh

require_env DOMAIN_NAME
require_env FTP_USER

FTP_PASSWORD=$(read_secret "$FTP_PASSWORD_FILE")

if ! id "$FTP_USER" >/dev/null 2>&1; then
    useradd -m -d /var/www/html -s /bin/sh "$FTP_USER"
    echo "$FTP_USER:$FTP_PASSWORD" | chpasswd

    usermod -aG www-data "$FTP_USER"    
fi

chown -R "$FTP_USER":www-data /var/www/html
chmod -R 775 /var/www/html
chmod g+s /var/www/html

sed "s|\${FTP_PASV_ADDRESS}|${DOMAIN_NAME}|g" \
    /etc/vsftpd.conf.template \
    > /etc/vsftpd.conf

echo "FTP server initialized for user $FTP_USER"
    
exec vsftpd /etc/vsftpd.conf
