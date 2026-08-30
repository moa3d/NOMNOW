import 'dart:io';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class UploadTile extends StatefulWidget {
  final String title, subtitle;
  final File? file;
  final VoidCallback onTap;
  final IconData icon;
  final Color? color;
  final bool isNotFound;
  final Widget? trailing; // ✅ إضافة هذا الحقل

  const UploadTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.file,
    required this.onTap,
    required this.icon,
    this.color,
    this.isNotFound = false,
    this.trailing,
  });

  @override
  State<UploadTile> createState() => _UploadTileState();
}

class _UploadTileState extends State<UploadTile> {
  @override
  Widget build(BuildContext context) {
    Color borderColor;
    if (widget.file != null) {
      borderColor = Colors.green;
    } else if (widget.isNotFound) {
      borderColor = Colors.red.withOpacity(0.5);
    } else {
      borderColor = AppColors.textGrey.withOpacity(0.1);
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: widget.color ?? AppColors.darkCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.darkBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                widget.file != null ? Icons.insert_drive_file : widget.icon,
                color: widget.file != null
                    ? Colors.green
                    : (widget.isNotFound ? Colors.red : AppColors.textGrey),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    widget.subtitle,
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            widget.trailing ?? (widget.file != null
                ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                : Icon(
              widget.isNotFound ? Icons.priority_high : Icons.arrow_forward_ios,
              color: widget.isNotFound ? Colors.red : AppColors.textGrey,
              size: 16,
            )),
          ],
        ),
      ),
    );
  }
}