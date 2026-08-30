import 'package:get/get.dart';
import 'package:delivery_app/data/services/socket_service.dart';
import 'package:flutter/material.dart';

class NewOrderController extends GetxController {
  final SocketService _socketService = Get.find<SocketService>();
  var isProcessing = false.obs;

  void acceptOrder(String? orderId) {
    if (isProcessing.value || orderId == null || orderId.isEmpty) return;

    isProcessing.value = true;
    _socketService.respondToOrder(orderId, 'accepted');

    // إظهار مؤشر تحميل
    Get.dialog(
      const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B44))),
      barrierDismissible: false,
    );
  }

  void declineOrder(String? orderId) {
    if (orderId != null && orderId.isNotEmpty) {
      _socketService.respondToOrder(orderId, 'rejected');
    }
    Get.back();
  }
}