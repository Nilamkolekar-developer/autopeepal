import 'package:autopeepal/logic/controller/cliCard/drawerViewController.dart';
import 'package:autopeepal/themes/app_colors.dart';
import 'package:autopeepal/utils/extension/extension/text_extension.dart';
import 'package:autopeepal/utils/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeviceList extends StatelessWidget {
  DeviceList({Key? key}) : super(key: key);

  final controller = Get.put(DrawerViewController());

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.pagebgColor,
      appBar: AppBar(
        toolbarHeight: isMobile ? 60 : 80,
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        title: "WiFi Devices".toInter(
          fontWeight: FontWeight.w700,
          fontSize: isMobile ? 20 : 28,
          color: AppColors.white,
          fontFamily: '',
        ),
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          // Loading indicator while connecting
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 3,
              backgroundColor: AppColors.primaryColor.withAlpha(50),
              valueColor: AlwaysStoppedAnimation(AppColors.primaryColor),
            ),
          );
        }

        if (controller.wifiDevices.isEmpty) {
          // No devices found
          return Center(
            child: "No devices found".toInter(
              fontSize: 16,
              color: AppColors.pinkishGrey,
              fontWeight: FontWeight.w500,
              fontFamily: '',
            ),
          );
        }

        // List of devices
        return ListView.builder(
          itemCount: controller.wifiDevices.length,
          itemBuilder: (context, index) {
            final device = controller.wifiDevices[index];
            final bool isSelected = device == controller.selectedDevice.value;

            return GestureDetector(
              onTap: () => controller.selectDevice(device),
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: isMobile ? 10 : 134,
                  vertical: isMobile ? 8 : 15,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryColor.withOpacity(0.1)
                      : Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.09),
                      offset: const Offset(0, 9),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          device.name!.toInter(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            fontFamily: '',
                          ),
                          const SizedBox(height: 8),
                          device.ip!.toInter(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            fontFamily: '',
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                    print('......................1tap');
                        await controller.connectDevice(device, context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryColor,
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/new/ic_link.png',
                            height: 22,
                            width: 22,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}