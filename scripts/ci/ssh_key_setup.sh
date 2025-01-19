#!/bin/bash

set -e

# Check for required environment variables
: "${HOMELAB_SSH_KEY_PATH:?Environment variable HOMELAB_SSH_KEY_PATH is required}"
: "${HOMELAB_SSH_KEY_B64:?Environment variable HOMELAB_SSH_KEY_B64 is required }"

# Ensure the .ssh directory exists
mkdir -p "$(dirname "${HOMELAB_SSH_KEY_PATH}")"

# Check if the SSH key file already exists
if [[ -f "${HOMELAB_SSH_KEY_PATH}" ]]; then
    echo "SSH key file already exists at ${HOMELAB_SSH_KEY_PATH}. Skipping creation."
else
    echo "SSH key file not found. Decoding and writing key to ${HOMELAB_SSH_KEY_PATH}."
    echo "$HOMELAB_SSH_KEY_B64" | base64 -d > "${HOMELAB_SSH_KEY_PATH}"
    chmod 600 "${HOMELAB_SSH_KEY_PATH}"
    echo "SSH key written successfully."
fi
