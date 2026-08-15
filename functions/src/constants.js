const PREMIUM_ENTITLEMENT_ID = "Takı Sandığım Pro";
const USERS_COLLECTION = "users";
const AI_USAGE_COLLECTION = "ai_usage";

// Rate limits live in .env (not hardcoded) so they can be tuned without
// touching code. Premium isn't literally unlimited — a generous-but-bounded
// cap protects against a fake/free Test Store "purchase" (or a bug, or
// abuse) driving up real Gemini API cost. Rolling window, same shape as the
// app's free-tier scan limit (ScanUsageRepository).
const AI_FREE_DAILY_LIMIT = Number(process.env.AI_FREE_DAILY_LIMIT);
const AI_PREMIUM_LIMIT = Number(process.env.AI_PREMIUM_LIMIT);
const AI_PREMIUM_WINDOW_MS = Number(process.env.AI_PREMIUM_WINDOW_HOURS) * 60 * 60 * 1000;

module.exports = {
  PREMIUM_ENTITLEMENT_ID,
  USERS_COLLECTION,
  AI_USAGE_COLLECTION,
  AI_FREE_DAILY_LIMIT,
  AI_PREMIUM_LIMIT,
  AI_PREMIUM_WINDOW_MS,
};
