const functions = require("firebase-functions");
const axios = require("axios");
const { v4: uuidv4 } = require("uuid");
const bcrypt = require("bcryptjs");
const { db, admin } = require("./db");

const SESSION_COLLECTION = "_registrasi_sessions";
const OTP_EXPIRY_MINUTES = 5;
const SESSION_EXPIRY_MINUTES = 15;

const FONNTE_TOKEN = functions.config().fonnte?.token || "GANTI_DENGAN_TOKEN_FONNTE";

function normalizePhone(phone) {
  let cleaned = phone.replace(/\D/g, "");
  if (cleaned.startsWith("0")) cleaned = "62" + cleaned.substring(1);
  return cleaned;
}

async function sendWhatsAppOtp(phone, otp) {
  await axios.post(
    "https://api.fonnte.com/send",
    {
      target: phone,
      message: `Kode verifikasi Medikidz Anda: ${otp}\n\nJangan berikan kode ini kepada siapapun. Berlaku ${OTP_EXPIRY_MINUTES} menit.`,
    },
    { headers: { Authorization: FONNTE_TOKEN } }
  );
}

const register = functions.https.onRequest(async (req, res) => {
  if (req.method !== "POST") return res.status(405).json({ success: false, message: "Method not allowed" });

  const { no_hp, tanggal_lahir, nama_orang_tua, nama_anak, tanggal_lahir_anak, jenis_kelamin_anak } = req.body;

  if (!no_hp || !tanggal_lahir || !nama_orang_tua || !nama_anak || !tanggal_lahir_anak || !jenis_kelamin_anak) {
    return res.status(400).json({ success: false, message: "Semua field wajib diisi." });
  }

  const phone = normalizePhone(no_hp);

  const existing = await db.collection("tb_pengguna").where("no_hp", "==", phone).limit(1).get();
  if (!existing.empty) {
    return res.status(409).json({ success: false, message: "Nomor HP ini sudah terdaftar. Silakan login." });
  }

  const registrationToken = uuidv4();
  const otp = Math.floor(100000 + Math.random() * 900000);

  await db.collection(SESSION_COLLECTION).doc(registrationToken).set({
    no_hp: phone,
    tanggal_lahir,
    nama_orang_tua,
    nama_anak,
    tanggal_lahir_anak,
    jenis_kelamin_anak,
    otp_code: otp,
    otp_attempts: 0,
    expires_at: admin.firestore.Timestamp.fromMillis(Date.now() + SESSION_EXPIRY_MINUTES * 60 * 1000),
  });

  await sendWhatsAppOtp(phone, otp);

  return res.status(200).json({ success: true, data: { registration_token: registrationToken } });
});

const resendOtp = functions.https.onRequest(async (req, res) => {
  if (req.method !== "POST") return res.status(405).json({ success: false, message: "Method not allowed" });

  const { registration_token } = req.body;
  const ref = db.collection(SESSION_COLLECTION).doc(registration_token);
  const doc = await ref.get();

  if (!doc.exists) return res.status(410).json({ success: false, message: "Sesi registrasi kadaluarsa." });

  const data = doc.data();
  const otp = Math.floor(100000 + Math.random() * 900000);

  await ref.update({ otp_code: otp, otp_attempts: 0 });
  await sendWhatsAppOtp(data.no_hp, otp);

  return res.status(200).json({ success: true, message: "Kode OTP baru telah dikirim." });
});

const verifyOtp = functions.https.onRequest(async (req, res) => {
  if (req.method !== "POST") return res.status(405).json({ success: false, message: "Method not allowed" });

  const { registration_token, otp, password } = req.body;

  if (!registration_token || !otp || !password || password.length < 8) {
    return res.status(400).json({ success: false, message: "Data tidak lengkap / password minimal 8 karakter." });
  }

  const sessionRef = db.collection(SESSION_COLLECTION).doc(registration_token);
  const sessionDoc = await sessionRef.get();

  if (!sessionDoc.exists) return res.status(410).json({ success: false, message: "Sesi kadaluarsa." });

  const session = sessionDoc.data();

  if (session.otp_attempts >= 3) {
    return res.status(429).json({ success: false, message: "Terlalu banyak percobaan, minta OTP baru." });
  }

  if (String(session.otp_code) !== String(otp)) {
    await sessionRef.update({ otp_attempts: admin.firestore.FieldValue.increment(1) });
    return res.status(422).json({ success: false, message: "Kode OTP salah." });
  }

  const passwordHash = await bcrypt.hash(password, 10);

  const penggunaRef = db.collection("tb_pengguna").doc();
  const anakRef = db.collection("tb_anak").doc();

  const batch = db.batch();

  batch.set(penggunaRef, {
    nama: session.nama_orang_tua,
    no_hp: session.no_hp,
    tanggal_lahir: session.tanggal_lahir,
    role: "user",
    password_hash: passwordHash,
    created_at: admin.firestore.FieldValue.serverTimestamp(),
  });

  batch.set(anakRef, {
    id_user: penggunaRef.id,
    nama_anak: session.nama_anak,
    tanggal_lahir: session.tanggal_lahir_anak,
    jenis_kelamin: session.jenis_kelamin_anak,
    deleted_at: null,
    created_at: admin.firestore.FieldValue.serverTimestamp(),
  });

  await batch.commit();
  await sessionRef.delete();

  return res.status(201).json({ success: true, data: { id_user: penggunaRef.id, id_anak: anakRef.id } });
});

module.exports = { register, resendOtp, verifyOtp };
