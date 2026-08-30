import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

import '../../features/navigation/presentation/controllers/navigation_controller.dart';
import '../../features/wallet/presentation/controllers/wallet_controller.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';

class SocketService extends GetxService {
  static final SocketService _instance = SocketService._internal();

  factory SocketService() => _instance;

  SocketService._internal();

  IO.Socket? socket;
  final _storage = GetStorage();

  void connect() {
    String? token = _storage.read('token');

    if (token == null) {
      log("❌ Socket: No token found, cannot connect.");
      return;
    }

    // الربط مع الاستضافة
    socket = IO.io(
      'https://nomnow-o4ba.onrender.com/driver',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableAutoConnect()
          .build(),
    );

    socket!.onConnect((_) {
      log('✅ Connected to Driver Socket Namespace');
      _setupGlobalListeners(); // تفعيل المستمعات العالمية فور الاتصال
      getActiveOrder(); // محاولة استعادة أي طلب نشط فور الاتصال
    });

    socket!.onDisconnect((_) => log('❌ Disconnected from Driver Socket'));
    socket!.onConnectError((err) => log('⚠️ Connection Error: $err'));
  }

  // --- مستمعات عالمية (تنبيهات النظام والطلبات) ---

  void _setupGlobalListeners() {
    // 1. الاستماع لطلبات الأوردرات الجديدة بمختلف المسميات من السيرفر
    socket?.on("order:newOrder", (data) => _handleNewOrder(data));
    socket?.on("order:newRequest", (data) => _handleNewOrder(data));
    socket?.on("order:driverRequest", (data) => _handleNewOrder(data));

    // 2. الاستماع لتأكيد السيرفر على قبول السائق للطلب (الانتقال للتفاصيل)
    socket?.on("order:driverRequest:accepted", (data) {
      log("✅ Server confirmed acceptance. Moving to Details.");

      // ✅ استخراج البيانات: السيرفر يرسل { success: true, order: { ... } }
      final orderData = data is Map && data.containsKey('order')
          ? data['order']
          : data;

      if (orderData != null) {
        if (Get.isOverlaysOpen) Get.back(); // إغلاق أي Loading Dialog
        Get.offAllNamed('/details-order', arguments: orderData);
      }
    });

    // 3. الاستماع لحالة انتهاء صلاحية الطلب (إذا قبله سائق آخر)
    socket?.on("order:driverRequest:expired", (data) {
      if (Get.isOverlaysOpen) Get.back();
      Get.snackbar(
        "تنبيه",
        data['message'] ?? "عذراً، هذا الطلب لم يعد متاحاً",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      if (Get.currentRoute == '/new-order') Get.back();
    });

    // 4. الاستماع للطلب النشط (عند إعادة فتح التطبيق)
    socket?.on("order:activeOrder", (data) {
      log("📦 Active order received: $data");
      if (data != null) {
        Get.offAllNamed('/details-order', arguments: data);
      }
    });

    // 5. الاستماع لتجاوز حد الكاش (خاص بسوريا)
    socket?.on("order:cashLimit:exceeded", (data) {
      if (Get.isOverlaysOpen) Get.back();
      Get.defaultDialog(
        title: "تنبيه الحد الائتماني",
        middleText: "لقد تجاوزت حد الكاش المسموح به (${data['cashCreditLimit'] ??
            ''}). يرجى تسوية المبالغ المحصلة أولاً لتتمكن من قبول طلبات جديدة.",
        textConfirm: "ذهاب للمحفظة",
        confirmTextColor: Colors.white,
        onConfirm: () {
          Get.back();
          Get.toNamed('/main-navigation');
          Get.find<NavigationController>().changePage(1); // صفحة المحفظة
        },
        textCancel: "إغلاق",
      );
    });

    // 6. تحديث حالة السائق (Online/Offline/Busy)
    socket?.on("driver:currentStatus", (data) {
      if (Get.isRegistered<AuthController>()) {
        final authController = Get.find<AuthController>();
        authController.driverData['availability'] = data['availability'];
        authController.driverData.refresh();
      }
    });

    // 7. تحديثات حالة الطلب (التوصيل، الإلغاء، إلخ)
    socket?.on("order:statusUpdated", (data) async {
      log("🔄 Order status updated: ${data['status']}");

      if (data['status'] == 'delivered') {
        await Future.delayed(const Duration(seconds: 1));
        if (Get.isRegistered<WalletController>()) {
          Get.find<WalletController>().fetchAllWalletData(); // تحديث المحفظة
        }
        Get.snackbar(
          "success_snack_title".tr,
          "success_snack_msg".tr,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        if (Get.currentRoute != '/main-navigation') {
          Get.offAllNamed('/main-navigation');
        }
      }
    });

    // 8. الاستماع لأخطاء تغيير الحالة
    socket?.on("driver:goOnline:error", (data) => _handleStatusError(data));
    socket?.on("driver:goOffline:error", (data) => _handleStatusError(data));

    // 9. الاستماع للأخطاء العامة من السيرفر
    socket?.on("order:error", (data) {
      if (Get.isOverlaysOpen) Get.back();
      Get.snackbar(
        "تنبيه",
        data['message'] ?? "خطأ في الطلب",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    });
  }

  // --- الدوال المساعدة ---

  void _handleStatusError(dynamic data) {
    String msg = data['message'] ?? "يرجى الانتظار لتأكيد الطلب";
    if (data['remainingMinutes'] != null) {
      msg = "$msg (متبقي ${data['remainingMinutes']} دقيقة)";
    }
    Get.snackbar(
      "تنبيه النظام",
      msg,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
    );
  }

  void _handleNewOrder(dynamic data) {
    log("🚀 Order Signal Received: $data");
    if (Get.currentRoute == '/new-order') return;

    final orderData = data is Map && data.containsKey('order')
        ? data['order']
        : data;
    if (orderData != null) {
      Get.toNamed('/new-order', arguments: orderData);
    }
  }

  // --- الدوال التنفيذية (Emitters) ---

  void getActiveOrder() => socket?.emit("order:getActiveOrder");

  void goOnline() => socket?.emit("driver:goOnline");

  void goOffline() => socket?.emit("driver:goOffline");

  void updateLocation(double lat, double lng) {
    socket?.emit("driver:updateLocation", {"lat": lat, "lng": lng});
  }

  void confirmPickUp(String orderId) {
    socket?.emit("order:pickup", {"orderId": orderId});
  }

  void respondToOrder(String orderId, String response) {
    socket?.emit(
        "order:driverResponse", {"orderId": orderId, "response": response});
  }

  void startDelivery(String orderId) {
    socket?.emit("order:startDelivery", {"orderId": orderId});
  }

  void completeDelivery(String orderId) {
    socket?.emit("order:delivered", {"orderId": orderId});
  }


  void disconnect() {
    socket
        ?.clearListeners();
    socket?.disconnect();
    socket = null;
    log("📡 Socket disconnected and cleared manually");
  }
}