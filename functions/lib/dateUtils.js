function pad2(n) {
  return n.toString().padStart(2, "0");
}

// Ambil hanya komponen tanggal kalender dari string ISO Flutter
// (contoh: "2026-05-01T00:00:00.000") tanpa terpengaruh timezone server.
function extractDateOnly(isoLikeString) {
  if (!isoLikeString || typeof isoLikeString !== "string") return null;
  const datePart = isoLikeString.split("T")[0];
  if (!/^\d{4}-\d{2}-\d{2}$/.test(datePart)) return null;
  const [y, m, d] = datePart.split("-").map(Number);
  return { y, m, d };
}

function dateOnlyToUtcDate({ y, m, d }) {
  return new Date(Date.UTC(y, m - 1, d));
}

function toIsoDateString(date) {
  return `${date.getUTCFullYear()}-${pad2(date.getUTCMonth() + 1)}-${pad2(date.getUTCDate())}`;
}

// Batas awal/akhir satu hari kalender, dalam format string yang sama
// dengan DateTime(...).toIso8601String() milik Dart (tanpa 'Z').
function dayStartIsoString(date) {
  return `${toIsoDateString(date)}T00:00:00.000`;
}
function dayEndIsoString(date) {
  return `${toIsoDateString(date)}T23:59:59.999`;
}

function addDaysUtc(date, days) {
  const d = new Date(date.getTime());
  d.setUTCDate(d.getUTCDate() + days);
  return d;
}

function todayUtc() {
  const now = new Date();
  return new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()));
}

module.exports = {
  extractDateOnly,
  dateOnlyToUtcDate,
  toIsoDateString,
  dayStartIsoString,
  dayEndIsoString,
  addDaysUtc,
  todayUtc,
};
