import 'package:autopeepal/logic/controller/diagnosticFunctions/sessionController.dart';
import 'package:autopeepal/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SessionLogsScreen extends StatelessWidget {
  final SessionController controller = Get.put(SessionController());
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: AppColors.pagebgColor,
      appBar: AppBar(
        title:
            const Text("Session Logs", style: TextStyle(color: Colors.white,fontSize: 18)),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: Colors.black87,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            onSelected: (value) {
              if (value == 'save') {
                controller.saveLogs();
              } else if (value == 'clear') {
                controller.clearLogs();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 'save',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'clear',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Clear',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ];
            },
          )
        ],
      ),
      body: Obx(() {
        // Scroll to bottom logic
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients) {
            scrollController.jumpTo(scrollController.position.maxScrollExtent);
          }
        });

        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemCount: controller.logs.length,
          itemBuilder: (context, index) {
            final log = controller.logs[index];
            bool isTx = log.header?.toUpperCase() == "TX";
            Color logColor = isTx ? Colors.green.shade700 : Colors.red.shade700;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'monospace',
                    color: logColor,
                  ),
                  children: [
                    TextSpan(
                      text: "${log.header} : ",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    TextSpan(
                      text: "${log.message}",
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
