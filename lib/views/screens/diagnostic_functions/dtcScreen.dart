import 'package:autopeepal/common_widgets/ui_helper_widgets.dart';
import 'package:autopeepal/logic/controller/diagnosticFunctions/dtcController.dart';
import 'package:autopeepal/themes/app_colors.dart';
import 'package:autopeepal/themes/app_textstyles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DTCScreen extends StatelessWidget {
  DTCScreen({super.key});
  final Dtccontroller controller = Get.put(Dtccontroller());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pagebgColor,

      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          "DTC List",
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _ecuTabs(),
        ),
      ),

      body: Column(
        children: [
          /// 🔹 SEARCH FIELD
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: TextField(
              style: TextStyles.textfieldTextStyle1,
              cursorColor: Colors.black,
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                prefixIcon: const Icon(Icons.search, size: 22),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: AppColors.primaryColor, width: 1.5),
                ),
              ),
              onChanged: controller.searchDTC,
            ),
          ),

          /// 🔹 DTC LIST
          Expanded(
            child: Obx(() {
              if (controller.isBusy.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.dtcList.isEmpty) {
                return Center(
                  child: Text(
                    controller.emptyViewText.value,
                    style: const TextStyle(color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.dtcList.length,
                itemBuilder: (context, index) {
                  final dtc = controller.dtcList[index];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),

                      /// 🔹 CODE
                      Text(
                        dtc.code ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      C5(),

                      /// 🔹 DESCRIPTION + ACTIONS
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// LEFT SIDE
                          Expanded(
                            child: Text(
                              dtc.description ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),

                          C10(),

                          /// RIGHT SIDE
                          Column(
                            children: [
                              /// STATUS
                              Text(
                                dtc.statusActivation ?? '',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      dtc.statusActivationColor ?? Colors.grey,
                                ),
                              ),

                              C2(),

                              /// TROUBLESHOOT
                              _actionButton(
                                title: "Troubleshoot",
                                onTap: () => controller.gdCommand(dtc),
                              ),

                              C2(),

                              /// FREEZE FRAME
                              _actionButton(
                                title: "Freeze Frame",
                                onTap: () => controller.openFreezeFrame(dtc),
                              ),
                            ],
                          ),
                        ],
                      ),

                      C5(),

                      Divider(
                        thickness: 1,
                        color: AppColors.primaryColor,
                      ),
                    ],
                  );
                },
              );
            }),
          ),
        ],
      ),

      /// 🔹 BOTTOM BUTTONS
      bottomNavigationBar: Obx(() {
        if (!controller.isReadDtc.value) {
          return const SizedBox.shrink();
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: _bottomButton(
                    title: "Clear",
                    onTap: () => controller.clearDtc(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _bottomButton(
                    title: "Refresh",
                    onTap: controller.refreshDtc,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
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
                    controller.selectedEcu.value.ecuId == ecu.ecuId;

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

  /// 🔹 COMMON SMALL BUTTON
  Widget _actionButton({
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.primaryColor),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// 🔹 BOTTOM BUTTON
  Widget _bottomButton({
    required String title,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      onPressed: onTap,
      child: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
