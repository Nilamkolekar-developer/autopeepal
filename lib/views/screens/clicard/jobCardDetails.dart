import 'package:autopeepal/common_widgets/commonLoader.dart';
import 'package:autopeepal/common_widgets/popup.dart';
import 'package:autopeepal/common_widgets/ui_helper_widgets.dart';
import 'package:autopeepal/logic/controller/cliCard/jobCardDetailsController.dart';
import 'package:autopeepal/logic/controller/dashboard/dasboardController.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:autopeepal/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class JobCardDetailsPage extends StatelessWidget {
  JobCardDetailsPage({super.key});

  final JobCardDetailsController controller =
      Get.put(JobCardDetailsController());
  final DashboardController dashboardController =
      Get.find<DashboardController>();
  final Color primaryColor = const Color(0xFFFF7A00);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: AppColors.pagebgColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text("Job Card Details"),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                controller.vciName,
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _detailsCard(),
            C50(),
            Column(
              mainAxisSize: MainAxisSize.min, // prevents extra vertical space
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 20), // smaller padding
                  child: const Text(
                    "Start Diagnosis\nby connecting Dongle via",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceAround, // tighter spacing
                  children: [
                    _connectionButton(
                      icon: Icons.usb,
                      label: "USB",
                      onTap: () {
                        Get.toNamed(Routes.usbWebScreen);
                      },
                    ),
                    _connectionButton(
                      icon: Icons.wifi,
                      label: "WiFi",
                      onTap: () async {
                        print("📶 WiFi tapped");

                        Get.dialog(
                          const CommonLoader(message: "Scanning..."),
                          barrierDismissible: false,
                        );

                        bool deviceFound = false;
                        await dashboardController.mdnsDiscoveryService
                            .startDiscovery();
                        final subscription = dashboardController
                            .mdnsDiscoveryService.discoveredServices
                            .listen((device) {
                          print("✅ Device detected during tap: $device");
                          deviceFound = true;
                        });

                        await Future.delayed(const Duration(seconds: 5));
                        await subscription.cancel();

                        if (Get.isDialogOpen ?? false) Get.back();

                        if (deviceFound) {
                          print("🚀 Redirecting to WiFi screen");
                          Get.toNamed(Routes.wifiScreen);
                        } else {
                          print("❌ No device found");
                          Get.dialog(
                            CustomPopup(
                              title: "Failed",
                              message: "Dongle not found",
                              onButtonPressed: () => Get.back(),
                            ),
                          );
                        }
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _rowItem("Job Card No", controller.jobCardNo),
          _divider(),
          _rowItem("Model", controller.model),
          _divider(),
          Row(
            children: [
              Expanded(
                child: _columnItem(
                  "Registration Number",
                  controller.registrationNumber,
                ),
              ),
              Expanded(
                child: _columnItem(
                  "KM Covered",
                  controller.kmCovered,
                ),
              ),
            ],
          ),
          _divider(),
          _rowItem("Chassis ID", controller.chassisId),
          _divider(),
          _rowItem("Complaints", controller.complaints),
        ],
      ),
    );
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
          style: TextStyle(fontSize: 14, color: Colors.grey.shade900

              // fontWeight: FontWeight.w500,
              ),
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
          style: TextStyle(fontSize: 14, color: Colors.grey.shade900
              //fontWeight: FontWeight.w500,
              ),
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
