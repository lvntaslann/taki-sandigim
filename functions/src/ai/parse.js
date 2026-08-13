function extractJson(content, {opening, closing}) {
  const start = content.indexOf(opening);
  const end = content.lastIndexOf(closing);
  if (start === -1 || end === -1 || end < start) {
    throw new Error(`AI yanıtında geçerli bir JSON bulunamadı ("${opening}...${closing}").`);
  }
  return JSON.parse(content.substring(start, end + 1));
}

function parseNotebookLines(content) {
  const decoded = extractJson(content, {opening: "[", closing: "]"});
  if (!Array.isArray(decoded)) {
    throw new Error("AI yanıtı beklenen JSON dizisi formatında değil.");
  }
  return decoded
      .filter((entry) => entry && typeof entry === "object")
      .map((entry) => {
        const personName = (entry.personName || "").toString().trim();
        const giftDescription = (entry.giftDescription || "").toString().trim();
        const amount = typeof entry.amount === "number" ? entry.amount : null;
        return {personName, giftDescription, amount};
      })
      .filter((line) => line.personName.length > 0);
}

function parseInvitation(content) {
  const decoded = extractJson(content, {opening: "{", closing: "}"});
  if (!decoded || typeof decoded !== "object" || Array.isArray(decoded)) {
    throw new Error("AI yanıtı beklenen JSON nesnesi formatında değil.");
  }
  return {
    title: (decoded.title || "").toString().trim(),
    date: decoded.date || null,
    time: decoded.time ? decoded.time.toString().trim() : null,
    location: decoded.location ? decoded.location.toString().trim() : null,
  };
}

module.exports = {parseNotebookLines, parseInvitation};
