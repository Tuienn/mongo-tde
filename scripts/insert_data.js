// scripts/insert_data.js
// This script connects to the MongoDB instance, creates a database and collection,
// and inserts a sample document.

console.log("--- Attempting to insert data into TDE-enabled MongoDB ---");

// --- Configuration ---
const dbName = "TDE_TestDB";
const collectionName = "EncryptedCollection";
const sampleDocument = {
  patient_name: "John Doe",
  ssn: "123-456-7890",
  birth_date: new Date("1985-05-20"),
  medical_history: [
    { visit_date: new Date(), reason: "Annual Checkup" },
    { visit_date: new Date("2022-10-15"), reason: "Flu Shot" },
  ],
  notes: "This is a sensitive record and should be encrypted at rest.",
};

// --- Main Logic ---
try {
  // Switch to the target database
  db = db.getSiblingDB(dbName);

  // Insert the document
  const insertResult = db[collectionName].insertOne(sampleDocument);

  if (insertResult.acknowledged) {
    console.log(
      `Successfully inserted document with ID: ${insertResult.insertedId}`
    );
    console.log(
      `Document inserted into database '${dbName}', collection '${collectionName}'.`
    );
  } else {
    console.error("Document insertion was not acknowledged.");
  }
} catch (e) {
  console.error("An error occurred during data insertion:", e);
}

console.log("---------------------------------------------------------");
