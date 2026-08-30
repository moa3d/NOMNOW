
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_logo_container.dart';
import '../../../../core/widgets/upload_tile.dart';

class CompletionDocumentScreen extends StatelessWidget {
  const CompletionDocumentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.darkBackground : Colors.grey
        .shade100;
    final titleColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF3D2621), AppColors.darkBackground]
                : [Colors.orange.shade50, Colors.grey.shade100],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 50),
              CustomLogoContainer(
                icon: CupertinoIcons.time,
                size: 60,
                borderRadius: 18,
                backgroundColor: const Color(0xffF0B100).withOpacity(0.33),
              ),
              const SizedBox(height: 20),
              Text(
                "under_review_title".tr,
                style: TextStyle(
                  fontSize: 20,
                  color: titleColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "under_review_subtitle".tr,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 25),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    "document_status".tr,
                    style: TextStyle(
                      color: titleColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              UploadTile(
                isNotFound: true,
                title: "id_card".tr,
                subtitle: "file_format_note".tr,
                onTap: () {},
                icon: Icons.file_present,
                color: Colors.deepOrange.withOpacity(0.1),
              ),
              const SizedBox(height: 10),
              UploadTile(
                isNotFound: true,
                title: "vehicle_reg".tr,
                subtitle: "file_format_note".tr,
                onTap: () {},
                icon: Icons.credit_card,
                color: Colors.yellowAccent.withOpacity(0.1),
              ),
              const SizedBox(height: 10),
              UploadTile(
                isNotFound: true,
                title: "license".tr,
                subtitle: "file_format_note".tr,
                onTap: () {},
                icon: Icons.directions_car,
                color: Colors.deepOrange.withOpacity(0.1),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.upload_outlined, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      "upload_missing_btn".tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 13,
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(
                        text: "${"tips_label".tr}: ",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: "tips_desc".tr)
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white24 : Colors.grey
                      .shade300,
                  minimumSize: const Size(double.infinity, 50),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => Get.offAllNamed('/home'),
                child: Text(
                  "continue_demo".tr,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}