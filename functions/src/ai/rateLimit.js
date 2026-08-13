const {getFirestore, FieldValue} = require("firebase-admin/firestore");
const {AI_USAGE_COLLECTION, AI_FREE_DAILY_LIMIT} = require("../constants");

function todayKey() {
  return new Date().toISOString().slice(0, 10); // YYYY-MM-DD (UTC)
}

// Atomically checks and consumes one of the caller's free-tier daily AI
// requests. Premium callers should never reach this (checked separately).
// Returns true if the request is allowed.
async function consumeFreeQuota(appUserId) {
  const db = getFirestore();
  const docRef = db.collection(AI_USAGE_COLLECTION).doc(`${appUserId}_${todayKey()}`);

  return db.runTransaction(async (tx) => {
    const doc = await tx.get(docRef);
    const count = doc.exists ? doc.data().count || 0 : 0;
    if (count >= AI_FREE_DAILY_LIMIT) {
      return false;
    }
    tx.set(
        docRef,
        {count: count + 1, appUserId, updatedAt: FieldValue.serverTimestamp()},
        {merge: true},
    );
    return true;
  });
}

module.exports = {consumeFreeQuota};
