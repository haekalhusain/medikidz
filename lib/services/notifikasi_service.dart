import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medikidz/models/notifikasi_model.dart';

class NotifikasiService {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('tb_notifikasi');
  final CollectionReference<Map<String, dynamic>> _penggunaCollection =
      FirebaseFirestore.instance.collection('tb_pengguna');

  Stream<List<Notifikasi>> streamForUser(String uid, {int limit = 50}) {
    return _collection
        .where('uid', isEqualTo: uid)
        .orderBy('waktu', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Notifikasi.fromJson(doc.data(), doc.id)).toList());
  }

  Stream<List<Notifikasi>> streamAll({int limit = 100}) {
    return _collection
        .orderBy('waktu', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Notifikasi.fromJson(doc.data(), doc.id)).toList());
  }

  Future<String> create(Notifikasi item) async {
    final docRef = await _collection.add(item.toJson());
    return docRef.id;
  }

  Future<void> createForUser(String uid, Notifikasi item) async {
    await _collection.add(item.toJson());
  }

  Future<void> broadcastToUsers({
    required String judul,
    required String pesan,
    required String kategori,
  }) async {
    final snapshot = await _penggunaCollection.where('role', isEqualTo: 'user').get();
    final batch = FirebaseFirestore.instance.batch();

    for (final doc in snapshot.docs) {
      final ref = _collection.doc();
      final notifikasi = Notifikasi(
        uid: doc.id,
        judul: judul,
        pesan: pesan,
        kategori: kategori,
        waktu: DateTime.now(),
      );
      batch.set(ref, notifikasi.toJson());
    }

    if (snapshot.docs.isNotEmpty) {
      await batch.commit();
    }
  }

  Future<void> update(String id, Notifikasi item) async {
    await _collection.doc(id).update(item.toJson());
  }

  Future<void> delete(String id) async {
    await _collection.doc(id).delete();
  }

  Future<void> markAsRead(String id) async {
    await _collection.doc(id).update({'terbaca': true});
  }

  Future<void> markAllRead(String uid) async {
    final snapshot = await _collection.where('uid', isEqualTo: uid).where('terbaca', isEqualTo: false).get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'terbaca': true});
    }
    if (snapshot.docs.isNotEmpty) {
      await batch.commit();
    }
  }
}
