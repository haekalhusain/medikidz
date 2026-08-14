import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'dart:math';
import '../firebase_options.dart';
import '../views/user/anak/anak_saya_list_page.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('FCM background message received: ${message.messageId}');
}

class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'medikidz_notifications',
    'Notifikasi Medikidz',
    description: 'Notifikasi penting dari aplikasi Medikidz',
    importance: Importance.high,
  );

  Future<void> init() async {
    if (_initialized) return;

    await _requestPermission();
    await _setupLocalNotifications();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    _messaging.onTokenRefresh.listen(_saveToken);
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    await _saveToken();
    await _handleInitialMessage();

    _initialized = true;
  }

  Future<NotificationSettings> getNotificationSettings() async {
    return _messaging.getNotificationSettings();
  }

  Future<void> requestPermissionIfNeeded() async {
    await _requestPermission();
    if (FirebaseAuth.instance.currentUser != null) {
      await saveTokenForCurrentUser();
    }
  }

  Future<void> _handleInitialMessage() async {
    final message = await FirebaseMessaging.instance.getInitialMessage();
    if (message != null) {
      await _handleMessageAction(message: message);
    }
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('FCM permission denied');
      return;
    }

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('FCM permission authorized');
      if (FirebaseAuth.instance.currentUser != null) {
        await saveTokenForCurrentUser();
      }
    }
  }

  Future<void> _setupLocalNotifications() async {
    if (kIsWeb) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    await _localNotifications.initialize(
      settings: const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    if (!kIsWeb) {
      await _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(AndroidNotificationChannel(
            _channel.id,
            _channel.name,
            description: _channel.description,
            importance: _channel.importance,
          ));
    }
  }

  Future<void> _saveToken([String? token]) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final fcmToken = token ?? await _messaging.getToken();
    if (fcmToken == null || fcmToken.isEmpty) return;

    final docRef = FirebaseFirestore.instance.collection('tb_pengguna').doc(user.uid);
    await docRef.set({'fcm_token': fcmToken}, SetOptions(merge: true));
  }

  Future<void> saveTokenForCurrentUser() async {
    await _saveToken();
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final title = message.notification?.title ?? 'Medikidz';
    final body = message.notification?.body ?? '';
    await _showLocalNotification(title, body, message.data);
  }

  Future<void> _handleMessageAction({RemoteMessage? message, String? payload}) async {
    final category = message?.data['kategori'] ?? payload;
    if (category == 'jadwal') {
      Get.to(() => const AnakSayaListPage());
    }
  }

  Future<void> _showLocalNotification(String title, String body, Map<String, dynamic> data) async {
    if (kIsWeb) return;

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 250, 250, 250]),
        enableLights: true,
        color: const Color.fromARGB(255, 0, 112, 192),
        ledColor: const Color.fromARGB(255, 0, 112, 192),
        ledOnMs: 1000,
        ledOffMs: 3000,
        icon: '@mipmap/ic_launcher',
        fullScreenIntent: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    final payload = data['kategori'] == 'jadwal' ? 'jadwal' : data['notifikasiId']?.toString();
    // Generate unique ID to prevent notification collision
    final uniqueId = Random().nextInt(2147483647);
    await _localNotifications.show(
      id: uniqueId,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('FCM message opened app: ${message.messageId}');
    _handleMessageAction(message: message);
  }

  void _onNotificationResponse(NotificationResponse response) {
    debugPrint('Local notification tapped: ${response.payload}');
    if (response.payload == 'jadwal') {
      _handleMessageAction(payload: 'jadwal');
    }
  }
}
