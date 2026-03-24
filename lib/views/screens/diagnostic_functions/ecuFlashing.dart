import 'package:autopeepal/common_widgets/commonLoader.dart';
import 'package:autopeepal/common_widgets/customDropdown.dart';
import 'package:autopeepal/logic/controller/diagnosticFunctions/ecuFlashingController.dart';
import 'package:autopeepal/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ECUFlashingScreen extends StatelessWidget {
  ECUFlashingScreen({super.key});

  final Ecuflashingcontroller controller = Get.put(Ecuflashingcontroller());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pagebgColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text("ECU Flashing"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _ecuTabs(),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          return Stack(
            children: [
              Column(
                children: [
                  Expanded(child: _mainContent()),
                ],
              ),

              /// 🔹 Loader Overlay (BEST PRACTICE)
              if (controller.isBusy.value)
                const Center(
                  child: CommonLoader(message: "Loading..."),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _ecuTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Obx(() => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: controller.ecusList.map((ecu) {
                final isSelected =
                    controller.selectedEcu.value?.ecu2 == ecu.ecu2;

                return GestureDetector(
                  onTap: () => controller.switchTab(ecu),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryColor
                          : Colors.grey.shade200,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      ecu.ecuName ?? '',
                      style: TextStyle(
                        color: isSelected ? Colors.grey.shade300 : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          )),
    );
  }

  /// 🔹 Main Content
  Widget _mainContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),

          Obx(() {
            return CustomSearchDropdown(
              selectedValue: controller.selectedFlashFileString,
              items: controller.flashFileList
                  .map((e) => e.dataFileName.toString())
                  .toList(),
              iconSize: 40,
              title: "SELECT FILE",
              hint: controller.flashFileList.isEmpty
                  ? "No files available"
                  : "Search file...",
              onChanged: (value) {
                final file = controller.flashFileList.firstWhereOrNull(
                  (e) => e.dataFileName == value,
                );

                if (file != null) {
                  controller.selectedFlashFile.value = file;
                  controller.selectedFlashFileString.value = value;
                  controller.isFlashBtnVisible.value = true;
                }
              },
              onFolderTap: controller.browseFile,
            );
          }),

          const SizedBox(height: 20),

          /// 🔹 Timer
          Obx(() => controller.timerVisible.value
              ? Center(
                  child: Text(
                    controller.flashTimer.value,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : const SizedBox()),

          const SizedBox(height: 20),

          /// 🔹 Progress Bar
          Obx(() => controller.flashProgressVisible.value
              ? Column(
                  children: [
                    LinearProgressIndicator(
                      value: controller.progress.value,
                      minHeight: 18,
                      backgroundColor: Colors.grey.shade300,
                      color: AppColors.primaryColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      controller.flashPercent.value,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              : const SizedBox()),

          const Spacer(),

          /// 🔹 Flash Button
          SizedBox(
            width: double.infinity,
            child: Obx(() => ElevatedButton(
                  onPressed: (controller.isFlashBtnVisible.value &&
                          !controller.isBusy.value &&
                          controller.selectedFlashFile.value != null)
                      ? controller.flashCommand
                      : null,
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
                )),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
