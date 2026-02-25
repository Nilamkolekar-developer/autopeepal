import 'package:autopeepal/common_widgets/custom_app_bar.dart';
import 'package:autopeepal/logic/controller/diagnosticFunctions/liveParameterController.dart';
import 'package:autopeepal/themes/app_colors.dart';
import 'package:autopeepal/themes/app_textstyles.dart';
import 'package:autopeepal/views/screens/diagnostic_functions/recordPlayScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LiveParameter extends StatelessWidget {
  LiveParameter({super.key});
  final controller = Get.put(Liveparametercontroller());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pagebgColor,
      appBar: const CommonAppBar(
        title: "Select Parameter",
        subtitle: "EMS",
      ),
      body: SafeArea(
        child: Column(
          children: [
            /// 🔹 Top Fixed Search Section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: TextField(
                      style: TextStyles.textfieldTextStyle1,
                      cursorColor: Colors.black,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 10,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 22,
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minHeight: 30,
                          minWidth: 35,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primaryColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primaryColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Image.asset(
                    "assets/new/ic_groupfilter.png",
                    height: 45,
                    width: 45,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: controller.parameters.length,
                itemBuilder: (context, index) {
                  final item = controller.parameters[index];

                  return Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            item,
                            style: TextStyles.textfieldTextStyle1,
                          ),
                        ),
                      ),
                      Transform.scale(
                        scale: 1.2,
                        child: Obx(() => Checkbox(
                              value:
                                  controller.selectedParameters.contains(item),
                              fillColor:
                                  MaterialStateProperty.resolveWith((states) {
                                if (states.contains(MaterialState.selected)) {
                                  return AppColors.primaryColor;
                                }
                                return null;
                              }),
                              side: BorderSide(
                                color: AppColors.primaryColor,
                                width: 2,
                              ),
                              onChanged: (value) {
                                controller.toggleSelection(
                                    item, value ?? false);
                              },
                            )),
                      )
                    ],
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider(
                    height: 5,
                    color: AppColors.primaryColor,
                    thickness: 1,
                    indent: 4,
                    endIndent: 4,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Get.to(() => RecordPlayScreen(
                        selectedItems: controller.selectedParameters.toList(),
                      ));
                },
                child: const Text(
                  "Continue",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
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
