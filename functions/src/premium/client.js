const PREMIUM_API_BASE_URL = process.env.PREMIUM_API_BASE_URL;

async function fetchSubscriber(appUserId, apiKey) {
  const response = await fetch(
      `${PREMIUM_API_BASE_URL}/subscribers/${encodeURIComponent(appUserId)}`,
      {headers: {Authorization: `Bearer ${apiKey}`}},
  );
  if (!response.ok) {
    throw new Error(`Premium provider lookup failed with status ${response.status}`);
  }
  return response.json();
}

function isEntitlementActive(subscriberData, entitlementId) {
  const entitlement = subscriberData?.subscriber?.entitlements?.[entitlementId];
  if (!entitlement) return false;
  return entitlement.expires_date === null ||
    new Date(entitlement.expires_date).getTime() > Date.now();
}

module.exports = {fetchSubscriber, isEntitlementActive};
