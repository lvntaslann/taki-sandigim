const {onRequest} = require("firebase-functions/v2/https");
const {defineSecret} = require("firebase-functions/params");
const {isPremiumUser} = require("../users/repository");
const {consumeFreeQuota} = require("./rateLimit");
const {generateContent} = require("./client");
const promptTemplates = require("./promptTemplates");
const {parseNotebookLines, parseInvitation} = require("./parse");

const aiApiKey = defineSecret("AI_API_KEY");

const VALID_TYPES = new Set(["notebook", "invitation"]);

// Flutter → this function → Gemini → this function → Flutter. Keeps the AI
// provider, model and prompts entirely server-side so they can change
// without a Play Store release. Caller identity is the RevenueCat
// appUserId (this app has no Firebase Auth) — see PurchaseService.appUserId.
const aiEvaluate = onRequest(
    {
      secrets: [aiApiKey],
      region: "europe-west1",
      enforceAppCheck: true,
    },
    async (req, res) => {
      if (req.method !== "POST") {
        res.status(405).send("Method Not Allowed");
        return;
      }

      const {appUserId, type, ocrText, imageBase64, mimeType} = req.body || {};

      if (!appUserId || typeof appUserId !== "string") {
        res.status(400).json({error: "Missing appUserId"});
        return;
      }
      if (!VALID_TYPES.has(type)) {
        res.status(400).json({error: "type must be 'notebook' or 'invitation'"});
        return;
      }
      if (!imageBase64 || typeof imageBase64 !== "string") {
        res.status(400).json({error: "Missing imageBase64"});
        return;
      }
      if (typeof ocrText !== "string") {
        res.status(400).json({error: "Missing ocrText"});
        return;
      }

      try {
        const premium = await isPremiumUser(appUserId);
        if (!premium) {
          const allowed = await consumeFreeQuota(appUserId);
          if (!allowed) {
            res.status(429).json({error: "Günlük ücretsiz tarama hakkın bitti."});
            return;
          }
        }

        const prompt = type === "notebook" ?
          promptTemplates.notebook({ocrText}) :
          promptTemplates.invitation({ocrText});

        const content = await generateContent({
          apiKey: aiApiKey.value(),
          prompt,
          base64Image: imageBase64,
          mimeType: mimeType || "image/jpeg",
        });

        if (type === "notebook") {
          res.status(200).json({lines: parseNotebookLines(content)});
        } else {
          res.status(200).json({invitation: parseInvitation(content)});
        }
      } catch (error) {
        console.error("aiEvaluate failed", error);
        res.status(500).json({error: error.message || "AI değerlendirme isteği başarısız."});
      }
    },
);

module.exports = {aiEvaluate};
