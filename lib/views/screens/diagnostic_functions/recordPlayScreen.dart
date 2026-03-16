import 'package:autopeepal/logic/controller/diagnosticFunctions/recordPlayController.dart';
import 'package:autopeepal/services/iFilesaver_service.dart';
import 'package:autopeepal/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:autopeepal/models/liveParameter_model.dart';

class RecordPlayScreen extends StatelessWidget {
  final List<PidCode> selectedPIDs;
  final IFileSaver fileSaver;

  const RecordPlayScreen({
    super.key,
    required this.selectedPIDs,
    required this.fileSaver,
  });

  @override
  Widget build(BuildContext context) {
    final RecordPlayController controller = Get.put(
      RecordPlayController(
        fileSaver: fileSaver,
        initialSelection: selectedPIDs,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.pagebgColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          "Live Parameters",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),

        /// BACK BUTTON
        leading: Obx(
          () => IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: controller.isBackButtonEnabled.value
                ? () {
                    controller.isPlaying.value = false;
                    controller.isRecording.value = false;
                    controller.isLoopRunning.value = false;

                    Get.back();
                  }
                : null,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            /// PID LIST
            Expanded(
              child: Obx(
                () => ListView.separated(
                  itemCount: controller.selectedParameterList.length,
                  itemBuilder: (context, index) {
                    final pid = controller.selectedParameterList[index];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// PID NAME
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          child: Text(
                            pid.shortName ?? "Unknown PID",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),

                        ...?pid.piCodeVariable?.map(
                          (variable) => Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 5),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// VALUE + UNIT
                                    Row(
                                      children: [
                                        Text(
                                          variable.showResolution ?? "--",
                                          style: const TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                        if (variable.isUnitVisible == true)
                                          Text(
                                            " ${variable.unit}",
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                      ],
                                    ),

                                    /// RANGE
                                    Text(
                                      "( Range : ${variable.min ?? 0} - ${variable.max ?? 0} )",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              /// DIVIDER FOR EACH VARIABLE
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: AppColors.primaryColor.withOpacity(0.2),
                                indent: 16,
                                endIndent: 16,
                              ),
                            ],
                          ),
                        )
                      ],
                    );
                  },
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.primaryColor.withOpacity(0.3),
                    indent: 12,
                    endIndent: 12,
                  ),
                ),
              ),
            ),

            /// CONTROL BUTTONS
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  /// PLAY BUTTON
                  Obx(
                    () => Column(
                      children: [
                        InkWell(
                          onTap: controller.togglePlay,
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            padding: const EdgeInsets.all(18),
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
                    ),
                  ),

                  /// RECORD BUTTON
                  Obx(
                    () => Column(
                      children: [
                        InkWell(
                          onTap: controller.toggleRecord,
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            padding: const EdgeInsets.all(18),
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
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
