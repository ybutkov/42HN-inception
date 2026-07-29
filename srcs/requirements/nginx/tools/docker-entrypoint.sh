#!/bin/bash
set -e

SSL_CERT_DST=/etc/nginx/ssl

CERT_NAME=$(basename "$NGINX_SSL_CERTIFICATE_HOST_FILE")
KEY_NAME=$(basename "$NGINX_SSL_CERTIFICATE_KEY_HOST_FILE")

mkdir -p "$SSL_CERT_DST"

if [ ! -f "$NGINX_SSL_CERTIFICATE_FILE" ]; then
    echo "ERROR: SSL certificate not found: $NGINX_SSL_CERTIFICATE_FILE"
    exit 1
fi

if [ ! -f "$NGINX_SSL_CERTIFICATE_KEY_FILE" ]; then
    echo "ERROR: SSL key not found: $NGINX_SSL_CERTIFICATE_KEY_FILE"
    exit 1
fi

cp "$NGINX_SSL_CERTIFICATE_FILE"        "$SSL_CERT_DST/$CERT_NAME"
cp "$NGINX_SSL_CERTIFICATE_KEY_FILE"    "$SSL_CERT_DST/$KEY_NAME"

chmod 600 "$SSL_CERT_DST/$KEY_NAME"

exec nginx -g "daemon off;"