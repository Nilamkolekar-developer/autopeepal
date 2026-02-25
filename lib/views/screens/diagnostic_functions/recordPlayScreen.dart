import 'package:autopeepal/logic/controller/diagnosticFunctions/recordPlayController.dart';
import 'package:autopeepal/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RecordPlayScreen extends StatelessWidget {
  final List<String> selectedItems;

  RecordPlayScreen({super.key, required this.selectedItems});
  final RecordPlayController controller = Get.put(RecordPlayController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pagebgColor,
      appBar: AppBar(
        title: const Text(
          'Live Parameters',
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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      itemCount: selectedItems.length + 1,
                      itemBuilder: (context, index) {
                        if (index == selectedItems.length) {
                          return const SizedBox.shrink();
                        }

                        return ListTile(
                          title: Text(
                            selectedItems[index],
                            style: const TextStyle(color: Colors.black),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Divider(
                          height: 1,
                          thickness: 1,
                          color: AppColors.primaryColor.withOpacity(0.3),
                          indent: 12,
                          endIndent: 12,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  /// ▶ PLAY BUTTON
                  Obx(() => Column(
                        children: [
                          InkWell(
                            onTap: controller.togglePlay,
                            borderRadius: BorderRadius.circular(50),
                            child: Container(
                              padding:
                                  const EdgeInsets.all(18), // 👈 controls size
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primaryColor,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppColors.primaryColor.withOpacity(0.4),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                controller.isPlaying.value
                                    ? "assets/new/ic_pause.png"
                                    : "assets/new/ic_play.png",
                                height: 32,
                                width: 32,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            controller.isPlaying.value ? "Pause" : "Play",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )),

                  /// 🔴 RECORD BUTTON
                  Obx(() => Column(
                        children: [
                          InkWell(
                            onTap: controller.toggleRecord,
                            borderRadius: BorderRadius.circular(50),
                            child: Container(
                              padding: const EdgeInsets.all(
                                  18), 
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: controller.isRecording.value
                                    ? Colors.red
                                    : AppColors.primaryColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: (controller.isRecording.value
                                            ? Colors.red
                                            : AppColors.primaryColor)
                                        .withOpacity(0.5),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                controller.isRecording.value
                                    ? "assets/new/ic_record_stop.png"
                                    : "assets/new/ic_recording.png",
                                height: 32,
                                width: 32,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            controller.isRecording.value ? "Stop" : "Record",
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
