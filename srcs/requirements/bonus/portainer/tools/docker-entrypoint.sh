#!/bin/bash

set -e

source /usr/local/lib/entrypoint-lib.sh

# if [ -f "$PORTAINER_PASSWORD_FILE" ]; then
#     PORTAINER_PASS=$(cat "$PORTAINER_PASSWORD_FILE" | tr -d '\r\n')
#     if [ -n "$PORTAINER_PASS" ]; then
#         HASH=$(htpasswd -nbB admin "$PORTAINER_PASS" | cut -d ":" -f 2)
#     fi
# fi

# if [ -z "$HASH" ] ; then
#     echo "WARNING: Secret password not found or empty" >&2
#     exec /usr/local/portainer/portainer "$@"
# else
#     exec /usr/local/portainer/portainer --admin-password="$HASH" "$@"
# fi

PORTAINER_PASS=$(read_secret "$PORTAINER_PASSWORD_FILE")
HASH=$(htpasswd -nbB admin "$PORTAINER_PASS" | cut -d ":" -f 2)

exec /usr/local/portainer/portainer --admin-password="$HASH" "$@"