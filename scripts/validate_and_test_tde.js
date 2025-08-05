// scripts/validate_and_test_tde.js
// A comprehensive script to initialize the replica set, validate TDE status,
// and perform a write/read test.

console.log("--- MongoDB TDE Validation and Test Script ---");

function initializeReplicaSet() {
  console.log("\n[Step 1] Initializing Replica Set 'rs0'...");
  try {
    const status = rs.status();
    console.log(
      "Replica set is already initialized. Current state: " + status.myStateStr
    );
  } catch (e) {
    if (e.codeName === "NotYetInitialized") {
      console.log("Attempting to initiate replica set...");
      const initResult = rs.initiate({
        _id: "rs0",
        members: [{ _id: 0, host: "localhost:27017" }],
      });
      if (initResult.ok === 1) {
        console.log(
          "Replica set initiated successfully. Waiting for node to become PRIMARY..."
        );
        // Wait for the node to become primary
        let isPrimary = false;
        for (let i = 0; i < 10; i++) {
          const status = rs.status();
          if (status.myState === 1) {
            // 1 means PRIMARY
            console.log("Node is now PRIMARY.");
            isPrimary = true;
            break;
          }
          sleep(1000); // sleep for 1 second
        }
        if (!isPrimary) {
          console.error("Error: Timed out waiting for node to become PRIMARY.");
          return false;
        }
      } else {
        console.error("Failed to initiate replica set:", initResult);
        return false;
      }
    } else {
      console.error(
        "An error occurred checking replica set status:",
        e.message
      );
      return false;
    }
  }
  return true;
}

function checkTdeStatus() {
  console.log("\n[Step 2] Checking TDE (Encryption at Rest) Status...");
  try {
    const encryptionStatus = db
      .getSiblingDB("admin")
      .serverStatus().encryptionAtRest;
    if (encryptionStatus && encryptionStatus.encryptionEnabled) {
      console.log("  - TDE Status: Active");
      console.log(
        "  - Encryption Cipher: " + encryptionStatus.encryptionCipherMode
      );
      return true;
    } else {
      console.error(
        "  - TDE Status: INACTIVE. Encryption is not enabled on the server."
      );
      return false;
    }
  } catch (e) {
    console.error("Failed to get TDE status:", e.message);
    return false;
  }
}

function performReadWriteTest() {
  console.log("\n[Step 3] Performing Write/Read Test...");
  const dbName = "TDE_TestDB";
  const collectionName = "EncryptedCollection";
  const testDoc = {
    patient_id: "98765",
    sensitive_info: "This data must be encrypted at rest.",
    timestamp: new Date(),
  };

  try {
    const testDB = db.getSiblingDB(dbName);

    // Write
    const insertResult = testDB[collectionName].insertOne(testDoc);
    if (!insertResult.acknowledged) {
      console.error(
        "  - Write Test FAILED: Document insertion not acknowledged."
      );
      return false;
    }
    console.log(
      `  - Write Test PASSED: Inserted document with ID: ${insertResult.insertedId}`
    );

    // Read
    const foundDocument = testDB[collectionName].findOne({
      patient_id: "98765",
    });
    if (
      foundDocument &&
      foundDocument.sensitive_info === testDoc.sensitive_info
    ) {
      console.log(
        "  - Read Test PASSED: Successfully retrieved and decrypted the document."
      );
      print("  - Retrieved Document:", JSON.stringify(foundDocument, null, 2));
    } else {
      console.error(
        "  - Read Test FAILED: Could not retrieve the correct document."
      );
      return false;
    }

    // Clean up
    testDB.dropDatabase();
    console.log("  - Cleanup: Dropped test database.");
  } catch (e) {
    console.error("An error occurred during the read/write test:", e.message);
    return false;
  }
  return true;
}

// --- Main Execution ---
if (initializeReplicaSet()) {
  if (checkTdeStatus()) {
    if (performReadWriteTest()) {
      console.log(
        "\n--- SUCCESS: MongoDB TDE setup is validated and working correctly! ---"
      );
    } else {
      console.log("\n--- FAILED: The read/write test failed. ---");
    }
  } else {
    console.log("\n--- FAILED: TDE status check failed. ---");
  }
} else {
  console.log("\n--- FAILED: Replica set initialization failed. ---");
}
