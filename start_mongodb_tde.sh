#!/bin/bash

# MongoDB Enterprise TDE Setup Script
# This script sets up MongoDB Enterprise with Transparent Data Encryption (TDE) enabled

set -e

echo "Starting MongoDB Enterprise TDE setup..."

# Create necessary directories
echo "Creating required directories..."
mkdir -p data configdb encryption scripts

# Check if encryption keyfile exists
if [ ! -f "encryption/mongodb-keyfile" ]; then
    echo "Encryption keyfile not found. Please run create_keyfile.sh first."
    exit 1
fi

# Set proper permissions for keyfile
echo "Setting keyfile permissions..."
chmod 600 encryption/mongodb-keyfile

# Copy test scripts to initialization directory
echo "Copying test scripts..."
cp test_*.js scripts/ 2>/dev/null || echo "No test scripts found to copy"

# Stop and remove existing container if exists
echo "Cleaning up existing containers..."
docker-compose down 2>/dev/null || true

# Pull the latest image
echo "Pulling MongoDB Enterprise image..."
docker pull mongodb/mongodb-enterprise-server:8.0.12-ubi9

# Start MongoDB Enterprise with TDE
echo "Starting MongoDB Enterprise with TDE enabled..."
docker-compose up -d

# Wait for MongoDB to be ready
echo "Waiting for MongoDB to be ready..."
sleep 5

# Check if MongoDB is running
if docker-compose ps | grep -q "Up"; then
    echo "MongoDB Enterprise is running successfully with TDE enabled!"
    echo ""
    echo "Connection details:"
    echo "  Host: localhost"
    echo "  Port: 27017"
    echo "  Username: admin"
    echo "  Password: admin123456"
    echo ""
    echo "To connect using mongosh:"
    echo "  docker exec -it mongodb-enterprise-tde mongosh -u admin -p admin123456 --authenticationDatabase admin"
    echo ""
    echo "To run TDE tests:"
    echo "  docker exec -it mongodb-enterprise-tde mongosh -u admin -p admin123456 --authenticationDatabase admin /docker-entrypoint-initdb.d/test_tde_basic.js"
else
    echo "Failed to start MongoDB Enterprise. Check logs with: docker-compose logs"
    exit 1
fi