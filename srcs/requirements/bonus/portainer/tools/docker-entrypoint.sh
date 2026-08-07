#!/bin/bash

set -Eeuo pipefail

source /usr/local/lib/entrypoint-lib.sh

PORTAINER_PASS=$(read_secret "$PORTAINER_PASSWORD_FILE")
HASH=$(htpasswd -nbB admin "$PORTAINER_PASS" | cut -d ":" -f 2)

exec /usr/local/portainer/portainer --admin-password="$HASH" "$@"