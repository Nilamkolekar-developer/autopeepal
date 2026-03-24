import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:autopeepal/themes/app_colors.dart';
import 'package:autopeepal/logic/controller/diagnosticFunctions/ecuInformationController.dart';

class EcuInformationScreen extends StatelessWidget {
  EcuInformationScreen({super.key});
  final controller = Get.put(EcuInformationController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pagebgColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text("ECU Information"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _ecuTabs(),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              

              /// LIST
              Expanded(
                child: Obx(() {
                  if (controller.selectedParameterList.isEmpty) {
                    return Center(
                      child: Text(
                        controller.errorMessage.value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 10),
                    itemCount: controller.selectedParameterList.length,
                    itemBuilder: (context, index) {
                      final pid = controller.selectedParameterList[index];

                      return Column(
                        children: (pid.piCodeVariable ?? [])
                            .map((v) => Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            v.shortName,
                                            style: const TextStyle(
                                                color: Colors.black),
                                          ),
                                        ),
                                        Text(
                                          v.showResolution?.toString() ?? "",
                                          style: const TextStyle(
                                              color: Colors.black),
                                        ),
                                      ],
                                    ),
                                    
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 15),
                                      child: Container(
                                        height: 1,
                                        color: AppColors.primaryColor,
                                      ),
                                    )
                                  ],
                                ))
                            .toList(),
                      );
                    },
                  );
                }),
              ),
            ],
          ),

          /// LOADER
          Obx(() => controller.isBusy.value
              ? Container(
                  color: Colors.black45,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : const SizedBox()),
        ],
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
                    controller.selectedEcu.value?.ecuName == ecu.ecuName;

                return GestureDetector(
                  onTap: () => controller.onTabClicked(ecu),
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
}
