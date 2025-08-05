#!/bin/bash

# ==============================================================================
# MongoDB TDE Test Simulation Script
#
# This script SIMULATES connecting to a TDE-enabled MongoDB instance.
# It does NOT make a real connection. Its purpose is to generate logs that
# explain and demonstrate the concept of Transparent Data Encryption (TDE).
# ==============================================================================

# --- Configuration for Simulation ---
DB_HOST="mongodb-tde"
MONGO_USER="myAdminUser"
TEST_DB="TDE_StressTest"
COLLECTION_NAME="customer_records"

# --- Helper Functions ---

# Function to print a clean header
print_header() {
    echo ""
    tput setaf 3 # Set text color to yellow
    echo "======================================================================="
    echo " $1"
    echo "======================================================================="
    tput sgr0 # Reset text color
}

# Function to print a success message
print_success() {
    tput setaf 2 # Set text color to green
    echo "[SUCCESS] $1"
    tput sgr0 # Reset text color
}

# Function to print an info message
print_info() {
    tput setaf 6 # Set text color to cyan
    echo "[INFO] $1"
    tput sgr0 # Reset text color
}

# --- Main Simulation Script ---

print_header "Starting MongoDB TDE Test Simulation"

# 1. Simulate Connection
print_info "Attempting to connect to host '$DB_HOST' with user '$MONGO_USER'..."
sleep 1
print_success "Connection established. Server confirmed TDE is active."

# 2. Simulate Data Insertion
print_header "Simulating Insertion of a Sensitive Document"
print_info "Client sends a new document in plaintext to the server:"
echo '{
    "customer_id": "CUST-849201",
    "full_name": "Nguyen Van A",
    "national_id": "038090012345",
    "credit_card_info": {
        "number": "5123-4567-8901-2345",
        "cvv": "123"
    }
}'
sleep 2
print_info "MongoDB server receives the plaintext document..."
print_info "Server is now encrypting the document before writing to storage..."
sleep 2
print_success "Document has been encrypted and written to the data files on disk."

# 3. Simulate Reading Data (The "Transparent" part of TDE)
print_header "Simulating Reading Data from the Client's Perspective"
print_info "Client application requests the document for 'CUST-849201'..."
sleep 1
print_info "MongoDB server finds the encrypted data on disk, decrypts it in memory..."
sleep 2
print_info "Server sends the decrypted, original document back to the client."
print_success "Client receives the familiar, readable JSON document:"
echo '{
    "_id": { "$oid": "66b1d4efabc123def4567890" },
    "customer_id": "CUST-849201",
    "full_name": "Nguyen Van A",
    "national_id": "038090012345",
    "credit_card_info": {
        "number": "5123-4567-8901-2345",
        "cvv": "123"
    }
}'

# 4. Illustrate the Encrypted Data on Disk
print_header "Illustrating the Encrypted Data as Stored on Disk"
print_info "If an unauthorized user gained access to the server's physical files..."
print_info "They would NOT see the JSON document. They would see encrypted gibberish:"
sleep 1
tput setaf 4 # Set color to blue for the encrypted block
echo "
-------------------------- REPRESENTATION OF ENCRYPTED DATA BLOCK --------------------------
|                                                                                          |
|  BSON obj -> Zstandard compression -> AES-256-CBC encryption -> Written to .wt file      |
|                                                                                          |
|  VIEW FROM RAW FILE:                                                                     |
|  T29uZf5pbiBzdG9yYWdlLCB0aGlzIGRhdGEgaXMgZW5jcnlwdGVkIGJ5IE1vbmdvREIgdXNpbmcgQUVT    |
|  MjU2LWdgyZiB3aXRoIGEgbWFzdGVyIGtleS4gVGhlIG9yaWdpbmFsIEpTT04gc3RydWN0dXJlIGlzIG5v   |
|  dCB2aXNpYmxlIGRpcmVjdGx5IGluIHRoZSBkYXRhYmFzZSBmaWxlcy4gSXQgaXMgcHJvdGVjdGVkIGFn   |
|  YWluc3QgZGlyZWN0IGFjY2VzcyBvciB0aGVmdCBvZiB0aGUgdW5kZXJseWluZyBzdG9yYWdlLiBUaGUg   |
|  ZGVjcnlwdGlvbiBoYXBwZW5zIHRyYW5zcGFyZW50bHkgd2hlbiBhbiBhdXRob3JpemVkIGNsaWVudCBx   |
|  dWVyaWVzIHRoZSBuZXR3b3JrLiBUYXAgdHJvbmcgYmFvIG1hdCBkdSBsaWV1LiBDaHVjIGJhbiB0aGFu   |
|  aCBjb25nIQ==                                                                             |
|                                                                                          |
--------------------------------------------------------------------------------------------
"
tput sgr0 # Reset color

print_header "Simulation Complete"
print_info "This simulation demonstrates that TDE secures data 'at rest' (on the disk) while remaining 'transparent' to authorized applications."
echo ""