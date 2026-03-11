import 'package:autopeepal/common_widgets/ui_helper_widgets.dart';
import 'package:autopeepal/logic/controller/diagnosticFunctions/diagnosticFunctionsController.dart';
import 'package:autopeepal/models/jobCard_model.dart';
import 'package:autopeepal/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DiagnosticFunctions extends StatelessWidget {
  DiagnosticFunctions({super.key});

  final AppFeatureController controller =
      Get.put(AppFeatureController(jobCardSession: JobCardListModel()));

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isMobile = width < 600;
    bool isTablet = width >= 600 && width < 1024;

    int gridCount = isMobile
        ? 2
        : isTablet
            ? 3
            : 4;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppColors.pagebgColor,
        appBar: AppBar(
          toolbarHeight: isMobile ? 60 : 80,
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.primaryColor,
          title: Text(
            "Diagnostic Functions",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: isMobile ? 20 : 28,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                controller.checkSessionLogs();
              },
              icon: Image.asset(
                "assets/new/ic_session_log.png",
                height: isMobile ? 35 : 50,
                width: isMobile ? 35 : 50,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: () {
                controller.fotaCommand();
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
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  padding: const EdgeInsets.all(20),
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
                              controller.selectedSubModel.value),
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
                verticalSpace(isMobile ? 15 : 30),
                GestureDetector(
                  onTap: () async {
                    print("Disconnect icon tapped...");
                    await controller
                        .disconnectDongle(context); // call our fixed function
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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Obx(() => GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gridCount,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                        ),
                        itemCount: controller.featureList.length,
                        itemBuilder: (context, index) {
                          final feature = controller.featureList[index];
                          return functionCard(
                            context: context,
                            title: feature.name ?? '',
                            imagePath: feature.image ?? '',
                            onTap: () =>
                                controller.onFeatureTap(feature, context),
                          );
                        },
                      )),
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

            /// Status with colored dot (centered)
            Expanded(
              flex: 3,
              child: Center(
                  child: Text(
                controller.getStatusText(status),
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: getStatusColor(status),
                ),
              )),
            ),
          ],
        ),
      ],
    );
  }

  /// Helper to get color based on status
  Color getStatusColor(String status) {
    switch (status) {
      case "Connected":
        return Colors.green.shade700;

      case "Dongle Disconnected":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget functionCard({
    required BuildContext context,
    required String title,
    required String imagePath,
    VoidCallback? onTap,
  }) {
    double width = MediaQuery.of(context).size.width;
    bool isMobile = width < 600;
    bool isTablet = width >= 600 && width < 1024;

    double iconSize = isMobile
        ? 60
        : isTablet
            ? 80
            : 100;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black38.withOpacity(0.09),
              blurRadius: 6,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: iconSize,
              width: iconSize,
              fit: BoxFit.contain,
            ),
            verticalSpace(10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
