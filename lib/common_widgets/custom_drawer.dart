import 'dart:io';

import 'package:autopeepal/AppPreferences/app_areferences.dart';
import 'package:autopeepal/common_widgets/ui_helper_widgets.dart';
import 'package:autopeepal/logic/controller/dashboard/dasboardController.dart';
import 'package:autopeepal/logic/controller/dataSyncController.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:autopeepal/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class CustomDrawer extends StatelessWidget {
  CustomDrawer({Key? key}) : super(key: key);

  final String drawerTitle = "Diagnostic Tool";
  final String drawerSubtitle = "TEST GREAVES";
  final String subtitle = "TECHNICIAN";
  final DashboardController controller = Get.find();
  final DataSyncController dataSyncController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 60),
            color: AppColors.primaryColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  drawerTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                C25(),
                Text(
                  drawerSubtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                C5(),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView(
                padding: const EdgeInsets.only(top: 10),
                children: [
                  ListTile(
                    leading:
                        const Icon(Icons.work_outline, color: Colors.black87),
                    title: const Text(
                      "Job Card",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      controller.goToJobcardPage();
                    },
                  ),
                  buildDivider(),
                  ListTile(
                    leading: const Icon(Icons.sync, color: Colors.black87),
                    title: const Text(
                      "Data Sync",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      dataSyncController.dataSyncMethod(context);
                    },
                  ),
                  buildDivider(),
                  ListTile(
                    leading: const Icon(Icons.settings, color: Colors.black87),
                    title: const Text(
                      "VCI Configuration",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      dataSyncController.changeSsidPassword();
                    },
                  ),
                  buildDivider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.black87),
                    title: const Text(
                      "Logout",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () async {
                      // Clear shared preferences
                     // AppPreferences.clearAll();
                     await AppPreferences.clearExceptCredentials();
                      await clearLocalData();
                      // Delete controllers to remove previous user data
                      // Get.delete<DashboardController>();
                      // Get.delete<DataSyncController>();

                      // Navigate to login
                      Get.offAllNamed(Routes.loginScreen);
                    },
                  ),
                  buildDivider(),
                ],
              ),
            ),
          ),
          Obx(() => SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    children: [
                      Text(
                        controller.appName.value,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Version ${controller.version.value} (${controller.buildNumber.value})",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ))
        ],
      ),
    );
  }

  Future<void> clearLocalData() async {
    final dir = await getApplicationDocumentsDirectory();

    final filesToDelete = [
      'MODEL_LocalList.txt',
      'IOR_LocalList.txt',
      'Actuator_LocalList.txt',
      'FreezeFrame_LocalList.txt',
      'UserDetail_LocalData.txt',
      'UserRequest_LocalData.txt',
    ];

    for (var fileName in filesToDelete) {
      final file = File('${dir.path}/$fileName');
      if (await file.exists()) {
        await file.delete();
        print('Deleted $fileName');
      }
    }
  }

  Widget buildDivider() {
    return Divider(
      color: AppColors.black,
      height: 1,
      indent: 15,
      endIndent: 15,
    );
  }
}
