import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:autopeepal/common_widgets/customDropdown.dart';
import 'package:autopeepal/common_widgets/custom_app_bar.dart';
import 'package:autopeepal/common_widgets/ui_helper_widgets.dart';
import 'package:autopeepal/logic/controller/diagnosticFunctions/writeParameterController.dart';
import 'package:autopeepal/themes/app_colors.dart';
import 'package:autopeepal/themes/app_textstyles.dart';

class WriteParameter extends StatelessWidget {
  WriteParameter({super.key});
  final controller = Get.put(WriteParameterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pagebgColor,
      appBar: const CommonAppBar(title: "Write Parameter", subtitle: "EMS"),

      body: SafeArea(
        child: Obx(() {
          if (controller.isBusy.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// PID Dropdown
                CustomSearchDropdown(
                  selectedValue: controller.selectedPidName,
                  items:
                      controller.pidList.map((e) => e.shortName ?? "").toList(),
                  hint: "Select PID",
                  onChanged: (val) {
                    if (controller.pidList.isEmpty) return;

                    final selected = controller.pidList.firstWhere(
                      (pid) => pid.shortName == val,
                      orElse: () => controller.pidList.first,
                    );

                    controller.selectPidClicked(selected);
                  },
                ),

                C15(),

                /// Selected PID Card
                Obx(() {
                  if ((controller.selectedPidName.value).isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.selectedPidName.value,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          C5(),
                          Row(
                            children: [
                              /// Current Value
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Current Value:",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500)),
                                    C2(),
                                    Obx(() => TextField(
                                          controller: controller
                                              .currentValueController.value,
                                          readOnly: true,
                                          style: TextStyles.textfieldTextStyle1,
                                          decoration:
                                              inputDecorationStyle.copyWith(
                                                  hintText: "Current value",
                                                  hintStyle:
                                                      TextStyles.hintStyle1),
                                        )),
                                  ],
                                ),
                              ),

                              C10(),

                              /// New Value
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("New Value:",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500)),
                                    C2(),
                                    Obx(() => TextField(
                                          controller: controller
                                              .newValueController.value,
                                          onChanged: (val) {
                                            // 1. Update the reactive string used for UI logic
                                            controller.newValue.value = val;

                                            if (controller
                                                    .selectedPidCode
                                                    ?.piCodeVariable
                                                    ?.isNotEmpty ??
                                                false) {
                                              controller
                                                  .selectedPidCode!
                                                  .piCodeVariable!
                                                  .first
                                                  .writeValue
                                                  .value = val;
                                            }

                                            print(
                                                "User typed: $val, Variable updated: ${controller.selectedPidCode!.piCodeVariable!.first.writeValue.value}");
                                          },
                                          style: TextStyles.textfieldTextStyle1,
                                          decoration:
                                              inputDecorationStyle1.copyWith(
                                                  hintText: "Enter new value",
                                                  hintStyle:
                                                      TextStyles.hintStyle1),
                                        ))
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                /// Space so button doesn't overlap scroll
                const SizedBox(height: 100),
              ],
            ),
          );
        }),
      ),

      /// ✅ Bottom Write Button
      bottomNavigationBar: SafeArea(
        child: Obx(() {
          if ((controller.selectedPidName.value).isEmpty) {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  controller.btnWriteClicked();
                },
                child: const Text(
                  "Write",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  final inputDecorationStyle = InputDecoration(
    filled: true,
    fillColor: AppColors.primaryColor.withOpacity(0.3),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: BorderSide(
        color: AppColors.primaryColor.withOpacity(0.1),
        width: 1,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: BorderSide(
        color: AppColors.primaryColor.withOpacity(0.1),
        width: 1,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: BorderSide(
        color: AppColors.primaryColor.withOpacity(0.1),
      ),
    ),
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
    hintText: "Enter new value",
  );

  final inputDecorationStyle1 = InputDecoration(
    filled: true,
    fillColor: Colors.grey.shade200,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: BorderSide(
        color: Colors.grey.shade200,
        width: 1,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: BorderSide(
        color: Colors.grey.shade200,
        width: 1,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: BorderSide(
        color: Colors.grey.shade200,
        width: 1.5,
      ),
    ),
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
    hintText: "Enter new value",
  );
}
