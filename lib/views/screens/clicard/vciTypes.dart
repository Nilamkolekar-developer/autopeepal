import 'package:autopeepal/logic/controller/dashboard/dasboardController.dart';
import 'package:autopeepal/themes/app_theme.dart';
import 'package:autopeepal/utils/ui_helper.dart/enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CliCard extends StatelessWidget {
  final DashboardController controller = Get.find();
  CliCard({super.key}) {
    if (controller.vciList.isEmpty) {
      controller.vciList.value =
          VCIType.values.where((e) => e != VCIType.NONE).toList();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pagebgColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFFED7D31),
        title: const Text(
          'Select VCI',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Obx(() => ListView.builder(
            itemCount: controller.vciList.length,
            itemBuilder: (context, index) {
              final VCIType item = controller.vciList[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    controller.selectVCI(item);
                    Get.back();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          )),
    );
  }
}
