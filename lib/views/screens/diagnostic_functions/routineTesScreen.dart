import 'package:autopeepal/common_widgets/ui_helper_widgets.dart';
import 'package:autopeepal/logic/controller/diagnosticFunctions/routineTestController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:autopeepal/themes/app_colors.dart';

class RoutineTestScreen extends StatelessWidget {
  RoutineTestScreen({super.key});

  final controller = Get.put(RoutineTestController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pagebgColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text("Routine Test"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _ecuTabs(),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              /// Routine List
              Expanded(
                child: Obx(() {
                  if (controller.iorTestList.isEmpty) {
                    return Center(
                      child: Text(
                        controller.routineListStatus.value,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    itemCount: controller.iorTestList.length,
                    itemBuilder: (context, index) {
                      final test = controller.iorTestList[index];
                      return GestureDetector(
                        onTap: () => controller.selectIorTestClicked(test),
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8), // separator spacing
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                          ),
                          child: Text(
                            test.routineName ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),

          /// Loader Overlay
          Obx(() => controller.isBusy.value
              ? Container(
                  color: Colors.black45,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : const SizedBox()),

          Obx(() {
            if (!controller.isNoticeVisible.value ||
                controller.routineNotice.isEmpty) return const SizedBox();

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (Get.isBottomSheetOpen ?? false) return;

              showModalBottomSheet(
                context: Get.context!,
                isDismissible: false,
                enableDrag: false,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                builder: (context) {
                  // --- SAFE AREA ADDED HERE ---
                  return SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Orange Header Bar
                        Container(
                          width: double.infinity,
                          color: AppColors.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: const Text(
                            "Alert!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        // Content Area with Padding
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 12),
                          child: Column(
                            children: [
                              // Item Name (e.g., INJECTOR 2.)
                              Text(
                                controller.routineListStatus.value
                                    .toUpperCase(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              C5(),

                              // Instruction Message
                              Text(
                                controller.routineNotice.value,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              C20(),

                              // Buttons Row
                              Row(
                                children: [
                                  // Cancel Button
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          controller.cancelRoutineClicked();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                              0xFFFF812D), // Direct orange from image
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.zero),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 15),
                                        ),
                                        child: const Text("Cancel",
                                            style: TextStyle(fontSize: 16)),
                                      ),
                                    ),
                                  ),

                                  // Ok Button
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          controller.okRoutineClicked();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                              0xFFFF812D), // Direct orange from image
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.zero),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 15),
                                        ),
                                        child: const Text("Ok",
                                            style: TextStyle(fontSize: 16)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            });

            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  /// ECU Tabs Widget
  Widget _ecuTabs() {
    return SizedBox(
      height: 50, // fixed height to avoid RenderBox issues
      child: Obx(() {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: controller.ecuList.map((ecu) {
              final isSelected =
                  controller.selectedEcu.value?.ecuName == ecu.ecuName;

              return GestureDetector(
                onTap: () => controller.selectEcuClicked(ecu),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryColor
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    ecu.ecuName ?? '',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }),
    );
  }
}
