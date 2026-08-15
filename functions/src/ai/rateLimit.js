const {getFirestore, FieldValue} = require("firebase-admin/firestore");
const {
  AI_USAGE_COLLECTION,
  AI_FREE_DAILY_LIMIT,
  AI_PREMIUM_LIMIT,
  AI_PREMIUM_WINDOW_MS,
} = require("../constants");

function todayKey() {
  return new Date().toISOString().slice(0, 10); // YYYY-MM-DD (UTC)
}

// Atomically checks and consumes one of the caller's free-tier daily AI
// requests. Returns true if the request is allowed.
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

// Same rolling-window shape as the app's free-tier scan limit
// (ScanUsageRepository): a window opens on first use and the count resets
// once AI_PREMIUM_WINDOW_MS has passed since it opened. Returns true if the
// request is allowed.
async function consumePremiumQuota(appUserId) {
  const db = getFirestore();
  const docRef = db.collection(AI_USAGE_COLLECTION).doc(`premium_${appUserId}`);

  return db.runTransaction(async (tx) => {
    const doc = await tx.get(docRef);
    const data = doc.exists ? doc.data() : null;
    const windowStartMs = data && data.windowStart ? data.windowStart.toMillis() : null;
    const windowExpired = windowStartMs === null ||
      (Date.now() - windowStartMs) >= AI_PREMIUM_WINDOW_MS;
    const count = windowExpired ? 0 : (data.count || 0);

    if (count >= AI_PREMIUM_LIMIT) {
      return false;
    }

    tx.set(
        docRef,
        {
          count: count + 1,
          appUserId,
          windowStart: windowExpired ? FieldValue.serverTimestamp() : data.windowStart,
          updatedAt: FieldValue.serverTimestamp(),
        },
        {merge: true},
    );
    return true;
  });
}

module.exports = {consumeFreeQuota, consumePremiumQuota};
