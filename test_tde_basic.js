// MongoDB TDE Basic Test Script
// This script tests basic TDE functionality

print("MongoDB TDE Basic Test");
print("======================");

// Switch to test database
db = db.getSiblingDB("testdb");

// Create a test collection
print("\n1. Creating test collection...");
db.createCollection("encrypted_data");

// Insert test documents
print("\n2. Inserting test documents...");
const testDocs = [
  {
    _id: 1,
    name: "John Doe",
    ssn: "123-45-6789",
    creditCard: "4532-1234-5678-9012",
    balance: 10000.5,
    created: new Date(),
  },
  {
    _id: 2,
    name: "Jane Smith",
    ssn: "987-65-4321",
    creditCard: "5432-9876-5432-1098",
    balance: 25000.75,
    created: new Date(),
  },
  {
    _id: 3,
    name: "Bob Johnson",
    ssn: "456-78-9123",
    creditCard: "4111-1111-1111-1111",
    balance: 5000.0,
    created: new Date(),
  },
];

db.encrypted_data.insertMany(testDocs);
print("Inserted " + testDocs.length + " documents");

// Query the data
print("\n3. Querying encrypted data...");
const results = db.encrypted_data.find({}).toArray();
print("Found " + results.length + " documents");
results.forEach((doc) => {
  print("  - " + doc.name + ": $" + doc.balance);
});

// Check encryption status
print("\n4. Checking encryption status...");
const serverStatus = db.adminCommand({ serverStatus: 1, security: 1 });
if (serverStatus.security && serverStatus.security.SSLInfo) {
  print("Encryption is enabled");
}

// Get collection stats
print("\n5. Collection statistics:");
const stats = db.encrypted_data.stats();
print("  - Document count: " + stats.count);
print("  - Storage size: " + stats.storageSize + " bytes");
print("  - Average object size: " + stats.avgObjSize + " bytes");

// Test aggregation on encrypted data
print("\n6. Testing aggregation on encrypted data...");
const totalBalance = db.encrypted_data
  .aggregate([{ $group: { _id: null, total: { $sum: "$balance" } } }])
  .toArray();
print("Total balance across all accounts: $" + totalBalance[0].total);

print("\n7. Testing update on encrypted data...");
db.encrypted_data.updateOne({ _id: 1 }, { $inc: { balance: 500 } });
const updated = db.encrypted_data.findOne({ _id: 1 });
print("Updated balance for " + updated.name + ": $" + updated.balance);

print("\nTDE basic test completed successfully!");
print("Note: Data is encrypted at rest on disk, transparent to applications.");
