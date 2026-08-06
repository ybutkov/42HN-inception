#!/bin/bash

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
# Docker Secrets
###############################################################################

# read_secret() {
#     local file="$1"

#     [ -f "$file" ] || fatal "Secret file '$file' not found."

#     local value
#     value=$(tr -d '\r\n' < "$file")

#     [ -n "$value" ] || fatal "Secret file '$file' is empty."

#     printf '%s' "$value"
# }

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