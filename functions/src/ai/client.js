const AI_API_BASE_URL = process.env.AI_API_BASE_URL;
const AI_MODEL = process.env.AI_MODEL;

const MAX_ATTEMPTS = 3;
const RETRY_DELAYS_MS = [2000, 5000];

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function isRateLimited(status, body) {
  if (status === 429) return true;
  return body && body.error && body.error.status === "RESOURCE_EXHAUSTED";
}

function describeError(status, body) {
  const error = body && body.error;
  if (error) {
    const parts = [error.message, error.status && `(status: ${error.status})`].filter(Boolean);
    if (parts.length) return `AI değerlendirme hatası: ${parts.join(" — ")}`;
  }
  return `AI değerlendirme isteği başarısız (HTTP ${status}).`;
}

// Sends a single-turn image+text prompt to the Gemini generateContent API
// and returns the extracted text response, retrying on rate limiting.
async function generateContent({apiKey, prompt, base64Image, mimeType}) {
  const endpoint = `${AI_API_BASE_URL}/models/${AI_MODEL}:generateContent`;
  const body = {
    contents: [
      {
        parts: [
          {text: prompt},
          {inline_data: {mime_type: mimeType, data: base64Image}},
        ],
      },
    ],
    generationConfig: {temperature: 0.2, maxOutputTokens: 4096},
  };

  let lastStatus;
  let lastBody;

  for (let attempt = 0; attempt < MAX_ATTEMPTS; attempt++) {
    const response = await fetch(endpoint, {
      method: "POST",
      headers: {
        "X-goog-api-key": apiKey,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(body),
    });

    if (response.ok) {
      const data = await response.json();
      const content = data && data.candidates && data.candidates[0] &&
        data.candidates[0].content && data.candidates[0].content.parts &&
        data.candidates[0].content.parts[0] && data.candidates[0].content.parts[0].text;
      if (!content || !content.trim()) {
        const finishReason = data && data.candidates && data.candidates[0] &&
          data.candidates[0].finishReason;
        throw new Error(
            finishReason ?
              `AI boş bir yanıt döndürdü (finishReason: ${finishReason}).` :
              "AI boş bir yanıt döndürdü.",
        );
      }
      return content;
    }

    lastStatus = response.status;
    lastBody = await response.json().catch(() => null);
    if (!isRateLimited(lastStatus, lastBody) || attempt === MAX_ATTEMPTS - 1) {
      throw new Error(describeError(lastStatus, lastBody));
    }
    await sleep(RETRY_DELAYS_MS[attempt]);
  }

  throw new Error(describeError(lastStatus, lastBody));
}

module.exports = {generateContent};
