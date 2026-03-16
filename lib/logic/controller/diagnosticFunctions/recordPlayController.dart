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

  /// Selected PIDs
  RxList<PidCode> selectedParameterList = <PidCode>[].obs;

  /// States
  RxBool isPlaying = false.obs;
  RxBool isRecording = false.obs;
  RxBool isLoopRunning = false.obs;

  /// UI
  RxBool isBackButtonEnabled = true.obs;

  /// CSV buffer
  StringBuffer? csvBuffer;

 Future<void> _init() async {
  await getPidsValue(isRecording: false);
}

  /// Read PID values
  Future<void> getPidsValue({required bool isRecording}) async {
    try {
      final readPidResp =
          await App.dllFunctions!.readPid(selectedParameterList);

      if (readPidResp != null) {
        setPidValue(readPidResp, isRecording);
      }
    } catch (e) {
      print("PID Read Error: $e");
    }
  }

  /// Update PID values
  void setPidValue(List<ReadPidResponseModel> readPidResp, bool recording) {
    final values = <String>[DateTime.now().toIso8601String()];

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

          variable.isUnitVisible = true;

          if (recording && pidCode.isStatic != true) {
            values.add(variable.showResolution ?? '');
          }
        }
      } else {
        for (var variable in pidCode.piCodeVariable ?? []) {
          variable.showResolution = respPid.status;
          variable.isUnitVisible = false;

          if (recording && pidCode.isStatic != true) {
            values.add(respPid.status ?? '');
          }
        }
      }
    }

    if (recording) {
      csvBuffer?.writeln(values.join(','));
    }

    selectedParameterList.refresh();
  }

  /// PID read loop
  Future<void> startLoop() async {
    if (isLoopRunning.value) return;

    isLoopRunning.value = true;

    while (isLoopRunning.value) {
      await getPidsValue(isRecording: isRecording.value);

      await Future.delayed(const Duration(milliseconds: 30));
    }
  }

  /// PLAY / PAUSE
  void togglePlay() {
    if (isPlaying.value) {
      isPlaying.value = false;
      isLoopRunning.value = false;
    } else {
      isPlaying.value = true;
      startLoop();
    }
  }

Future<void> toggleRecord() async {

  if (isSaving.value) return;

  if (isRecording.value) {
    await stopRecording();
  } else {
    startRecording();
  }
}

  // void startRecording() {
  //   if (isRecording.value) return; // prevent duplicate start

  //   csvBuffer = StringBuffer();

  //   csvBuffer!.writeln("Date/Time Units Range,Eng Speed rpm(0-0)");

  //   isRecording.value = true;
  //   isPlaying.value = true;

  //   isBackButtonEnabled.value = false;

  //   startLoop();
  // }

  // Future<void> stopRecording() async {
  //   if (!isRecording.value) return;

  //   isRecording.value = false;

  //   isLoopRunning.value = false;
  //   isPlaying.value = false;

  //   isBackButtonEnabled.value = true;

  //   if (csvBuffer != null && csvBuffer!.isNotEmpty) {
  //     String fileName =
  //         "SiDia_Live_Parameter_Log_${DateTime.now().toIso8601String().replaceAll(':', '_')}.csv";

  //     await fileSaver.saveFile(csvBuffer!.toString(), fileName);

  //     csvBuffer = null;
  //   }
  // }
  RxBool isSaving = false.obs;
  void startRecording() {
    print("START RECORDING CALLED");
    print("isRecording before start: ${isRecording.value}");

    if (isRecording.value) {
      print("Recording already running - skipping start");
      return;
    }

    csvBuffer = StringBuffer();

    print("CSV buffer created");

    csvBuffer!.writeln("Date/Time Units Range,Eng Speed rpm(0-0)");

    isRecording.value = true;
    isPlaying.value = true;

    print("Recording state set to TRUE");
    print("Play state set to TRUE");

    isBackButtonEnabled.value = false;

    print("Back button disabled");

    startLoop();

    print("PID loop started");
  }

 Future<void> stopRecording() async {
  if (!isRecording.value) return;

  isRecording.value = false;
  isLoopRunning.value = false;
  isPlaying.value = false;

  isBackButtonEnabled.value = true;

  if (csvBuffer != null && csvBuffer!.isNotEmpty) {

    String fileName =
        "SiDia_Live_Parameter_Log_${DateTime.now().toIso8601String().replaceAll(':', '_')}.csv";

    // Ask folder only when saving
    await fileSaver.selectFolder();

    await fileSaver.saveFile(csvBuffer!.toString(), fileName);

    csvBuffer = null;
  }
}
}
