import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

class NotificationService extends GetxService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<NotificationService> init() async {
    // طلب الصلاحيات
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    // معالجة الرسائل عند النقر عليها (التطبيق مغلق أو في الخلفية)
    _setupInteractedMessages();

    // الاستماع للرسائل والتطبيق مفتوح (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('🔔 [FCM Foreground] Received:');
      _printFullMessage(message);
    });

    return this;
  }

  void _setupInteractedMessages() async {
    // 1. إذا كان التطبيق مغلقاً تماماً (Terminated) وتم فتحه عبر الإشعار
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      log('📱 [FCM Terminated] App opened via notification:');
      _handleMessage(initialMessage);
    }

    // 2. إذا كان التطبيق في الخلفية (Background) وتم النقر على الإشعار
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      log('🔙 [FCM Background] Notification clicked:');
      _handleMessage(message);
    });
  }

  void _handleMessage(RemoteMessage message) {
    _printFullMessage(message);
    final data = message.data;

    if (data['type'] == "order:driverRequest" || data['orderId'] != null) {
      Get.toNamed('/new-order', arguments: data);
    }
  }

  // دالة مخصصة لطباعة تفاصيل الإشعار بشكل مرتب
  void _printFullMessage(RemoteMessage message) {
    log('---------------- FCM PAYLOAD START ----------------');
    log('Title: ${message.notification?.title}');
    log('Body: ${message.notification?.body}');
    log('Data (Map): ${message.data}');
    log('----------------- FCM PAYLOAD END -----------------');
  }
}