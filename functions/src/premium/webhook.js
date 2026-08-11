const {onRequest} = require("firebase-functions/v2/https");
const {defineSecret} = require("firebase-functions/params");
const {PREMIUM_ENTITLEMENT_ID} = require("../constants");
const {fetchSubscriber, isEntitlementActive} = require("./client");
const {setPremiumStatus} = require("../users/repository");

const premiumWebhookSecret = defineSecret("PREMIUM_WEBHOOK_SECRET");
const premiumApiKey = defineSecret("PREMIUM_API_KEY");

// Our premium provider calls this on every purchase/renewal/cancellation/
// expiration event. Rather than trying to interpret each event type, it
// re-fetches the subscriber's current entitlement state from the provider's
// API (the recommended pattern — the webhook is just a "something changed,
// re-sync" signal) and stores the result in Firestore so other backend code
// (e.g. an AI proxy) can check a user's premium status without calling the
// provider directly on every request.
const premiumWebhook = onRequest(
    {secrets: [premiumWebhookSecret, premiumApiKey], region: "europe-west1"},
    async (req, res) => {
      if (req.method !== "POST") {
        res.status(405).send("Method Not Allowed");
        return;
      }

      if (req.get("Authorization") !== premiumWebhookSecret.value()) {
        res.status(401).send("Unauthorized");
        return;
      }

      const event = req.body && req.body.event;
      const appUserId = event && event.app_user_id;
      if (!appUserId) {
        res.status(400).send("Missing app_user_id");
        return;
      }

      try {
        const subscriberData = await fetchSubscriber(appUserId, premiumApiKey.value());
        const isPremium = isEntitlementActive(subscriberData, PREMIUM_ENTITLEMENT_ID);
        await setPremiumStatus(appUserId, {isPremium, lastEventType: event.type});
        res.status(200).send("OK");
      } catch (error) {
        console.error("Webhook handling failed", error);
        res.status(500).send("Internal error");
      }
    },
);

module.exports = {premiumWebhook};
