const { register, resendOtp, verifyOtp } = require("./lib/auth");
const { scheduleJadwalNotifications } = require("./lib/scheduleNotifications");
const { sendFcmOnNotificationCreate } = require("./lib/sendFcm");

// Auth & registrasi
exports.register = register;
exports.resendOtp = resendOtp;
exports.verifyOtp = verifyOtp;

// Notifikasi: 1x cron/hari, cek semua offset (H-3/H-2/H-1/H-0) sekaligus.
// Query terarah ke tb_anak (aktif saja) + tb_jadwalImunisasi (hanya dosis
// yang relevan hari ini) -- BUKAN scan seluruh koleksi.
exports.scheduleJadwalNotifications = scheduleJadwalNotifications;

// Kirim push FCM saat dokumen notifikasi dibuat
exports.sendFcmOnNotificationCreate = sendFcmOnNotificationCreate;
