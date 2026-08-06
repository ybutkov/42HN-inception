#!/bin/bash
set -e

source /usr/local/lib/entrypoint-lib.sh

require_env NGINX_SSL_CERTIFICATE_HOST_FILE
require_env NGINX_SSL_CERTIFICATE_FILE
require_env NGINX_SSL_CERTIFICATE_KEY_HOST_FILE
require_env NGINX_SSL_CERTIFICATE_KEY_FILE

SSL_CERT_DST=/etc/nginx/ssl

CERT_NAME=$(basename "$NGINX_SSL_CERTIFICATE_HOST_FILE")
KEY_NAME=$(basename "$NGINX_SSL_CERTIFICATE_KEY_HOST_FILE")

mkdir -p "$SSL_CERT_DST"

# if [ ! -f "$NGINX_SSL_CERTIFICATE_FILE" ]; then
#     echo "ERROR: SSL certificate not found: $NGINX_SSL_CERTIFICATE_FILE"
#     exit 1
# fi
check_file_has_content "$NGINX_SSL_CERTIFICATE_FILE"

# if [ ! -f "$NGINX_SSL_CERTIFICATE_KEY_FILE" ]; then
#     echo "ERROR: SSL key not found: $NGINX_SSL_CERTIFICATE_KEY_FILE"
#     exit 1
# fi
check_file_has_content "$NGINX_SSL_CERTIFICATE_KEY_FILE"

cp "$NGINX_SSL_CERTIFICATE_FILE"        "$SSL_CERT_DST/$CERT_NAME"
cp "$NGINX_SSL_CERTIFICATE_KEY_FILE"    "$SSL_CERT_DST/$KEY_NAME"

chmod 600 "$SSL_CERT_DST/$KEY_NAME"

exec nginx -g "daemon off;"