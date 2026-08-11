const {getFirestore, FieldValue} = require("firebase-admin/firestore");
const {USERS_COLLECTION} = require("../constants");

async function setPremiumStatus(appUserId, {isPremium, lastEventType}) {
  await getFirestore().collection(USERS_COLLECTION).doc(appUserId).set(
      {
        premium: isPremium,
        lastEventType: lastEventType || null,
        updatedAt: FieldValue.serverTimestamp(),
      },
      {merge: true},
  );
}

// Used by other backend code (e.g. a future AI proxy function) to check a
// caller's premium status — pass the appUserId the Flutter app sends (see
// PurchaseService.appUserId) before applying free-tier limits.
async function isPremiumUser(appUserId) {
  const doc = await getFirestore().collection(USERS_COLLECTION).doc(appUserId).get();
  return doc.exists && doc.data().premium === true;
}

module.exports = {setPremiumStatus, isPremiumUser};
