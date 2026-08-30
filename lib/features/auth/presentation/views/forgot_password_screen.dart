import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:delivery_app/core/constants/app_colors.dart';
import 'package:delivery_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:delivery_app/core/widgets/custom_text_field.dart';

import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final AuthController _authController = Get.find<AuthController>();
  bool _isEmailValid = false;

  bool _validateEmail(String email) {
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    );
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.darkBackground : Colors.grey
        .shade100;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(isDark),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF3D2621), AppColors.darkBackground]
                : [Colors.orange.shade50, Colors.grey.shade100],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                _buildHeaderIcon(),
                const SizedBox(height: 30),
                _buildTitleSection(isDark),
                const SizedBox(height: 40),
                _buildInputCard(isDark),
                const SizedBox(height: 25),
                _buildSubmitButton(),
                const SizedBox(height: 25),
                _buildSpamNote(isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: Icon(
          Icons.arrow_back,
          color: isDark ? Colors.white : Colors.black87,
          size: 20,
        ),
      ),
      title: Text(
        "back_to_login".tr,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildHeaderIcon() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryOrange.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryOrange.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Icon(
        Icons.lock_outline,
        size: 50,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTitleSection(bool isDark) {
    return Column(
      children: [
        Text(
          "forgot_pass_title".tr,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          "forgot_pass_subtitle".tr,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textGrey,
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInputCard(bool isDark) {
    final cardColor = isDark ? AppColors.darkCard.withOpacity(0.5) : Colors
        .white;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? []
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "email_label".tr,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          CustomTextField(
            onChanged: (val) =>
                setState(() => _isEmailValid = _validateEmail(val)),
            hint: 'driver@example.com',
            icon: Icons.email_outlined,
            controller: _authController.emailController,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Obx(
          () =>
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: (_authController.isLoading.value || !_isEmailValid)
                  ? null
                  : () =>
                  Get.to(
                        () => const ResetPasswordScreen(),
                    arguments: _authController.emailController.text,
                  ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isEmailValid
                    ? AppColors.primaryOrange
                    : const Color(0xFFB54F37),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: _authController.isLoading.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.send_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "send_link_btn".tr,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildSpamNote(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(43, 127, 255, 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: Colors.yellow,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "spam_folder_note".tr,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}