#!/bin/bash

# MongoDB Encryption Keyfile Generator
# This script creates a keyfile for MongoDB Transparent Data Encryption (TDE)

set -e

echo "MongoDB TDE Keyfile Generator"
echo "=============================="

# Create encryption directory if it doesn't exist
mkdir -p encryption

# Keyfile path
KEYFILE_PATH="encryption/mongodb-keyfile"

# Check if keyfile already exists
if [ -f "$KEYFILE_PATH" ]; then
    read -p "Keyfile already exists. Do you want to overwrite it? (y/N): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo "Keyfile generation cancelled."
        exit 0
    fi
fi

# Generate a 96-byte base64-encoded keyfile
echo "Generating encryption keyfile..."
openssl rand -base64 96 > "$KEYFILE_PATH"

# Set secure permissions (read-only for owner)
chmod 600 "$KEYFILE_PATH"

# Verify keyfile was created
if [ -f "$KEYFILE_PATH" ]; then
    echo "Keyfile created successfully at: $KEYFILE_PATH"
    echo ""
    echo "Important notes:"
    echo "1. Keep this keyfile secure - it's required to decrypt your data"
    echo "2. Back up this keyfile in a secure location"
    echo "3. Loss of this keyfile means permanent loss of encrypted data"
    echo "4. The keyfile has been set with permissions 600 (owner read-only)"
else
    echo "Failed to create keyfile"
    exit 1
fi