#!/bin/sh

set -e

ADMIN_USER="${PORTAINER_ADMIN_USER:-admin}"

if [ -f "$PORTAINER_PASSWORD_FILE" ]; then
    PORTAINER_PASS=$(cat "$PORTAINER_PASSWORD_FILE" | tr -d '\r\n')
    if [ -n "$PORTAINER_PASS" ]; then
        HASH=$(htpasswd -nbB "$ADMIN_USER" "$PORTAINER_PASS" | cut -d ":" -f 2)
    fi
fi

if [ -z "$HASH" ] ; then
    echo "WARNING: Secret password not found or empty" >&2
    exec /usr/local/portainer/portainer "$@"
else
    exec /usr/local/portainer/portainer --admin-password="$HASH" "$@"
fi

