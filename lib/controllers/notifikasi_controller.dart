import 'package:get/get.dart';
import '../models/notifikasi_model.dart';
import '../services/auth_service.dart';
import '../services/notifikasi_service.dart';

class NotifikasiController extends GetxController {
  final _service = NotifikasiService();

  var notifikasiList = <Notifikasi>[].obs;
  var unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final uid = AuthService().currentUser?.uid;
    if (uid != null) {
      _service.streamForUser(uid).listen((items) {
        notifikasiList.assignAll(items);
        unreadCount.value = items.where((item) => !item.terbaca).length;
      });
    }
  }

  Future<void> markAsRead(String id) async {
    await _service.markAsRead(id);
  }

  Future<void> markAllRead() async {
    final uid = AuthService().currentUser?.uid;
    if (uid == null) return;
    await _service.markAllRead(uid);
  }
}

class AdminNotifikasiController extends GetxController {
  final _service = NotifikasiService();

  var notifikasiList = <Notifikasi>[].obs;
  var isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    _service.streamAll().listen((items) {
      notifikasiList.assignAll(items);
    });
  }

  Future<void> createBroadcast({
    required String judul,
    required String pesan,
    required String kategori,
  }) async {
    isSubmitting.value = true;
    try {
      await _service.broadcastToUsers(
        judul: judul,
        pesan: pesan,
        kategori: kategori,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> sendToUser({
    required String uid,
    required String judul,
    required String pesan,
    required String kategori,
  }) async {
    isSubmitting.value = true;
    try {
      await _service.createForUser(
        uid,
        Notifikasi(
          uid: uid,
          judul: judul,
          pesan: pesan,
          kategori: kategori,
          waktu: DateTime.now(),
        ),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> updateNotification(String id, Notifikasi item) async {
    await _service.update(id, item);
  }

  Future<void> deleteNotification(String id) async {
    await _service.delete(id);
  }
}
