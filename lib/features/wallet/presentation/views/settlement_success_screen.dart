import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// شاشة تظهر عند نجاح عملية إيداع المبالغ النقدية وتصفية الرصيد
class SettlementSuccessScreen extends StatelessWidget {
  const SettlementSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String amount = Get.arguments?.toString() ?? "0.00";
    final bool isDark = Theme
        .of(context)
        .brightness == Brightness.dark;

    final Color bgColor = isDark ? const Color(0xFF101828) : Colors.grey
        .shade50;
    final Color cardColor = isDark ? const Color(0xFF1D2939) : Colors.white;
    const Color successGreen = Color(0xFF12B76A);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // أيقونة النجاح
              _buildSuccessIcon(successGreen),
              const SizedBox(height: 40),

              // نصوص رسالة النجاح
              _buildSuccessText(isDark, successGreen),
              const SizedBox(height: 50),

              // بطاقة تفاصيل المبلغ الذي تمت تسويته
              _buildAmountCard(amount, cardColor, isDark),
              const SizedBox(height: 60),

              _buildHomeButton(isDark),
            ],
          ),
        ),
      ),
    );
  }

  /// بناء أيقونة النجاح المركزية
  Widget _buildSuccessIcon(Color color) =>
      Stack(
        alignment: Alignment.center,
        children: [
          ..._buildDecorativeDots(),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
          ),
        ],
      );

  /// بناء نصوص الترحيب والنجاح
  Widget _buildSuccessText(bool isDark, Color green) =>
      Column(
        children: [
          Text(
            "success_snack_title".tr,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "unlock_account_msg".tr,
            style: TextStyle(
              color: green,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );

  /// بناء بطاقة عرض المبلغ
  Widget _buildAmountCard(String amount, Color cardBg, bool isDark) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black12,
          ),
        ),
        child: Column(
          children: [
            Text(
              "amount_col".tr,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Text(
              "\$$amount",
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );

  Widget _buildHomeButton(bool isDark) =>
      SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: () => Get.offAllNamed('/main-navigation'),
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? const Color(0xFF344054) : Colors.grey
                .shade300,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: Text(
            "back_to_login".tr.replaceAll("Login", "Home"),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      );

  List<Widget> _buildDecorativeDots() =>
      const [
        Positioned(top: 0,
            left: 20,
            child: _DecorativeDot(color: Colors.greenAccent, size: 8)),
        Positioned(top: -10,
            left: 80,
            child: _DecorativeDot(color: Colors.orangeAccent, size: 10)),
        Positioned(top: 10,
            right: 30,
            child: _DecorativeDot(color: Colors.yellowAccent, size: 8)),
        Positioned(bottom: 20,
            right: -5,
            child: _DecorativeDot(color: Colors.blueAccent, size: 8)),
      ];
}

class _DecorativeDot extends StatelessWidget {
  final Color color;
  final double size;

  const _DecorativeDot({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}