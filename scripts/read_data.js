// scripts/read_data.js
// This script connects to the MongoDB instance and reads the document
// inserted by insert_data.js to verify it can be decrypted.

console.log("--- Attempting to read data from TDE-enabled MongoDB ---");

// --- Configuration ---
const dbName = "TDE_TestDB";
const collectionName = "EncryptedCollection";

// --- Main Logic ---
try {
  // Switch to the target database
  db = db.getSiblingDB(dbName);

  // Find the document we inserted
  const foundDocument = db[collectionName].findOne({ ssn: "123-456-7890" });

  if (foundDocument) {
    console.log("Successfully found and decrypted the document:");
    // Print the document to show it's readable by the application
    printjson(foundDocument);
  } else {
    console.error(
      "Could not find the document. Make sure you have run 'insert_data.js' first."
    );
  }
} catch (e) {
  console.error("An error occurred while reading data:", e);
}

console.log("-------------------------------------------------------");
