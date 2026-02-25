import 'package:autopeepal/logic/controller/cliCard/drawerViewController.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:autopeepal/services/hotspot_service.dart';
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
    bool isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.pagebgColor,
      appBar: AppBar(
        toolbarHeight: isMobile ? 60 : 80,
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        title: ("Wifi Devices").toInter(
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
          // While searching for devices
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 3,
              backgroundColor: AppColors.primaryColor.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primaryColor,
              ),
            ),
          );
        } else if (controller.discoveredServices.isEmpty) {
          // No devices found
          return Center(
            child: "No devices found".toInter(
              fontSize: 16,
              color: AppColors.pinkishGrey,
              fontWeight: FontWeight.w500,
              fontFamily: '',
            ),
          );
        } else {
          return ListView.builder(
            itemCount: controller.discoveredServices.length,
            itemBuilder: (context, index) {
              return Obx(() {
                DiscoveredService service =
                    controller.discoveredServices[index];
                bool isSelected = service == controller.selectedDevice.value;

                return Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: isMobile ? 10 : 134,
                    vertical: isMobile ? 8 : 15,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.09),
                        offset: Offset(0, 9),
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
                            service.name.toInter(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              fontFamily: '',
                            ),
                            SizedBox(height: 15),
                            service.ip.toInter(
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
                          if (!isSelected) {
                            Get.rawSnackbar(
                              message: "Connecting to ${service.name}...",
                            );

                            await controller.connectToDevice(
                              service,
                              index,
                              isRP1210: true,
                            );

                            Get.toNamed(Routes.diagnosticScreen);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20),
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
                      )
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
