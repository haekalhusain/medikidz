const functions = require("firebase-functions");
const { db, admin } = require("./db");

const sendFcmOnNotificationCreate = functions.firestore
  .document("tb_notifikasi/{notifikasiId}")
  .onCreate(async (snapshot, context) => {
    const data = snapshot.data();
    if (!data) return null;

    const uid = data.uid;
    if (!uid) return null;

    const penggunaDoc = await db.collection("tb_pengguna").doc(uid).get();
    if (!penggunaDoc.exists) return null;

    const penggunaData = penggunaDoc.data();
    if (!penggunaData || !penggunaData.fcm_token) return null;

    const message = {
      token: penggunaData.fcm_token,
      notification: {
        title: data.judul || "Notifikasi Medikidz",
        body: data.pesan || "",
      },
      data: {
        kategori: data.kategori || "jadwal",
        notifikasiId: snapshot.id,
      },
    };

    try {
      await admin.messaging().send(message);
    } catch (error) {
      console.error("FCM send error:", error);
    }

    return null;
  });

module.exports = { sendFcmOnNotificationCreate };
