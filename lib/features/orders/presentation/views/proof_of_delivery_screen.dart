import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:delivery_app/core/constants/app_colors.dart';
import 'package:delivery_app/data/services/socket_service.dart';

import '../../../../core/widgets/custom_leading.dart';

/// شاشة إثبات التوصيل: تظهر للمندوب عند وصوله للعميل بانتظار تأكيد الاستلام النهائي
class ProofOfDeliveryScreen extends StatefulWidget {
  final Map<String, dynamic>? orderData;

  const ProofOfDeliveryScreen({super.key, this.orderData});

  @override
  State<ProofOfDeliveryScreen> createState() => _ProofOfDeliveryScreenState();
}

class _ProofOfDeliveryScreenState extends State<ProofOfDeliveryScreen> {
  bool isCustomerConfirmed = false; // مراقبة حالة تأكيد العميل عبر السوكيت
  final SocketService _socketService = Get.find<SocketService>();

  @override
  void initState() {
    super.initState();
    _listenToCustomerConfirmation();
  }

  /// الاستماع لتحديثات الحالة من السيرفر للتأكد من استلام العميل للطلب
  void _listenToCustomerConfirmation() {
    _socketService.socket?.on("order:statusUpdated", (data) {
      if (data['status'] == 'delivered' && mounted) {
        setState(() => isCustomerConfirmed = true);
        Get.snackbar(
          "success_snack_title".tr,
          "success_snack_msg".tr,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    });
  }

  @override
  void dispose() {
    _socketService.socket?.off("order:statusUpdated");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userName = widget.orderData?['userId']?['name'] ?? "Customer";
    final deliveryAddress = (widget.orderData?['deliveryAddress'] is Map)
        ? (widget.orderData?['deliveryAddress']['fullAddress'] ?? "")
        : (widget.orderData?['deliveryAddress']?.toString() ?? "");

    final bgColor = isDark ? const Color(0xFF101828) : Colors.grey.shade50;
    final cardColor = isDark ? const Color(0xFF1D2939) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(isDark),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              const SizedBox(height: 40),
              _buildCenterHeaderIcon(),
              const SizedBox(height: 30),
              _buildHeaderText(isDark),
              const SizedBox(height: 40),
              _buildCustomerCard(isDark, cardColor, userName, deliveryAddress),
              const SizedBox(height: 25),
              _buildInstructionBox(),
              const SizedBox(height: 30),
              _buildHintText(),
              const Spacer(),
              _buildCompleteActionButton(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  /// بناء شريط التطبيق العلوي
  PreferredSizeWidget _buildAppBar(bool isDark) => AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    leading: Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomLeading(onPressed: () => Get.back()),
    ),
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "proof_delivery_title".tr,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "complete_delivery_sub".tr,
          style: TextStyle(
            color: isDark ? Colors.white.withOpacity(0.5) : Colors.black54,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );

  /// أيقونة النجاح المركزية مع التوهج البصري
  Widget _buildCenterHeaderIcon() => Container(
    padding: const EdgeInsets.all(25),
    decoration: BoxDecoration(
      color: AppColors.primaryOrange,
      borderRadius: BorderRadius.circular(25),
      boxShadow: [
        BoxShadow(
          color: AppColors.primaryOrange.withOpacity(0.3),
          blurRadius: 40,
          spreadRadius: 10,
        ),
      ],
    ),
    child: const Icon(Icons.check_circle, size: 50, color: Colors.white),
  );

  Widget _buildHeaderText(bool isDark) => Column(
    children: [
      Text(
        "almost_done_title".tr,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 10),
      Text(
        "confirm_details_sub".tr,
        style: TextStyle(
          color: isDark ? Colors.white.withOpacity(0.6) : Colors.black54,
          fontSize: 16,
        ),
      ),
    ],
  );

  /// بطاقة معلومات العميل المستلم
  Widget _buildCustomerCard(
    bool isDark,
    Color cardColor,
    String name,
    String address,
  ) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(20),
      boxShadow: isDark
          ? []
          : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.blueAccent, Colors.purpleAccent],
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(Icons.person, color: Colors.white),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                address,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildInstructionBox() => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.green.withOpacity(0.1),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: Colors.green.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        const Icon(Icons.check, color: Colors.green, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            "confirm_instruction_text".tr,
            style: const TextStyle(color: Colors.green, fontSize: 12),
          ),
        ),
      ],
    ),
  );

  Widget _buildHintText() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Text(
      "tap_confirm_hint".tr,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.redAccent,
        fontSize: 11,
        fontStyle: FontStyle.italic,
      ),
    ),
  );

  /// زر الإنهاء النهائي (يتم تفعيله فقط عند تأكيد العميل)
  Widget _buildCompleteActionButton() => SizedBox(
    width: double.infinity,
    height: 60,
    child: ElevatedButton.icon(
      onPressed: isCustomerConfirmed
          ? () => Get.offAllNamed('/main-navigation')
          : null,
      icon: Icon(
        Icons.check_circle,
        color: isCustomerConfirmed ? Colors.white : Colors.white24,
      ),
      label: Text(
        "confirm_delivery_btn".tr,
        style: TextStyle(
          color: isCustomerConfirmed ? Colors.white : Colors.white24,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isCustomerConfirmed
            ? AppColors.primaryOrange
            : Colors.white.withOpacity(0.05),
        disabledBackgroundColor: Colors.white.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isCustomerConfirmed ? Colors.transparent : Colors.white12,
          ),
        ),
      ),
    ),
  );
}
