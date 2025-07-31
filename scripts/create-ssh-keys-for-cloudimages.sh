#!/usr/bin/env bash
#

# Create SSH keys for cloud images
## Usage: ./create-ssh-keys-for-cloudimages.sh <key_name> <key_comment>

set -euo pipefail

# ask for --yes parameter
if [[ "$1" != "--yes" ]]; then
    echo "Usage: $0 --yes" 
# done
    exit 1
else
    echo "Creating SSH keys for cloud images..."
fi

KEY_NAME="tf-cloud-init"
KEY_COMMENT="Terraform Cloud Init Key for Proxmox VE"
# make sure the dir is inside working directory
KEY_DIR="$(pwd)/infrastructure/ssh-keys"
KEY_FILE="${KEY_DIR}/${KEY_NAME}"

# Create the directory if it doesn't exist
mkdir -p "$KEY_DIR"

# Generate the SSH key pair
ssh-keygen -t rsa -b 4096 -f "$KEY_FILE" -C "$KEY_COMMENT" -N ""

# Set permissions for the private key
chmod 600 "$KEY_FILE"

# Set permissions for the public key
chmod 644 "${KEY_FILE}.pub"

# Output the public key
echo "SSH public key created at: ${KEY_FILE}.pub"

# Output the private key path
echo "SSH private key created at: ${KEY_FILE}"

# Display the public key content
echo "Public key content:"
cat "${KEY_FILE}.pub"

