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
    
    chown -R www-data:www-data /var/www/html
    
    usermod -aG www-data "$FTP_USER"
fi

echo "FTP server initialized for user $FTP_USER"

exec vsftpd /etc/vsftpd.conf
