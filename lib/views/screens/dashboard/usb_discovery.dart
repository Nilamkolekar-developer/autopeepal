import 'package:autopeepal/logic/controller/cliCard/usbDiscoveryController.dart';
import 'package:autopeepal/themes/app_colors.dart';
import 'package:autopeepal/utils/app_assets.dart';
import 'package:autopeepal/utils/extension/extension/text_extension.dart';
import 'package:autopeepal/utils/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UsbDiscoveryPage extends StatelessWidget {
  UsbDiscoveryPage({Key? key}) : super(key: key);

  final controller = Get.put(UsbDiscoveryController());

  @override
  Widget build(BuildContext context) {
    bool isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
       backgroundColor: AppColors.pagebgColor,
      appBar: AppBar(
        toolbarHeight: isMobile ? 60 : 80,
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        title: ("USB Devices").toInter(
          fontWeight: FontWeight.w700,
          fontSize: isMobile ? 20 : 28,
          color: AppColors.white, fontFamily: '',
        ),
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () => controller.hardRefresh(),
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                backgroundColor: AppColors.primaryColor.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              ),
            ),
          );
        } else if (controller.discoveredDevices.isEmpty) {
          return Center(
            child: "No USB devices detected".toInter(
              fontSize: 16,
              color: AppColors.pinkishGrey,
              fontWeight: FontWeight.w500, fontFamily: '',
            ),
          );
        } else {
          return ListView.builder(
            itemCount: controller.discoveredDevices.length,
            itemBuilder: (context, index) {
              return Obx(() {
                final device = controller.discoveredDevices[index];
                bool isSelected = controller.isConnected.value && 
                                 controller.selectedUsbDevice.value.deviceId == device.deviceId;
                bool isConnectingThis = controller.isConnecting.value && 
                                       controller.selectedUsbDevice.value.deviceId == device.deviceId;

                return Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: isMobile ? 20 : 134,
                    vertical: isMobile ? 10 : 15,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16, // Increased slightly for 3-line look
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffF5F5F5),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        offset: const Offset(0, 4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Device Name
                            device.name.toInter(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w600, fontFamily: '',
                            ),
                            const SizedBox(height: 8),
                            // Device Path (Equivalent to IP)
                            "Path: /usb/dev/${device.deviceId}".toInter(
                              color: Colors.black54,
                              fontSize: 13,
                              fontWeight: FontWeight.w400, fontFamily: '',
                            ),
                            const SizedBox(height: 4),
                            // Protocol info
                            "Serial: 115200 Baud".toInter(
                              color: Colors.black54,
                              fontSize: 13,
                              fontWeight: FontWeight.w400, fontFamily: '',
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => (isSelected || isConnectingThis)
                            ? null
                            : controller.connectToDevice(device),
                        child: isConnectingThis
                            ? const SizedBox(
                                width: 40,
                                height: 40,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : Image.asset(
                                AppAssets.linkImage,
                                height: 40,
                                width: 40,
                                color: isSelected
                                    ? Colors.green
                                    : AppColors.primaryColor,
                              ),
                      ),
                    ],
                  ),
                );
              });
            },
          );
        }
      }),
    );
  }
}
