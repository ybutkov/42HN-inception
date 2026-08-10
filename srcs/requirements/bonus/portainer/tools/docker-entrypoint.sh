#!/bin/bash

set -Eeuo pipefail

source /usr/local/lib/entrypoint-lib.sh

require_env PORTAINER_PASSWORD_FILE

if [ "$1" = "/usr/local/portainer/portainer" ]; then
    PORTAINER_PASS=$(read_secret "$PORTAINER_PASSWORD_FILE")
    HASH=$(htpasswd -nbB admin "$PORTAINER_PASS" | cut -d ":" -f 2)

    set -- "$@" --admin-password="$HASH"
fi

exec "$@"
