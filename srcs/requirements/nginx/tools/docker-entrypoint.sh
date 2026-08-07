#!/bin/bash
set -Eeuo pipefail

source /usr/local/lib/entrypoint-lib.sh

require_env NGINX_SSL_CERTIFICATE_HOST_FILE
require_env NGINX_SSL_CERTIFICATE_FILE
require_env NGINX_SSL_CERTIFICATE_KEY_HOST_FILE
require_env NGINX_SSL_CERTIFICATE_KEY_FILE

SSL_CERT_DST=/etc/nginx/ssl

CERT_NAME=$(basename "$NGINX_SSL_CERTIFICATE_HOST_FILE")
KEY_NAME=$(basename "$NGINX_SSL_CERTIFICATE_KEY_HOST_FILE")

mkdir -p "$SSL_CERT_DST"

check_file_has_content "$NGINX_SSL_CERTIFICATE_FILE"
check_file_has_content "$NGINX_SSL_CERTIFICATE_KEY_FILE"

cp "$NGINX_SSL_CERTIFICATE_FILE"        "$SSL_CERT_DST/$CERT_NAME"
cp "$NGINX_SSL_CERTIFICATE_KEY_FILE"    "$SSL_CERT_DST/$KEY_NAME"

chmod 600 "$SSL_CERT_DST/$KEY_NAME"

exec nginx -g "daemon off;"