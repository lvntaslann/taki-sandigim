const admin = require("firebase-admin");

admin.initializeApp();

const {premiumWebhook} = require("./src/premium/webhook");

// Future functions (e.g. an AI proxy) get added here the same way, each
// living under its own src/<domain>/ folder.
exports.premiumWebhook = premiumWebhook;
