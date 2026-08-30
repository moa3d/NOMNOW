import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettlementController extends GetxController {
  var selectedMethod = 'cash'.obs; // cash or digital
  var isConfirmed = false.obs;

  void selectMethod(String method) => selectedMethod.value = method;

  void toggleConfirmation(bool? value) => isConfirmed.value = value ?? false;
}

class SettlementScreen extends StatelessWidget {
  const SettlementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettlementController());
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;

    // استلام المبلغ من الـ arguments
    final String amount = Get.arguments?.toString() ?? "0.00";

    final bgColor = isDark ? const Color(0xFF101828) : Colors.grey.shade50;
    final cardColor = isDark ? const Color(0xFF1D2939) : Colors.white;
    const accentOrange = Color(0xFFFF5630);
    const successGreen = Color(0xFF12B76A);
    const warningGold = Color(0xFFF79009);
    final textGrey = isDark ? const Color(0xFF98A2B3) : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
              Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("settle_balance".tr,
                style: TextStyle(color: textGrey, fontSize: 12)),
            Text("process_deposit".tr,
                style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // أيقونة العملة الذهبية
            Center(
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: warningGold.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(35),
                ),
                child: const Icon(
                    Icons.monetization_on, color: Colors.white, size: 60),
              ),
            ),
            const SizedBox(height: 32),
            Text("settlement_required".tr,
                style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 28,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("deposit_instruction".tr,
                style: TextStyle(color: textGrey, fontSize: 14)),
            const SizedBox(height: 32),

            // بطاقة المبلغ المطلوب إيداعه
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: isDark
                      ? []
                      : [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ]),
              child: Column(
                children: [
                  Text("you_must_deposit".tr,
                      style: TextStyle(color: textGrey, fontSize: 14)),
                  const SizedBox(height: 12),
                  Text("\$$amount",
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 48,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                      width: 40,
                      height: 4,
                      decoration:
                      BoxDecoration(color: warningGold,
                          borderRadius: BorderRadius.circular(2))),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // اختيار طريقة الدفع
            Align(
              alignment: Alignment.centerLeft,
              child: Text("select_payment_method".tr,
                  style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),

            _buildPaymentMethodTile(
              isDark,
              cardColor,
              controller: controller,
              id: 'cash',
              title: "cash_at_office".tr,
              sub: "visit_office_desc".tr,
              icon: Icons.store,
              accentColor: const Color(0xFFF04438),
            ),
            const SizedBox(height: 12),
            _buildPaymentMethodTile(
              isDark,
              cardColor,
              controller: controller,
              id: 'digital',
              title: "digital_transfer".tr,
              sub: "digital_transfer_desc".tr,
              icon: Icons.phone_android,
              accentColor: const Color(0xFF2E90FA),
            ),

            const SizedBox(height: 32),

            // خانة التأكيد
            _buildConfirmationBox(
                isDark, controller, cardColor, textGrey, successGreen),
            const SizedBox(height: 24),

            // تنبيه هام
            _buildNoticeBox(isDark, warningGold, textGrey),
            const SizedBox(height: 32),

            // زر التأكيد
            Obx(() =>
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: controller.isConfirmed.value
                        ? () => Get.back()
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.isConfirmed.value
                          ? accentOrange
                          : (isDark ? const Color(0xFF344054) : Colors.grey
                          .shade300),
                      disabledBackgroundColor:
                      (isDark ? const Color(0xFF344054) : Colors.grey.shade300)
                          .withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                            Icons.check_circle_outline, color: Colors.white),
                        const SizedBox(width: 12),
                        Text("confirm_deposit_btn".tr,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 16),
            Text("unlock_account_msg".tr,
                style: TextStyle(color: textGrey, fontSize: 12)),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile(bool isDark, Color cardBg,
      {required SettlementController controller,
        required String id,
        required String title,
        required String sub,
        required IconData icon,
        required Color accentColor}) {
    return Obx(() {
      bool isSelected = controller.selectedMethod.value == id;
      return GestureDetector(
        onTap: () => controller.selectMethod(id),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: isSelected
                    ? accentColor.withOpacity(0.5)
                    : (isDark ? Colors.transparent : Colors.black12)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: accentColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    Text(sub,
                        style: TextStyle(
                            color: isDark ? const Color(0xFF98A2B3) : Colors
                                .grey.shade600,
                            fontSize: 11)),
                  ],
                ),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: isSelected
                          ? accentColor
                          : (isDark ? const Color(0xFF475467) : Colors.grey
                          .shade400),
                      width: 2),
                  color: isSelected ? accentColor : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildConfirmationBox(bool isDark, SettlementController controller,
      Color cardColor,
      Color textGrey, Color success) {
    return GestureDetector(
      onTap: () => controller.toggleConfirmation(!controller.isConfirmed.value),
      child: Obx(() =>
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: controller.isConfirmed.value
                        ? success.withOpacity(0.5)
                        : (isDark ? Colors.transparent : Colors.black12))),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: controller.isConfirmed.value
                            ? success
                            : (isDark ? textGrey : Colors.grey.shade400),
                        width: 2),
                    color: controller.isConfirmed.value ? success : Colors
                        .transparent,
                  ),
                  child: controller.isConfirmed.value
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text("confirm_deposit_check".tr,
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 13,
                          height: 1.4)),
                ),
              ],
            ),
          )),
    );
  }

  Widget _buildNoticeBox(bool isDark, Color gold, Color textGrey) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: gold.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: gold.withOpacity(0.2))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: gold, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("important_notice".tr,
                    style:
                    TextStyle(color: gold,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 4),
                Text("false_confirmation_warning".tr,
                    style: TextStyle(
                        color: isDark ? textGrey : Colors.grey.shade700,
                        fontSize: 12,
                        height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}