import 'package:autopeepal/common_widgets/customDropdown.dart';
import 'package:autopeepal/common_widgets/custom_app_bar.dart';
import 'package:autopeepal/common_widgets/ui_helper_widgets.dart';
import 'package:autopeepal/logic/controller/diagnosticFunctions/writeParameterController.dart';
import 'package:autopeepal/themes/app_textstyles.dart';
import 'package:flutter/material.dart';
import 'package:autopeepal/themes/app_colors.dart';
import 'package:get/get.dart';

class WriteParameter extends StatelessWidget {
  WriteParameter({super.key});
  final controller = Get.put(Writeparametercontroller());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pagebgColor,
      appBar: const CommonAppBar(
        title: "Write parameter",
        subtitle: "EMS",
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔹 Dropdown
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: CustomSearchDropdown(
                  selectedValue: controller.selectedFile,
                  items: controller.Files,
                  iconSize: 50,
                  showFolderIcon: false,
                  hint: "Select a parameter to write",
                ),
              ),

              C15(),

              Obx(() {
                if (controller.selectedFile.value.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.selectedFile.value,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                        C5(),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Current Value :",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  C2(),
                                  TextField(
                                    style: TextStyles.textfieldTextStyle1,
                                    cursorColor: Colors.black,
                                    readOnly: true,
                                    controller:
                                        controller.currentValueController.value,
                                    decoration: inputDecorationStyle.copyWith(
                                        hintText: "Current value",
                                        hintStyle: TextStyles.hintStyle1),
                                  ),
                                ],
                              ),
                            ),

                            C10(),

                            /// New Value Column
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "New Value :",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  C2(),
                                  TextField(
                                    cursorColor: Colors.black,
                                    style: TextStyles.textfieldTextStyle1,
                                    controller:
                                        controller.newValueController.value,
                                    decoration: inputDecorationStyle1.copyWith(
                                        hintText: "Enter new value",
                                        hintStyle: TextStyles.hintStyle1),
                                  ),
                                ],
                              ),
                            ),
                           
                          ],
                          
                        ),
                        C25()
                      ],
                    ),
                  ),
                );
              }),

              const Spacer(),

              /// 🔹 Write Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // 🔹 Call write function here
                    print(
                        "Write button pressed for file: ${controller.selectedFile.value} with new value: ${controller.newValueController.value.text}");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Write",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
