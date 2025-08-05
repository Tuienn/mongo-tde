#!/bin/bash

# This script orchestrates the setup and launch of a TDE-enabled
# MongoDB Enterprise container using Docker Compose.

echo "--- MongoDB TDE Docker Start Script ---"

# Step 1: Generate the encryption key if it doesn't exist.
# This calls the key generation script.
echo "[Step 1/2] Checking and generating encryption key..."
bash ./create_keyfile.sh

# Check if the key file was created successfully before proceeding
if [ ! -f "./keys/mongodb-tde.key" ]; then
    echo "Error: Encryption key file was not found after running create_keyfile.sh. Aborting."
    exit 1
fi
echo "Encryption key is ready."
echo ""

# Step 2: Start the MongoDB container using Docker Compose.
# The '-d' flag runs the container in detached mode (in the background).
echo "[Step 2/2] Starting MongoDB container with Docker Compose..."
docker-compose up -d

# Check the status of the container
echo ""
echo "Docker Compose command executed. Checking container status..."
docker-compose ps

echo ""
echo "--- Script finished. Your MongoDB TDE instance should be running. ---"
echo "You can view logs with: docker-compose logs -f"
