import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:delivery_app/core/constants/app_colors.dart';
import 'package:delivery_app/features/auth/presentation/controllers/auth_controller.dart';

/// شاشة تظهر عندما يتم حظر حساب السائق من قبل الإدارة
class BlockedScreen extends StatelessWidget {
  const BlockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // الوصول للمتحكم لتنفيذ عملية تسجيل الخروج
    final authController = Get.find<AuthController>();
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF2D1B18), const Color(0xFF101828)]
                : [Colors.red.shade50, Colors.grey.shade50],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // أيقونة الحظر الكبيرة
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                      Icons.block_flipped, color: Colors.redAccent, size: 85),
                ),
                const SizedBox(height: 35),

                // عناوين التنبيه
                Text(
                  "blocked_account_title".tr,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Text(
                  "blocked_account_subtitle".tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: isDark ? Colors.red.shade300 : Colors.red.shade700,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),

                // وصف سبب الحظر أو التعليمات
                Text(
                  "blocked_account_desc".tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 15, height: 1.5),
                ),

                const SizedBox(height: 50),

                // أزرار الإجراءات (دعم فني / خروج)
                _buildActionButtons(authController),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// بناء أزرار التواصل مع الدعم أو تسجيل الخروج
  Widget _buildActionButtons(AuthController controller) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              // سيتم ربط خدمة التواصل هنا لاحقاً
            },
            icon: const Icon(Icons.support_agent, color: Colors.white),
            label: Text("contact_support_btn".tr, style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15))),
          ),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () => controller.logout(),
          child: Text(
            "logout_btn".tr,
            style: const TextStyle(color: Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
        ),
      ],
    );
  }
}