import 'package:autopeepal/common_widgets/ui_helper_widgets.dart';
import 'package:autopeepal/logic/controller/diagnosticFunctions/diagnosticFunctionsController.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:autopeepal/themes/app_colors.dart';
import 'package:autopeepal/utils/extension/extension/text_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DiagnosticFunctions extends StatelessWidget {
  DiagnosticFunctions({super.key});

  final DiagnosticController controller = Get.put(DiagnosticController());

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isMobile = width < 600;
    bool isTablet = width >= 600 && width < 1024;

    isMobile
        ? 2
        : isTablet
            ? 3
            : 4;
    return WillPopScope(
      onWillPop: () async{
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.pagebgColor,
        appBar: AppBar(
          toolbarHeight: isMobile ? 60 : 80,
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.primaryColor,
          title: ("Diagnostic Functions").toInter(
            fontWeight: FontWeight.w700,
            fontSize: isMobile ? 20 : 28,
            color: AppColors.white,
            fontFamily: "OpenSans-SemiBold",
          ),
          actions: [
            IconButton(
              onPressed: () {
                Get.toNamed(Routes.SessionScreen);
              },
              icon: Image.asset(
                "assets/new/ic_session_log.png",
                height: isMobile ? 35 : 50,
                width: isMobile ? 35 : 50,
                color: Colors.white, // optional if PNG is black
              ),
            ),
            IconButton(
              onPressed: () {
                Get.toNamed(Routes.firmwareUpdateScreen);
              },
              icon: Image.asset(
                "assets/new/ic_update_fw.png",
                height: isMobile ? 35 : 50,
                width: isMobile ? 35 : 50,
                color: Colors.white,
              ),
            ),
            C5(),
          ],
        ),
        body: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.09),
                        blurRadius: 5,
                        offset: const Offset(4, 14),
                      ),
                    ],
                  ),
                  child: Obx(() => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildRow("Model :", controller.selectedModel.value),
                          buildDivider(),
                          buildRow("Regulation :",
                              controller.selectedRegulation.value),
                          buildDivider(),
                          buildEcuRow(
                            controller.selectedEcu.value,
                            controller.status.value,
                          ),
                          buildDivider(),
                          buildRow(
                            "Firmware Version :",
                            controller.firmwareVersion.value,
                          ),
                        ],
                      )),
                ),
                verticalSpace(isMobile ? 10 : 20),
                GestureDetector(
                  onTap: () async {
                    Get.toNamed(Routes.dashboardScreen);
                  },
                  child: Container(
                    padding: EdgeInsets.all(isMobile ? 14 : 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.09),
                          blurRadius: isMobile ? 5 : 10,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      "assets/new/ic_disconnect.png",
                      height: isMobile ? 40 : 50,
                      width: isMobile ? 50 : 50,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                C10(),
                const Text(
                  "Click Here To Disconnect",
                  style: TextStyle(
                    fontFamily: "OpenSans-Regular",
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                verticalSpace(isMobile ? 15 : 30),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 27, vertical: 22),
                  child: GridView.count(
                    crossAxisCount: isMobile
                        ? 2
                        : isTablet
                            ? 3
                            : 3, // 4 columns for desktop
                    crossAxisSpacing: 70,
                    mainAxisSpacing: 55,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      functionCard(
                        context: context,
                        imagePath: "assets/new/ic_info.png",
                        title: "ECU Information",
                        onTap: () {
                          Get.toNamed(Routes.ecuInformation);
                        },
                      ),
                      functionCard(
                          context: context,
                          imagePath: "assets/new/ic_dtc.png",
                          title: "DTC",
                          onTap: () {
                            Get.toNamed(Routes.dtcScreen);
                          }),
                      functionCard(
                          context: context,
                          imagePath: "assets/new/ic_pid.png",
                          title: "Live Parameter",
                          onTap: () {
                            Get.toNamed(Routes.liveParameter);
                          }),
                      functionCard(
                        context: context,
                        imagePath: "assets/new/ic_write.png",
                        title: "Write Parameter",
                        onTap: () {
                          Get.toNamed(Routes.writeParameter);
                        },
                      ),
                      functionCard(
                        context: context,
                        imagePath: "assets/new/ic_flash.png",
                        title: "ECU Flashing",
                        onTap: () {
                          Get.toNamed(Routes.ecuFlashing);
                        },
                      ),
                      functionCard(
                        context: context,
                        imagePath: "assets/new/ic_routine.png",
                        title: "Routine Test",
                        onTap: () {
                          Get.toNamed(Routes.routineTest);
                        },
                      ),
                      functionCard(
                        context: context,
                        imagePath: "assets/new/ic_dtc.png",
                        title: "All DTC Details",
                        onTap: () {
                          Get.toNamed(Routes.allDtcDetails);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDivider() {
    return Divider(
      color: AppColors.primaryColor,
      thickness: 1,
      height: 8,
    );
  }

  Widget verticalSpace(double height) {
    return SizedBox(height: height);
  }

  Widget buildRow(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: "OpenSans-SemiBold",
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
        C2(),
        Text(
          value.isEmpty ? "N/A" : value.toUpperCase(),
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.blueColor,
          ),
        ),
      ],
    );
  }

  Widget functionCard({
    required BuildContext context,
    required String title,
    IconData? icon,
    String? imagePath,
    VoidCallback? onTap,
  }) {
    double width = MediaQuery.of(context).size.width;

    bool isMobile = width < 600;
    bool isTablet = width >= 600 && width < 1024;

    double padding = isMobile
        ? 12
        : isTablet
            ? 14
            : 16;
    double iconSize = isMobile
        ? 60
        : isTablet
            ? 90
            : 120;
    double fontSize = isMobile
        ? 13
        : isTablet
            ? 14
            : 14;
    double blur = isMobile
        ? 5
        : isTablet
            ? 6
            : 6;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black38.withOpacity(0.09),
              blurRadius: blur,
              offset: const Offset(14, 14),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: padding, horizontal: padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Show image if provided
              if (imagePath != null)
                Image.asset(
                  imagePath,
                  height: iconSize,
                  width: iconSize,
                  fit: BoxFit.contain,
                ),

              C8(),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEcuRow(String ecu, String status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "ECU",
          style: TextStyle(
            fontFamily: "OpenSans-SemiBold",
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
        C2(),
        Row(
          children: [
            /// ECU value (left)
            Expanded(
              child: Text(
                ecu.isEmpty ? "N/A" : ecu.toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.blueColor,
                ),
              ),
            ),

            /// Status exactly center
            Expanded(
              child: Center(
                child: Text(
                  status == "Connected"
                      ? "ECU Connected"
                      : "Dongle Disconnected",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    //fontFamily: "OpenSans-Regular",
                    color: getStatusColor(status),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color getStatusColor(String status) {
    if (status == "Connected") return Colors.green.shade700;
    if (status == "Disconnected") return Colors.red;
    return Colors.grey;
  }
}
