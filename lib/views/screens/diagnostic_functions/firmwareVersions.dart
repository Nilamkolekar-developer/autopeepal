import 'package:autopeepal/logic/controller/diagnosticFunctions/firmwareVersionController.dart';
import 'package:autopeepal/themes/app_colors.dart';
import 'package:autopeepal/utils/ui_helper_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FirmwareUpdatePage extends StatelessWidget {
  FirmwareUpdatePage({Key? key}) : super(key: key);

  final Firmwareupdatecontroller controller = Get.put(Firmwareupdatecontroller());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: AppColors.pagebgColor,
      appBar: AppBar(
        title: const Text(
          'Firmware Update',
          style: TextStyle(color: Colors.white,fontSize: 18),
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
        padding: const EdgeInsets.symmetric(horizontal: 24,vertical:50),
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Current Firmware Version: ${controller.currentFirmwareController.value.text}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              C15(),
              Text(
                'New Firmware Version: ${controller.NewFirmwareController.value.text}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
        
              Expanded(
                child: Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7A18),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 60,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      // Call firmware update logic here
                    },
                    child: const Text(
                      'Update Firmware',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: "Roboto-Regular",
                        color: Colors.white,
                      ),
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
}