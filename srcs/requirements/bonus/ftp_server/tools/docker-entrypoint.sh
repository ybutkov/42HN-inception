#!/bin/sh


if [ -f "$FTP_PASSWORD_FILE" ]; then
    FTP_PASSWORD=$(cat "$FTP_PASSWORD_FILE")
else
    echo "ERROR: Secret file $FTP_PASSWORD_FILE not found!" >&2
    exit 1
fi

if ! id "$FTP_USER" >/dev/null 2>&1; then
    useradd -m -d /var/www/html -s /bin/sh "$FTP_USER"
    echo "$FTP_USER:$FTP_PASSWORD" | chpasswd

    usermod -aG www-data "$FTP_USER"    
fi

chown -R "$FTP_USER":www-data /var/www/html
chmod -R 775 /var/www/html

sed "s|\${FTP_PASV_ADDRESS}|${DOMAIN_NAME}|g" \
    /etc/vsftpd.conf.template \
    > /etc/vsftpd.conf

echo "FTP server initialized for user $FTP_USER"
    
exec vsftpd /etc/vsftpd.conf
