import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:delivery_app/data/api_client/dio_client.dart';

class CashCollectionController extends GetxController {
  final isLoading = true.obs;
  final orders = [].obs;
  final summary = {}.obs;
  final selectedFilter = 'all'.obs;

  @override
  void onInit() {
    fetchCashOrders();
    super.onInit();
  }

  Future<void> fetchCashOrders() async {
    try {
      isLoading.value = true;
      final response = await DioClient().instance.get("api/driver/cash-orders");
      if (response.statusCode == 200) {
        orders.assignAll(response.data['orders'] ?? []);
        summary.value = response.data['summary'] ?? {};
      }
    } catch (e) {
      debugPrint("API Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  List get filteredOrders {
    if (selectedFilter.value == 'all') return orders;
    return orders.where((o) =>
    o['driverPaymentStatus']
        .toString()
        .toLowerCase() == selectedFilter.value.toLowerCase()).toList();
  }
}