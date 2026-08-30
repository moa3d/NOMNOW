import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/new_order_controller.dart';

class NewOrderRequestScreen extends StatefulWidget {
  const NewOrderRequestScreen({super.key});

  @override
  State<NewOrderRequestScreen> createState() => _NewOrderRequestScreenState();
}

class _NewOrderRequestScreenState extends State<NewOrderRequestScreen> {
  final controller = Get.put(NewOrderController());
  late Timer _timer;
  var _timeLeft = 25.obs;

  @override
  void initState() {
    super.initState();
    final dynamic rawData = Get.arguments;
    if (rawData is Map && rawData['timeoutSeconds'] != null) {
      _timeLeft.value =
          int.tryParse(rawData['timeoutSeconds'].toString()) ?? 25;
    }
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft.value > 0) {
        _timeLeft.value--;
      } else {
        _timer.cancel();
        _handleAutoDecline();
      }
    });
  }

  void _handleAutoDecline() {
    final dynamic rawData = Get.arguments;
    String orderId = _extractOrderId(rawData);
    controller.declineOrder(orderId);
  }

  String _extractOrderId(dynamic rawData) {
    if (rawData is! Map) return "";
    return rawData['orderId']?.toString() ??
        rawData['_id']?.toString() ??
        rawData['order']?['_id']?.toString() ??
        rawData['id']?.toString() ?? "";
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;
    final dynamic rawData = Get.arguments;
    final dynamic effectiveData = (rawData is Map &&
        rawData.containsKey('order'))
        ? rawData['order']
        : rawData;

    final restaurantName = effectiveData?['restaurantName'] ??
        effectiveData?['restaurantId']?['name'] ?? "NUMNOW Restaurant";
    final earnings = effectiveData?['totalPrice']?.toString() ?? "12.50";
    final distance = effectiveData?['distance']?.toString() ?? "2.3";
    final orderId = _extractOrderId(rawData);

    final bgColor = isDark ? const Color(0xFF101828) : Colors.grey.shade50;
    final cardColor = isDark ? const Color(0xFF1D2939) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF2D1B18), const Color(0xFF101828)]
                : [Colors.orange.shade50, Colors.grey.shade50],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 30),
              _buildTimerBadge(),
              const SizedBox(height: 30),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _buildMainCard(isDark, restaurantName, earnings, distance,
                          cardColor),
                      const SizedBox(height: 30),
                      _buildActionButtons(orderId),
                      const SizedBox(height: 25),
                      Text("busy_status_msg".tr,
                          style: const TextStyle(color: Color(0xFF98A2B3),
                              fontSize: 14)),
                    ],
                  ),
                ),
              ),
              _buildFakeBottomNav(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF4A341A).withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: const Color(0xFFF79009).withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                  Icons.timer_outlined, color: Color(0xFFF79009), size: 16),
              const SizedBox(width: 8),
              Text("respond_in".tr, style: const TextStyle(
                  color: Color(0xFFF79009),
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
            ],
          ),
          Obx(() =>
              Text("${_timeLeft.value}s",
                  style: const TextStyle(color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildMainCard(bool isDark, String name, String earnings, String dist,
      Color cardColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B44),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: const Color(0xFFFF6B44).withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5)
              ],
            ),
            child: const Icon(Icons.storefront, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 24),
          Text("new_order_req".tr, style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(name,
              style: const TextStyle(color: Color(0xFF98A2B3), fontSize: 16)),
          const SizedBox(height: 32),
          _infoRow(
              isDark, Icons.near_me, const Color(0xFF2E90FA), "dist_to_rest".tr,
              "$dist km", "~8 ${"min_unit".tr}"),
          const SizedBox(height: 16),
          _infoRow(isDark, Icons.access_time_filled, const Color(0xFFF79009),
              "prep_time".tr, "15 ${"min_unit".tr}", ""),
          const SizedBox(height: 16),
          _infoRow(isDark, Icons.location_on, const Color(0xFF7F56D9),
              "deliv_dist".tr, "4.7 km", "~12 ${"min_unit".tr}"),
          const SizedBox(height: 32),
          _buildEarningBox(isDark, earnings),
          const SizedBox(height: 24),
          Divider(color: isDark ? Colors.white10 : Colors.black12),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("est_total_time".tr, style: const TextStyle(
                  color: Color(0xFF98A2B3), fontSize: 14)),
              Text("~35 ${"min_unit".tr}", style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(bool isDark, IconData icon, Color color, String title,
      String val, String time) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: isDark ? Colors.black.withOpacity(0.2) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(
                    color: Color(0xFF98A2B3), fontSize: 11)),
                Text(val, style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          if (time.isNotEmpty) Text(time, style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildEarningBox(bool isDark, String earnings) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF79009).withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF79009).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF4A341A),
                borderRadius: BorderRadius.circular(16)),
            child: const Icon(
                Icons.attach_money, color: Color(0xFFF79009), size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("your_earning".tr, style: const TextStyle(
                  color: Color(0xFFF79009),
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
              Text("\$$earnings", style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildActionButtons(String orderId) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 60,
            child: OutlinedButton(
              onPressed: () => controller.declineOrder(orderId),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFF04438), width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.close, color: Color(0xFFF04438), size: 20),
                  const SizedBox(width: 8),
                  Text("decline_btn".tr, style: const TextStyle(
                      color: Color(0xFFF04438),
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: const Color(0xFFFF6B44).withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8))
              ],
            ),
            child: ElevatedButton(
              onPressed: () => controller.acceptOrder(orderId),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B44),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text("accept_btn".tr, style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFakeBottomNav(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1D2939) : Colors.white,
          border: Border(top: BorderSide(
              color: isDark ? Colors.white10 : Colors.black12))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_filled, "Home".tr, true),
          _navItem(
              Icons.account_balance_wallet_outlined, "wallet_title".tr, false),
          _navItem(Icons.assignment_outlined, "orders_history_title".tr, false),
          _navItem(Icons.settings_outlined, "settings_title".tr, false),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool active) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            color: active ? const Color(0xFFFF6B44) : const Color(0xFF98A2B3),
            size: 24),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(
            color: active ? const Color(0xFFFF6B44) : const Color(0xFF98A2B3),
            fontSize: 10)),
      ],
    );
  }
}