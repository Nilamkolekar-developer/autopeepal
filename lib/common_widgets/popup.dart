import 'package:autopeepal/common_widgets/ui_helper_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomPopup extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final VoidCallback? onButtonPressed;
  final VoidCallback? onConfirm;
  final bool showCancel;
  final String cancelText;
  final VoidCallback? onCancel;

  const CustomPopup({
    Key? key,
    required this.title,
    required this.message,
    this.confirmText = "OK",
    this.onConfirm,
    this.onCancel,
    this.showCancel = false,
    this.cancelText = "Cancel",
    this.onButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey.shade800,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  //fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            C10(),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            C10(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (showCancel)
                  TextButton(
                    onPressed: onCancel ?? () => Navigator.pop(context),
                    child: Text(
                      cancelText,
                      style: const TextStyle(
                          color: Colors.white70, fontWeight: FontWeight.bold),
                    ),
                  ),
                if (showCancel) const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade800,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  onPressed: onConfirm ?? () => Navigator.pop(context),
                  child: Text(
                    confirmText,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class CustomPopup2 extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final bool showCancel;

  const CustomPopup2({
    Key? key,
    required this.title,
    required this.message,
    this.confirmText = "OK",
    this.cancelText = "Cancel",
    this.showCancel = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey.shade800,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (showCancel)
                  TextButton(
                    onPressed: () => Get.back(result: false), // returns false
                    child: Text(
                      cancelText,
                      style: const TextStyle(
                          color: Colors.white70, fontWeight: FontWeight.bold),
                    ),
                  ),
                if (showCancel) const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade800,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  onPressed: () => Get.back(result: true), // returns true
                  child: Text(
                    confirmText,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CustomPopup1 extends StatelessWidget {
  final String title;
  final String message;
  final String? yesText;
  final String? noText;
  final VoidCallback? onYesTap;
  final VoidCallback? onNoTap;
  final bool showYesNo;

  const CustomPopup1({
    Key? key,
    required this.title,
    required this.message,
    this.yesText = "Ok",
    this.noText = "Cancle",
    this.onYesTap,
    this.onNoTap,
    this.showYesNo = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey.shade800,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                message,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: showYesNo
                  ? [
                      TextButton(
                        onPressed:
                            onNoTap ?? () => Navigator.pop(context, false),
                        child: Text(noText!,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed:
                            onYesTap ?? () => Navigator.pop(context, true),
                        child: Text(yesText!,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ]
                  : [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade800,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("OK",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
            ),
          ],
        ),
      ),
    );
  }
}
