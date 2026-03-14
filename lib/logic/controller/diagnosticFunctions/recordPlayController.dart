import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:autopeepal/services/iFilesaver_service.dart';
import 'package:autopeepal/app.dart';
import 'package:autopeepal/models/liveParameter_model.dart';

class RecordPlayController extends GetxController {
  final IFileSaver fileSaver;

  RecordPlayController({
    required this.fileSaver,
    required List<PidCode> initialSelection,
  }) {
    selectedParameterList.value = List<PidCode>.from(initialSelection);
    _init();
  }

  /// PID selection
  RxList<PidCode> selectedParameterList = <PidCode>[].obs;

  /// Recording / Playing flags
  RxBool isRecording = false.obs;
  RxBool isPlaying = false.obs;

  /// CSV buffer
  StringBuffer? csvBuffer;

  /// UI state
  RxString playStopText = "Play".obs;
  RxString recordText = "Record".obs;
  RxString playPauseImage = "assets/new/play.png".obs;
  RxString recordingImage = "assets/new/ic_recording.png".obs;
  Rx<Color> recordingBackgroundColor = Colors.red.obs;
  RxBool isBackButtonEnabled = true.obs;

  /// Busy state
  RxBool isBusy = false.obs;
  RxString loaderText = ''.obs;

  /// PID reading flag
  RxBool isReadingPid = false.obs;

  /// Initialize by reading PIDs once
  Future<void> _init() async {
    isReadingPid.value = true;
    await Future.delayed(const Duration(milliseconds: 10));
    await getPidsValue(isRecording: false);
    isReadingPid.value = false;
  }

  /// Read PID values
  Future<void> getPidsValue({required bool isRecording}) async {
    try {
      isReadingPid.value = true;

      final readPidResp =
          await App.dllFunctions!.readPid(selectedParameterList);
      if (readPidResp != null) {
        setPidValue(readPidResp, isRecording);
      }
    } catch (e) {
      print("Error reading PIDsrrrrrrrrr: $e");
    } finally {
      isReadingPid.value = false;
    }
  }

  /// Update PID values and optionally save to CSV
  void setPidValue(List<ReadPidResponseModel> readPidResp, bool isRecording) {
    if (readPidResp.isEmpty) return;

    final List<String> values = [DateTime.now().toIso8601String()];

    for (var respPid in readPidResp) {
      final pidCode =
          selectedParameterList.firstWhereOrNull((x) => x.id == respPid.pidId);
      if (pidCode == null) continue;

      if (respPid.status == "NOERROR") {
        for (var variable in pidCode.piCodeVariable ?? []) {
          final item = respPid.variables
              ?.firstWhereOrNull((x) => x.pidNumber == variable.id);
          variable.showResolution = (item?.responseValue?.isNotEmpty ?? false)
              ? item!.responseValue
              : "Not Found";

          if (isRecording && pidCode.isStatic != true) {
            values.add(variable.showResolution ?? '');
          }

          variable.isUnitVisible = true;
        }
      } else {
        for (var variable in pidCode.piCodeVariable ?? []) {
          variable.showResolution = respPid.status;
          variable.isUnitVisible = false;

          if (isRecording && pidCode.isStatic != true) {
            values.add(respPid.status ?? '');
          }
        }
      }
    }

    if (isRecording) {
      csvBuffer?.writeln(values.join(','));
    }
  }
  RxBool isPlayingLoop = false.obs;
Future<void> loopRead() async {
  isPlayingLoop.value = true;
  try {
    while (isPlayingLoop.value) {
      isRecording.value = recordText.value == "Recording";
      await getPidsValue(isRecording: isRecording.value);
      await Future.delayed(const Duration(milliseconds: 50));
    }
  } catch (e) {
    print("Error in loopRead: $e");
  }
}
void togglePlay() {
  if (isPlaying.value) {
    // Stop current loop
    isPlayingLoop.value = false;
    isPlaying.value = false;
    playStopText.value = "Play";
    playPauseImage.value = "assets/new/play.png";
  } else {
    // Start playing
    isPlaying.value = true;
    isRecording.value = false; // stop recording if it was
    playStopText.value = "Stop";
    playPauseImage.value = "assets/new/ic_pause.png";
    loopRead(); // start loop
  }
}

  void toggleRecord() {
  if (isRecording.value) {
    // Stop recording
    isRecording.value = false;
    pidRecordingClicked(start: false);
  } else {
    // Start recording
    isRecording.value = true;
    isPlaying.value = false;
    isPlayingLoop.value = false; // stop any playing loop
    pidRecordingClicked(start: true);
  }
}

  /// Handle CSV recording
  Future<void> pidRecordingClicked({required bool start}) async {
    if (start) {
      // Start recording
      csvBuffer = StringBuffer();
      csvBuffer!.writeln();
      csvBuffer!.writeln();

      recordText.value = "Recording";
      recordingImage.value = "assets/new/ic_record_stop.png";
      recordingBackgroundColor.value = Colors.red;

      if (playStopText.value == "Play") {
        playStopText.value = "Stop";
        playPauseImage.value = "assets/new/ic_pause.png";
        loopRead();
      }
    } else {
      // Stop recording
      recordText.value = "Record";
      recordingImage.value = "assets/new/ic_recording.png";
      recordingBackgroundColor.value = Colors.grey;

      if (csvBuffer != null) {
        String fileName =
            "SiDia_Live_Parameter_Log_${DateTime.now().toIso8601String().replaceAll(':', '_')}.csv";
        await fileSaver.saveFile(csvBuffer!.toString(), fileName);
      }
    }
  }
}
