import 'package:autopeepal/common_widgets/custom_app_bar.dart';
import 'package:autopeepal/common_widgets/ui_helper_widgets.dart';
import 'package:autopeepal/logic/controller/cliCard/jobCardDetailsController.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:autopeepal/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class JobCardDetailsPage extends StatelessWidget {
  JobCardDetailsPage({super.key});

  final JobCardDetailsController controller =
      Get.put(JobCardDetailsController());
  final Color primaryColor = const Color(0xFFFF7A00);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pagebgColor,
      appBar: appBar(
        title: "Job Card Details",
        isBack: true,
        showSelectVci: true,
        onSelectVciTap: () {
          Get.toNamed(Routes.cliCard);
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _detailsCard(),
            C50(),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: const Text(
                    "Start Diagnosis\nby connecting Dongle via",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _connectionButton(
                      icon: Icons.usb,
                      label: "USB",
                      onTap: () async {
                        await controller.usbConnect(context);
                      },
                    ),
                    _connectionButton(
                      icon: Icons.wifi,
                      label: "WiFi",
                      onTap: () async {
                        print("📶 WiFi tapped");

                        await controller.wifiConnect(context);
                      },
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _detailsCard() {
    return Obx(() {
      final job = controller.jobCard.value;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _rowItem("Job Card No", job?.sessionId ?? ''),
            _divider(),
            _rowItem("Model", (job?.modelWithSubmodel ?? 0).toString()),
            _divider(),
            Row(
              children: [
                Expanded(
                  child: _columnItem(
                    "Registration Number",
                    job?.registrationNo ?? '',
                  ),
                ),
                Expanded(
                  child: _columnItem(
                    "KM Covered",
                    job?.kmCovered?.toString() ?? '', // null-safe string
                  ),
                ),
              ],
            ),
            _divider(),
            _rowItem("Chassis ID", job?.chasisId ?? ''),
            _divider(),
            _rowItem("Complaints", job?.complaints ?? ''),
          ],
        ),
      );
    });
  }

  Widget _rowItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        C2(),
        Text(
          value,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade900),
        ),
      ],
    );
  }

  Widget _columnItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        C2(),
        Text(
          value,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade900),
        ),
      ],
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Divider(color: Colors.grey.shade300, height: 1),
    );
  }

  Widget _connectionButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 25,
            ),
          ),
        ),
        C8(),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
