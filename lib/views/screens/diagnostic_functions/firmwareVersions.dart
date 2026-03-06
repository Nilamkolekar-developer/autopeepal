import 'package:autopeepal/logic/controller/diagnosticFunctions/firmwareVersionController.dart';
import 'package:autopeepal/themes/app_colors.dart';
import 'package:autopeepal/utils/ui_helper_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FirmwareUpdatePage extends StatelessWidget {
  FirmwareUpdatePage({Key? key}) : super(key: key);

  final SettingsController controller = Get.put(SettingsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pagebgColor,
      appBar: AppBar(
        title: const Text(
          'Firmware Update',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Current Firmware Version: ${controller.currentVersion.value}',
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              C15(),
              Text(
                'New Firmware Version: ${controller.serverFirmware.value}',
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Center(
                    child:
                        Obx(
                  () => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.btnEnable.value
                          ? const Color(0xFFFF7A18)
                          : Colors.grey,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 60, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed:
                        (controller.btnEnable.value && !controller.isBusy.value)
                            ? () => controller.upgradeCommand()
                            : null,
                    child: controller.isBusy.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Update Firmware',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: "Roboto-Regular",
                              color: Colors.white,
                            ),
                          ),
                  ),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
