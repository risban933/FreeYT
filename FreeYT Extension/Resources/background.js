/* global chrome */
const DEBUG = false;

const RULESET_ID = "redirectRules";
const STORAGE_KEYS = {
  enabled: "enabled",
  stats: "stats",
  firstRun: "firstRun"
};

const defaultStats = () => ({
  total: 0,
  today: 0,
  lastRedirectAt: null,
  lastResetDate: new Date().toISOString().slice(0, 10) // YYYY-MM-DD
});

async function getEnabled() {
  const { [STORAGE_KEYS.enabled]: enabled } = await chrome.storage.local.get(STORAGE_KEYS.enabled);
  return typeof enabled === "boolean" ? enabled : true;
}

async function setEnabled(enabled) {
  await chrome.storage.local.set({ [STORAGE_KEYS.enabled]: enabled });
  try {
    if (enabled) {
      await chrome.declarativeNetRequest.updateEnabledRulesets({ enableRulesetIds: [RULESET_ID], disableRulesetIds: [] });
    } else {
      await chrome.declarativeNetRequest.updateEnabledRulesets({ enableRulesetIds: [], disableRulesetIds: [RULESET_ID] });
    }
  } catch (e) {
    if (DEBUG) console.error("updateEnabledRulesets failed", e);
    throw e;
  }
  await updateBadge();
}

async function getStats() {
  let { [STORAGE_KEYS.stats]: stats } = await chrome.storage.local.get(STORAGE_KEYS.stats);
  const created = !stats;
  stats = stats || defaultStats();
  const { stats: normalized, changed } = maybeResetToday(stats);
  if (changed || created) {
    await saveStats(normalized);
  }
  return normalized;
}

async function saveStats(stats) {
  await chrome.storage.local.set({ [STORAGE_KEYS.stats]: stats });
}

function maybeResetToday(stats) {
  const todayStr = new Date().toISOString().slice(0, 10);
  if (stats.lastResetDate !== todayStr) {
    return {
      stats: { ...stats, today: 0, lastResetDate: todayStr },
      changed: true
    };
  }
  return { stats, changed: false };
}

async function incrementRedirectCounter() {
  let stats = await getStats();
  stats.today += 1;
  stats.total += 1;
  stats.lastRedirectAt = new Date().toISOString();
  await saveStats(stats);
  await updateBadge();
  return stats;
}

async function updateBadge() {
  const enabled = await getEnabled();
  const stats = await getStats();
  const text = enabled ? String(stats.today || 0) : "";
  try {
    await chrome.action.setBadgeText({ text });
    // background color optional in Safari; safe no-op elsewhere
    await chrome.action.setBadgeBackgroundColor?.({ color: enabled ? [0, 200, 83, 255] : [128, 128, 128, 255] });
  } catch (_) {}
}

// Listen to DNR matches (requires declarativeNetRequestFeedback)
if (chrome.declarativeNetRequest?.onRuleMatchedDebug) {
  chrome.declarativeNetRequest.onRuleMatchedDebug.addListener(async (info) => {
    try {
      // Count only our redirect rules (1-5)
      if ([1, 2, 3, 4, 5].includes(info?.rule?.ruleId)) {
        await incrementRedirectCounter();
        // Notify popup (if open)
        const ping = chrome.runtime.sendMessage({ type: "statsUpdated" });
        ping?.catch?.(() => {});
      }
    } catch (e) {
      if (DEBUG) console.error("onRuleMatchedDebug error", e);
    }
  });
}

// Messages from popup
chrome.runtime.onMessage.addListener((msg, _sender, sendResponse) => {
  (async () => {
    try {
      if (msg?.type === "getState") {
        const [enabled, stats] = await Promise.all([getEnabled(), getStats()]);
        sendResponse({ ok: true, enabled, stats });
      } else if (msg?.type === "setEnabled") {
        await setEnabled(!!msg.enabled);
        const [enabled, stats] = await Promise.all([getEnabled(), getStats()]);
        sendResponse({ ok: true, enabled, stats });
      } else {
        sendResponse({ ok: false, error: "Unknown message" });
      }
    } catch (e) {
      sendResponse({ ok: false, error: String(e?.message || e) });
    }
  })();
  return true; // async
});

// Init defaults on install/activate
chrome.runtime.onInstalled.addListener(async () => {
  const store = await chrome.storage.local.get([STORAGE_KEYS.enabled, STORAGE_KEYS.stats, STORAGE_KEYS.firstRun]);
  if (store[STORAGE_KEYS.enabled] === undefined) await chrome.storage.local.set({ [STORAGE_KEYS.enabled]: true });
  if (!store[STORAGE_KEYS.stats]) await chrome.storage.local.set({ [STORAGE_KEYS.stats]: defaultStats() });
  if (store[STORAGE_KEYS.firstRun] === undefined) await chrome.storage.local.set({ [STORAGE_KEYS.firstRun]: true });

  // Ensure ruleset matches toggle
  const enabled = await getEnabled();
  await setEnabled(enabled);
  await updateBadge();
});

chrome.runtime.onStartup?.addListener(updateBadge);
