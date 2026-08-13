const admin = require("firebase-admin");

admin.initializeApp();

const {premiumWebhook} = require("./src/premium/webhook");
const {aiEvaluate} = require("./src/ai/evaluate");

exports.premiumWebhook = premiumWebhook;
exports.aiEvaluate = aiEvaluate;
