import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:delivery_app/core/constants/app_colors.dart';
import 'package:delivery_app/core/widgets/custom_leading.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.darkBackground : Colors.grey
        .shade50;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Padding(
            padding: EdgeInsets.all(8.0), child: CustomLeading()),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("notifications".tr, style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold)),
          Text("${"unread_count".tr} 2", style: TextStyle(
              color: AppColors.primaryOrange.withOpacity(0.8), fontSize: 12)),
        ]),
        actions: [
          TextButton(onPressed: () {},
              child: Text("mark_all_read".tr,
                  style: const TextStyle(color: Colors.green, fontSize: 13))),
          const SizedBox(width: 10)
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF3D2621), AppColors.darkBackground]
                : [Colors.orange.shade50, Colors.grey.shade100])),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          physics: const BouncingScrollPhysics(),
          children: [
            _buildNotificationItem(
                Icons.inventory_2,
                Colors.green,
                "notif_new_order_title".tr,
                "notif_new_order_desc".tr,
                "notif_time_2min".tr,
                isDark,
                true),
            _buildNotificationItem(
                Icons.attach_money,
                Colors.blue,
                "notif_payment_title".tr,
                "notif_payment_desc".tr,
                "notif_time_1h".tr,
                isDark,
                true),
            _buildNotificationItem(
                Icons.access_time_filled,
                Colors.orange,
                "notif_peak_title".tr,
                "notif_peak_desc".tr,
                "notif_time_3h".tr,
                isDark,
                false),
            _buildNotificationItem(
                Icons.check_circle,
                Colors.teal,
                "notif_delivery_done_title".tr,
                "notif_delivery_done_desc".tr,
                "notif_time_5h".tr,
                isDark,
                false),
            _buildNotificationItem(
                Icons.error_outline,
                Colors.redAccent,
                "notif_doc_expire_title".tr,
                "notif_doc_expire_desc".tr,
                "notif_time_1d".tr,
                isDark,
                false),
            const SizedBox(height: 20),
            Center(child: TextButton(onPressed: () {},
                child: Text("load_older_notif".tr, style: TextStyle(
                    color: isDark ? AppColors.textGrey.withOpacity(0.7) : Colors
                        .black45)))),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(IconData icon, Color iconColor, String title,
      String description, String time, bool isDark, bool isUnread) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isUnread ? iconColor.withOpacity(0.2) : Colors
                  .transparent),
          boxShadow: isDark ? [] : [
            BoxShadow(color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 24)),
        const SizedBox(width: 15),
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
                if (isUnread) Container(width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle))
              ]),
          const SizedBox(height: 5),
          Text(description, style: TextStyle(
              color: isDark ? AppColors.textGrey : Colors.black54,
              fontSize: 13,
              height: 1.4)),
          const SizedBox(height: 10),
          Text(time, style: TextStyle(
              color: isDark ? AppColors.textGrey.withOpacity(0.6) : Colors
                  .black38, fontSize: 11)),
        ])),
      ]),
    );
  }
}