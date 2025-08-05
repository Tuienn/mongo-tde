#!/bin/bash

# This script generates a local encryption key for MongoDB TDE.
# The key is a 32-byte (256-bit) random string, base64 encoded.

# --- Configuration ---
KEY_DIR="keys"
KEY_FILE_NAME="mongodb-tde.key"
KEY_FILE_PATH="${KEY_DIR}/${KEY_FILE_NAME}"

# --- Main Logic ---
echo "--- MongoDB TDE Key Generation Script ---"

# Create the key directory if it does not exist
if [ ! -d "$KEY_DIR" ]; then
  echo "Creating directory for key file: ${KEY_DIR}"
  mkdir -p "$KEY_DIR"
fi

# Check if the key file already exists
if [ -f "$KEY_FILE_PATH" ]; then
  echo "Key file already exists at ${KEY_FILE_PATH}. Skipping generation."
else
  echo "Generating new encryption key at ${KEY_FILE_PATH}..."
  # Use openssl to generate 32 random bytes and base64 encode them
  openssl rand -base64 32 > "$KEY_FILE_PATH"
  
  # Set permissions to be readable only by the owner for security
  chmod 400 "$KEY_FILE_PATH"
  
  echo "Successfully generated encryption key."
fi

echo "-----------------------------------------"
