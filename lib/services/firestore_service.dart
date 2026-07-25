import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService<T> {
  final String collectionPath;
  final T Function(Map<String, dynamic> json, String id) fromJson;
  final Map<String, dynamic> Function(T item) toJson;

  FirestoreService({
    required this.collectionPath,
    required this.fromJson,
    required this.toJson,
  });

  CollectionReference<Map<String, dynamic>> get _collection =>
      FirebaseFirestore.instance.collection(collectionPath);

  Stream<List<T>> streamAll({String? orderBy, bool descending = false}) {
    Query<Map<String, dynamic>> query = _collection;
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }
    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => fromJson(doc.data(), doc.id)).toList());
  }

  Future<List<T>> getAll({String? orderBy, bool descending = false}) async {
    Query<Map<String, dynamic>> query = _collection;
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => fromJson(doc.data(), doc.id)).toList();
  }

  Future<T?> getById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return fromJson(doc.data()!, doc.id);
  }

  Future<List<T>> getWhere(String field, dynamic isEqualTo) async {
    final snapshot = await _collection.where(field, isEqualTo: isEqualTo).get();
    return snapshot.docs.map((doc) => fromJson(doc.data(), doc.id)).toList();
  }

  Future<String> create(T item) async {
    final docRef = await _collection.add(toJson(item));
    return docRef.id;
  }

  Future<void> update(String id, T item) async {
    await _collection.doc(id).update(toJson(item));
  }

  Future<void> delete(String id) async {
    await _collection.doc(id).delete();
  }

  Future<void> softDelete(String id) async {
    await _collection.doc(id).update({'deleted_at': FieldValue.serverTimestamp()});
  }
}
