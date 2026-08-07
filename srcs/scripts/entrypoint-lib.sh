#!/bin/bash
set -Eeuo pipefail

###############################################################################
# Logging
###############################################################################

info() {
    echo "[INFO] $*"
}

warn() {
    echo "[WARN] $*" >&2
}

fatal() {
    echo "[ERROR] $*" >&2
    exit 1
}

###############################################################################
# Environment
###############################################################################

require_env() {
    local name="$1"

    [ -n "${!name}" ] || fatal "Environment variable '$name' is not set."
}

###############################################################################
# File checkers
###############################################################################

check_file_has_content() {
    local file="$1"

    [ -f "$file" ] || fatal "File '$file' not found."
    [ -s "$file" ] || fatal "File '$file' is empty."
}

read_secret() {
    local file="$1"

    check_file_has_content "$file"

    tr -d '\r\n' < "$file"
}