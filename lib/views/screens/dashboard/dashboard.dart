import 'package:autopeepal/common_widgets/customDropdown.dart';
import 'package:autopeepal/common_widgets/custom_app_bar.dart';
import 'package:autopeepal/common_widgets/custom_drawer.dart';
import 'package:autopeepal/common_widgets/popup.dart';
import 'package:autopeepal/common_widgets/ui_helper_widgets.dart';
import 'package:autopeepal/logic/controller/dashboard/dasboardController.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:autopeepal/themes/app_colors.dart';
import 'package:autopeepal/themes/app_textstyles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final DashboardController controller = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pagebgColor,
      key: scaffoldKey,
      appBar: appBar(
        title: "ATPL Diagnostic Tool",
        showSelectVci: true,
        onSelectVciTap: () {
          Get.toNamed(Routes.cliCard);
        },
        onMenuTap: () {
          scaffoldKey.currentState?.openDrawer();
        },
      ),
      drawer: CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
            "Model",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          C8(),
          Obx(() => CustomDropdownTextField(
                selectedValue: controller.selectedModel,
                items: controller.modelList.map((m) => m.name ?? "").toList(),
                hint: "Select Model",
                textStyle: TextStyles.textfieldTextStyle,
                iconColor: AppColors.primaryColor,
                iconSize: 50,
                title: 'Model',
                enabled: true,
                onTapDisabled: () {},
                onItemSelected: (value) {
                  controller.selectModel(value);
                },
              )),
          C20(),
          const Text(
            "Regulation",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          C8(),
          Obx(() => CustomDropdownTextField(
                selectedValue: controller.selectedRegulation,
                items: controller.filteredSubModels
                    .map((s) => "${s.name} (${s.modelYear})")
                    .toList(),
                hint: "Select Regulation",
                textStyle: TextStyles.textfieldTextStyle,
                iconColor: AppColors.primaryColor,
                iconSize: 50,
                title: 'Regulation',
                enabled: controller.selectedModel.value.isNotEmpty,
                onTapDisabled: () {
                  showDialog(
                    context: context,
                    builder: (context) => CustomPopup(
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
                    controller.selectSubModel(subModel);
                    controller.selectedRegulation.value = value;
                  } else {
                    print("⚠️ SubModel not found for selection: $value");
                    controller.selectedSubModel.value = null;
                    controller.selectedRegulation.value = '';
                  }
                },
              )),
          Padding(
            padding: const EdgeInsets.only(top: 150),
            child: Obx(() {
              if (controller.selectedModel.value.isNotEmpty &&
                  controller.selectedRegulation.value.isNotEmpty &&
                  controller.selectedVciType.value.isNotEmpty) {
                return Column(
                  children: [
                    const Text(
                      "Start Diagnosis By Connecting Vehicle\n Communication Interface",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    C30(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _connectionButton(
                          icon: Icons.usb,
                          label: "USB",
                          onTap: () async {
                            await controller.usbConnect(context);
                          },
                        ),
                        // _connectionButton(
                        //   icon: Icons.wifi,
                        //   label: "WiFi",
                        //   onTap: () {
                        //     controller.wifiConnect(context);
                        //     Get.toNamed(Routes.wifiScreen);
                        //   },
                        // ),
                        _connectionButton(
                            icon: Icons.wifi,
                            label: "WiFi",
                            onTap: () async {
                              print("📶 WiFi tapped");

                              await controller.wifiConnect(context);
                            })
                      ],
                    ),
                  ],
                );
              } else {
                return const SizedBox();
              }
            }),
          ),
        ]),
      ),
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
              size: 30,
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
