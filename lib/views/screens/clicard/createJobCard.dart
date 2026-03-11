import 'package:autopeepal/common_widgets/customDropdown.dart';
import 'package:autopeepal/common_widgets/popup.dart';
import 'package:autopeepal/common_widgets/ui_helper_widgets.dart';
import 'package:autopeepal/logic/controller/cliCard/createJobCardController.dart';
import 'package:autopeepal/themes/app_colors.dart';
import 'package:autopeepal/themes/app_textstyles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateJobCardScreen extends StatelessWidget {
  CreateJobCardScreen({super.key});
  final controller = Get.put(CreateJobcardController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text('Create Job Card', style: TextStyles.appBarTitle),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildFieldWithLabel(controller: controller.jobCardId.value,readOnly: true),
                    C20(),
                    Obx(() => CustomDropdownTextField1(
                          selectedValue: controller.selectedModel,
                          items: controller.modelList
                              .map((m) => m.name ?? "")
                              .toList(),
                          hint: "Select Model",
                          textStyle: TextStyles.textfieldTextStyle,
                          iconColor: AppColors.primaryColor,
                          iconSize: 50,
                          enabled: true,
                          onTapDisabled: () {},
                          onItemSelected: (value) {
                            controller.selectModel(value);
                          },
                          dialogTitle: 'Regulation',
                          title: '',
                        )),
                    C20(),
                    Obx(() => CustomDropdownTextField1(
                          selectedValue: controller.selectedRegulation,
                          items: controller.filteredSubModels
                              .map((s) => "${s.name} (${s.modelYear})")
                              .toList(),
                          hint: "Select Regulation",
                          textStyle: TextStyles.textfieldTextStyle,
                          iconColor: AppColors.primaryColor,
                          iconSize: 50,
                          enabled: controller.selectedModel.value.isNotEmpty,
                          onTapDisabled: () {
                            Get.dialog(
                              CustomPopup(
                                title: "Alert",
                                message: "Please select Model first",
                                onButtonPressed: () => Get.back(),
                              ),
                            );
                          },
                          onItemSelected: (value) {
                            final parts = value.split(" (");
                            final year = parts.last.replaceAll(")", "").trim();

                            final subModel =
                                controller.filteredSubModels.firstWhereOrNull(
                              (s) => s.modelYear?.trim() == year,
                            );

                            if (subModel != null) {
                              controller.selectedSubModel(subModel);
                              controller.selectedRegulation.value = value;
                            }
                          },
                          dialogTitle: 'Regulation',
                          title: "",
                        )),
                    buildFieldWithLabel(
                      controller: controller.regNo.value,
                      hint: "Enter Registration Number(Ex:MP09****)",
                    ),
                    buildFieldWithLabel(
                        controller: controller.chassisNo.value,
                        hint: "Enter Chassis Number"),
                    buildFieldWithLabel(
                        controller: controller.engineNo.value,
                        hint: "Enter Engine number"),
                    buildFieldWithLabel(
                        controller: controller.kmCovered.value,
                        hint: "Enter Kms Travelled"),
                    buildFieldWithLabel(
                        controller: controller.complaint.value,
                        hint: "Enter Complaints"),
                  ],
                ),
              ),
            ),

            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7A18),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 60 // controls height naturally
                      ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(6)),
                ),
                onPressed: () {
                  controller.submitJobCard();
                },
                child: const Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: "OpenSans-SemiBold",
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFieldWithLabel({
    String? label,
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String hint = "",
    bool readOnly = false
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label ?? '',
          style: TextStyles.labelStyle, // Add a custom style for label
        ),
        TextField(
          
          controller: controller,
          style: TextStyles.textfieldTextStyle2,
          cursorColor: Colors.black,
          keyboardType: keyboardType,
          obscureText: obscureText,
          readOnly:readOnly,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyles.hintStyle1,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(color: AppColors.primaryColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(color: AppColors.primaryColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(color: AppColors.primaryColor),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          ),
        ),
      ],
    );
  }
}
