import 'package:autopeepal/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IorNoticeBanner extends StatelessWidget {
  final RxString routineNotice;
  final RxBool isNoticeVisible;
  final VoidCallback onConfirm;

  const IorNoticeBanner({
    super.key,
    required this.routineNotice,
    required this.isNoticeVisible,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!isNoticeVisible.value) return const SizedBox.shrink();

      return AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        offset: isNoticeVisible.value ? Offset(0, 0) : const Offset(0, -1.5),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: AppColors.primaryColor, // your app primary color
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notice text
              Text(
                routineNotice.value,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 12),

              // Buttons row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Cancel button
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero, // square corners
                      ),
                    ),
                    onPressed: () {
                      isNoticeVisible.value = false;
                    },
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 8),

                  // OK button
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero, // square corners
                      ),
                    ),
                    onPressed: () {
                      isNoticeVisible.value = false;
                      onConfirm(); // your action
                    },
                    child: const Text("OK"),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
