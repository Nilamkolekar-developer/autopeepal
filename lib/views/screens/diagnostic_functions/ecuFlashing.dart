import 'package:autopeepal/common_widgets/customDropdown.dart';
import 'package:autopeepal/common_widgets/custom_app_bar.dart';
import 'package:autopeepal/logic/controller/diagnosticFunctions/ecuFlashingController.dart';
import 'package:autopeepal/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ECUFlashingScreen extends StatelessWidget {
  ECUFlashingScreen({super.key});

  final controller = Get.put(Ecuflashingcontroller());

  @override
  Widget build(BuildContext context) {
    // Set default selected file if list not empty
    if (controller.Files.isNotEmpty &&
        controller.selectedFile.value.isEmpty) {
      controller.selectedFile.value = controller.Files[0];
    }

    return Scaffold(
      backgroundColor: AppColors.pagebgColor,
      appBar: const CommonAppBar(
        title: "ECU Flashing",
        subtitle: "EMS",
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        
            /// 🔹 Dropdown
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: CustomSearchDropdown(
                selectedValue: controller.selectedFile,
                items: controller.Files,
                iconSize: 50,
                title: "SELECT FILE",
                hint: "Search",
                onFolderTap: () {
                  print("Folder clicked");
                },
              ),
            ),
        
            const Spacer(),
        
            /// 🔹 Flash Button
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // 🔹 Call flash function here
                    print("Flash button pressed for file: ${controller.selectedFile.value}");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "FLASH",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}