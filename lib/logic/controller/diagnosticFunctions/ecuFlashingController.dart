import 'dart:async';
import 'dart:typed_data';
import 'package:autopeepal/app.dart';
import 'package:autopeepal/common_widgets/popup.dart';
import 'package:autopeepal/models/all_models.dart';
import 'package:autopeepal/models/flashRecord_model.dart';
import 'package:autopeepal/models/staticData.dart';
import 'package:autopeepal/services/filePicker_service.dart';
import 'package:autopeepal/services/getJson_service.dart';
import 'package:autopeepal/utils/save_local_data.dart';
import 'package:get/get.dart';

class Ecuflashingcontroller extends GetxController {
  var ecusList = <FlashEcusModel>[].obs;
  var flashFileList = <File>[].obs;
  var staticFlashFileList = <File>[].obs;
  final SaveLocalData saveLocalData = SaveLocalData();
  Rx<FlashEcusModel?> selectedEcu = Rx<FlashEcusModel?>(null);
  Rx<File?> selectedFlashFile = Rx<File?>(null);
  RxString selectedFlashFileString = "".obs;
  var isBusy = false.obs;
  var loaderText = "".obs;
  var isFlashBtnVisible = false.obs;
  Timer? swTimer;
  Timer? percentTimer;
  Stopwatch stopwatch = Stopwatch();
  RxBool timerStatus = false.obs;
  RxBool timerVisible = false.obs;
  RxBool flashProgressVisible = false.obs;
  RxDouble progress = 0.0.obs;
  RxString flashPercent = "0.0%".obs;
  RxString flashPercentText = "0.0%".obs;
  RxString flashTimer = "00 : 00".obs;
  FlashData? flashData;
  String? flashDatasetFile;
  RxBool flashFileViewVisible = true.obs;
  List<EcuMapFile>? parsedEcuMapFiles;
  RxString serverMessage = "".obs;
  RxString messageTitle = "".obs;
  RxString message = "".obs;
  RxString status = "".obs;
  RxBool extraViewVisible = false.obs;
  RxBool isNavigate = false.obs;
  RxBool isLocalFile = false.obs;

  int count1 = 0;
  @override
  void onInit() {
    super.onInit();
    getFlashFileList();
  }

  Future<void> getFlashFileList() async {
    try {
      print("[FLASH] Starting getFlashFileList...");
      ecusList.clear();
      isBusy.value = true;
      await Future.delayed(const Duration(milliseconds: 20));
      count1 = 0;

      for (var ecu in StaticData.ecuInfo) {
        count1++;
        final flashEcu = FlashEcusModel(
          ecuName: ecu.ecuName,
          id: ecu.ecuID,
          opacity: count1 == 1 ? 1.0 : 0.5,
          seedkeyalgoFnIndexValues: ecu.seedKeyIndex,
          txHeader: ecu.txHeader,
          rxHeader: ecu.rxHeader,
          protocol: ecu.protocol,
          flashFileList: [],
          ecu2: ecu.ecu2,
        );
        if (ecu.ecu2?.file != null) {
          flashEcu.flashFileList = List<File>.from(ecu.ecu2!.file!);
        }
        ecusList.add(flashEcu);
      }
      print("[FLASH] Total ECUs Loaded: ${ecusList.length}");
      staticFlashFileList.clear();
      flashFileList.clear();
      if (ecusList.isNotEmpty) {
        selectedEcu.value = ecusList.first;
        if (selectedEcu.value?.flashFileList != null &&
            selectedEcu.value!.flashFileList!.isNotEmpty) {
          staticFlashFileList.assignAll(selectedEcu.value!.flashFileList!);
          flashFileList.assignAll(selectedEcu.value!.flashFileList!);
          selectedFlashFile.value = flashFileList.first;
          isFlashBtnVisible.value = true;
        }
        await setDongleProperties();
        print("[FLASH] Dongle properties set");
      }

      isBusy.value = false;
      loaderText.value = "";
      print("[FLASH] getFlashFileList completed successfully");
    } catch (e, st) {
      isBusy.value = false;
      loaderText.value = "";
      print("[FLASH][ERROR] Exception: $e");
      print("[FLASH][STACKTRACE] $st");

      await Get.dialog(
        CustomPopup(
          title: "Exception in GetFlashFileList",
          message: e.toString(),
          onButtonPressed: () => Get.back(),
        ),
        barrierDismissible: false,
      );
    }
  }

  Future<void> initFlashing() async {
    try {
      print("[FLASH] InitFlashing started");
      isBusy.value = true;
      loaderText.value = "Loading...";
      await Future.delayed(const Duration(milliseconds: 50));
      final sequenceLocalFile = await saveLocalData
          .getData("flashRecord_sequence_file_${selectedEcu.value?.ecu2?.id}");
      print("[FLASH] sequenceLocalFile: $sequenceLocalFile");
      final ecu = selectedEcu.value;
      final file = selectedFlashFile.value;
      if (ecu == null) {
        await Get.dialog(
          CustomPopup(
            title: "Error",
            message: "Selected ECU is null!",
            onButtonPressed: () => Get.back(),
          ),
          barrierDismissible: false,
        );

        _resetFlags();
        return;
      }
      if (ecu.ecu2 == null || ecu.seedkeyalgoFnIndexValues == null) {
        await Get.dialog(
          CustomPopup(
            title: "Error",
            message: "Selected ECU data is incomplete!",
            onButtonPressed: () => Get.back(),
          ),
          barrierDismissible: false,
        );

        _resetFlags();
        return;
      }
      if (file == null) {
        await Get.dialog(
          CustomPopup(
            title: "Error",
            message: "Selected flash file is null!",
            onButtonPressed: () => Get.back(),
          ),
          barrierDismissible: false,
        );

        _resetFlags();
        return;
      }
      flashData = FlashData(
        ecu2: ecu.ecu2!,
        seedkeyalgoFnIndexValues: ecu.seedkeyalgoFnIndexValues!,
        dwnldSeqFileUrl: sequenceLocalFile,
        file: file,
      );
      print("[FLASH] flashData initialized");
      if (isLocalFile.value == true) {
        if ((file.dwnldDataFile ?? '').isEmpty) {
          await Get.dialog(
            CustomPopup(
              title: "Error",
              message: "Local flash file data is empty!",
              onButtonPressed: () => Get.back(),
            ),
            barrierDismissible: false,
          );

          _resetFlags();
          return;
        }
        flashData!.file?.dwnldDataFile = file.dwnldDataFile ?? '';
        print("[FLASH] Using local file data");
      } else {
        final localFileData =
            await saveLocalData.getData("file_data_file_${file.id ?? ''}");
        if (localFileData.isEmpty) {
          await Get.dialog(
            CustomPopup(
              title: "Error",
              message: "File data not found in local storage!",
              onButtonPressed: () => Get.back(),
            ),
            barrierDismissible: false,
          );

          _resetFlags();
          return;
        }
        flashData!.file?.dwnldDataFile = localFileData;
        print("[FLASH] Loaded file data from local storage");
      }
      if ((flashData?.file?.dwnldDataFile ?? '').isEmpty) {
        await Get.dialog(
          CustomPopup(
            title: "Alert!",
            message: "File not downloaded.\nPlease update local data",
            onButtonPressed: () => Get.back(),
          ),
          barrierDismissible: false,
        );

        _resetFlags();
        return;
      }
      if ((flashData?.dwnldSeqFileUrl ?? '').isEmpty) {
        await Get.dialog(
          CustomPopup(
            title: "Alert!",
            message: "Sequence file not available.\nPlease update local data",
            onButtonPressed: () => Get.back(),
          ),
          barrierDismissible: false,
        );

        _resetFlags();
        return;
      }
      if ((file.dataFile ?? '').contains(".json")) {
        flashDatasetFile = file.dwnldDataFile ?? '';
        print("[FLASH] Using JSON file directly");
        selectedEcu.value!.ecuMapFile = parsedEcuMapFiles ?? [];
      } else {
        flashDatasetFile = await readJson(
          flashData?.dwnldSeqFileUrl ?? '',
          Uint8List.fromList(flashData?.file?.dwnldDataFile?.codeUnits ?? []),
        );
        print("[FLASH] JSON converted from sequence file");
        selectedEcu.value!.ecuMapFile = parsedEcuMapFiles;

        print(
            "[DEBUG] ecuMapFile count: ${selectedEcu.value!.ecuMapFile?.length}");
      }
      if ((flashDatasetFile ?? '').isEmpty) {
        await Get.dialog(
          CustomPopup(
            title: "Alert!",
            message: "Failed to convert Datafile.",
            onButtonPressed: () => Get.back(),
          ),
          barrierDismissible: false,
        );

        _resetFlags();
        return;
      }

      print("[FLASH] File ready for flashing");
      isBusy.value = false;
      loaderText.value = "";
      isFlashBtnVisible.value = false;
      timerr();
      startFlashing();

      print("[FLASH] Flashing started successfully");
    } catch (e) {
      print("[FLASH] Exception @initFlashing(): $e");
      await Get.dialog(
        CustomPopup(
          title: "Exception @initFlashing()",
          message: e.toString(),
          onButtonPressed: () => Get.back(),
        ),
        barrierDismissible: false,
      );

      _resetFlags(showFlashBtn: true);
    }
  }

  void _resetFlags({bool showFlashBtn = false}) {
    isBusy.value = false;
    loaderText.value = "";
    isFlashBtnVisible.value = showFlashBtn;
  }

  void selectDataset(dynamic arg) {
    try {
      selectedFlashFile.value = arg as File;
      flashFileViewVisible.value = false;
      isFlashBtnVisible.value = true;
      isLocalFile.value = false;
    } catch (e) {
      print("Error selecting dataset: $e");
    }
  }

  void switchTab(dynamic arg) async {
    try {
      selectedEcu.value = arg as FlashEcusModel;
      Future.microtask(() async {
        try {
          isBusy.value = true;
          loaderText.value = "Loading...";
          await Future.delayed(const Duration(milliseconds: 100));
          selectedEcu.value?.opacity = 1;
          flashFileList.clear();
          staticFlashFileList.clear();
          for (var ecu in ecusList) {
            if (selectedEcu.value?.id == ecu.id) {
              ecu.opacity = 1;
              flashFileList.assignAll(ecu.flashFileList ?? []);
              staticFlashFileList.assignAll(ecu.flashFileList ?? []);

              await setDongleProperties();
            } else {
              ecu.opacity = 0.5;
            }
          }

          isBusy.value = false;
          loaderText.value = "";
        } catch (e) {
          print("Inner error: $e");
        }
      });
    } catch (e) {
      print("SwitchTab error: $e");
    }
  }

  void flashCommand() async {
    try {
      print("[FLASH] 🔹 flashCommand started");

      String flashPopupMsg = '''
1. Engine ignition to be in ON condition
2. Battery voltage to be maintain as 12 V
3. All electrical connections to be intact
4. Mobile / Laptop batteries should not be with low charge indication
5. Ensure the appropriate dataset to be selected
6. Ensure no interruption during flashing process
''';

      print("[FLASH] 🔹 Showing flash alert dialog");

      bool? resp = await Get.dialog<bool>(
        CustomPopup(
          title: "Alert!",
          message: flashPopupMsg,
          onConfirm: () {
            print("[FLASH] ✅ User pressed OK");
            Get.back(result: true);
          },
          showCancel: true,
          onCancel: () {
            print("[FLASH] ⚠️ User pressed Cancel");
            Get.back(result: false);
          },
        ),
        barrierDismissible: false,
      );

      print("[FLASH] 🔹 Dialog response: $resp");

      if (resp == true) {
        print("[FLASH] 🔹 Starting initFlashing");
        await initFlashing();
        print("[FLASH] 🔹 initFlashing completed");
      } else {
        print("[FLASH] ⚠️ Flashing canceled by user");
      }
    } catch (e) {
      print("[FLASH][flashCommand error] $e");
    }
  }

  final FilePickerService _pickerService = FilePickerService();
  // Future<void> browseFile() async {
  //   try {
  //     final result = await _pickerService.pickFileAsync();

  //     if (result != null &&
  //         result.fileName.isNotEmpty &&
  //         result.fileContent.isNotEmpty) {
  //       selectedFlashFile.value = File(
  //         dataFileName: result.fileName,
  //         dwnldDataFile: result.fileContent,
  //         dataFile: '',
  //       );

  //       flashFileViewVisible.value = false;
  //       isLocalFile!.value = true;
  //       isFlashBtnVisible.value = true;

  //       print('[FLASH] File picked: ${selectedFlashFile.value!.dataFileName}');
  //     } else {
  //       await Get.dialog(
  //         CustomPopup(
  //           title: "Alert!",
  //           message: "No Data File pick",
  //           onButtonPressed: () => Get.back(),
  //         ),
  //         barrierDismissible: false,
  //       );
  //       print('[FLASH] No file was picked');
  //     }
  //   } catch (e) {
  //     print('[FLASH][ERROR] $e');
  //   }
  // }
  Future<void> browseFile() async {
    try {
      final result = await _pickerService.pickFileAsync();

      if (result != null &&
          result.fileName.isNotEmpty &&
          result.fileContent.isNotEmpty) {
        final newFile = File(
          dataFileName: result.fileName,
          dwnldDataFile: result.fileContent,
          dataFile: '',
        );

        selectedFlashFile.value = newFile;

        // ✅ ADD FILE TO DROPDOWN LIST
        final exists = flashFileList.any(
          (e) => e.dataFileName == result.fileName,
        );

        if (!exists) {
          flashFileList.add(newFile);
        }

        // ✅ SET SELECTED VALUE IN DROPDOWN
        selectedFlashFileString.value = result.fileName;

        flashFileViewVisible.value = false;
        isLocalFile.value = true;
        isFlashBtnVisible.value = true;

        print('[FLASH] File picked: ${newFile.dataFileName}');
      } else {
        await Get.dialog(
          CustomPopup(
            title: "Alert!",
            message: "No Data File pick",
            onButtonPressed: () => Get.back(),
          ),
          barrierDismissible: false,
        );
      }
    } catch (e) {
      print('[FLASH][ERROR] $e');
    }
  }

  Future<String> readJson(
      String interpreterData, Uint8List flashFileBytes) async {
    try {
      isBusy.value = true;
      loaderText.value = "Processing Dataset...";
      print("[FLASH] 🔹 Started readJson");

      await Future.delayed(const Duration(milliseconds: 100));

      List<EcuMapFile> ecuMapFiles = [];
      String checksumAlgo = "";

      if (interpreterData.isNotEmpty &&
          interpreterData.contains("EcuMapFile")) {
        final lines = interpreterData.split('\n');
        print("[FLASH] 🔹 Interpreter data lines: ${lines.length}");

        for (var line in lines) {
          final formatted = line.replaceAll("\r", "").trim();
          if (formatted.isEmpty || formatted.startsWith("//")) continue;

          String command = "";
          String info = "";

          if (formatted.contains(":")) {
            final parts = formatted.split(":");
            command = parts[0];
            info = parts.length > 1 ? parts[1] : "";
          } else {
            command = formatted;
          }

          print("[FLASH] 🔹 Parsed line -> command: '$command', info: '$info'");

          if (command == "EcuMapFile") {
            final ecuMap = EcuMapFile();
            final splitData = info.split('+');

            for (var item in splitData) {
              int endIndex = item.indexOf('>');
              if (endIndex == -1) continue;

              String bracketStr = item.substring(1, endIndex);
              final values = bracketStr.split(',');

              String reference = values[0];
              if (reference.contains("start_address")) {
                ecuMap.startAddress = values[1];
                ecuMap.startAddr = int.parse(values[1], radix: 16);
                print(
                    "[FLASH] 🔹 EcuMap startAddress: ${ecuMap.startAddress}, startAddr: ${ecuMap.startAddr}");
              } else if (reference.contains("end_address")) {
                ecuMap.endAddress = values[1];
                ecuMap.endAddr = int.parse(values[1], radix: 16);
                print(
                    "[FLASH] 🔹 EcuMap endAddress: ${ecuMap.endAddress}, endAddr: ${ecuMap.endAddr}");
              }
            }

            ecuMapFiles.add(ecuMap);
            print(
                "[FLASH] 🔹 Added EcuMapFile, total count: ${ecuMapFiles.length}");
          } else if (command.toLowerCase().contains("chksum")) {
            checksumAlgo = info.trim();
            print("[FLASH] 🔹 Checksum algorithm found: $checksumAlgo");
          }
        }
      } else {
        print("[FLASH] ⚠️ No valid interpreter data or missing EcuMapFile");
      }
      print("[FLASH] 🔹 Converting flash file to JSON...");
      final getJson = GetJson();
      final flashJson = await getJson.convertToJson(
          flashFileBytes, ecuMapFiles, checksumAlgo);
      parsedEcuMapFiles = ecuMapFiles;
      print("[FLASH] 🔹 Conversion done, JSON length: ${flashJson.length}");

      _resetLoader();

      return flashJson;
    } catch (e) {
      print("[FLASH][readJson error] $e");
      _resetLoader();
      return '';
    }
  }

  void _setBusy(bool busy, String text) {
    isBusy.value = busy;
    loaderText.value = text;
  }

  void _resetLoader() => _setBusy(false, "");

  void timerr() {
    stopwatch = Stopwatch()..start();
    timerStatus.value = true;
    timerVisible.value = true;
    flashProgressVisible.value = true;
    swTimer?.cancel();
    swTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final minutes = stopwatch.elapsed.inMinutes.toString().padLeft(2, '0');
      final seconds =
          (stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, '0');
      flashTimer.value = "$minutes : $seconds";
    });

    percentTimer?.cancel();
    percentTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      try {
        double flashPercentValue = await App.dllFunctions!.flashingData();
        progress.value = flashPercentValue;
        flashPercent.value = "${(flashPercentValue * 100).toStringAsFixed(1)}%";
      } catch (e) {
        print("[FLASH] Error in percentTimer: $e");
      }
    });

    print("[FLASH] Timers started successfully");
  }

  void onSWTimerElapsed() {
    final minutes =
        stopwatch.elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');

    final seconds =
        stopwatch.elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');

    flashTimer.value = "$minutes : $seconds";
  }

  void onPercentTimerElapsed() async {
    try {
      final double? flashPercentValue = await App.dllFunctions?.flashingData();

      if (flashPercentValue != null && !flashPercentValue.isNaN) {
        flashPercent.value = "${(flashPercentValue * 100).toStringAsFixed(1)}%";

        progress.value = flashPercentValue;
      }
    } catch (e) {
      print("Percent Timer error: $e");
    }
  }

  Future<void> startFlashing() async {
    try {
      print("[FLASH] StartFlashing initiated");
      serverMessage.value = "";
      messageTitle.value = "";
      message.value = "";
      status.value = "";

      extraViewVisible.value = true;
      print("[FLASH] extraViewVisible set to true");
      isNavigate.value = true;
      print("[FLASH] Back navigation disabled");
      print("[FLASH] flashData.ecu2: ${flashData?.ecu2}");
      print("[FLASH] selectedEcu.value: ${selectedEcu.value}");
      print(
          "[FLASH] selectedEcu.value?.ecuMapFile: ${selectedEcu.value?.ecuMapFile}");
      if (flashData?.ecu2 == null || selectedEcu.value?.ecuMapFile == null) {
        print("[FLASH] Error: Required ECU data missing");
        print("[FLASH] flashData?.ecu2 is null? ${flashData?.ecu2 == null}");
        print(
            "[FLASH] selectedEcu?.ecuMapFile is null? ${selectedEcu.value?.ecuMapFile == null}");
        _resetFlags(showFlashBtn: true);
        Get.dialog(
          CustomPopup(
            title: "Error",
            message: "Required ECU data missing",
            onButtonPressed: () => Get.back(),
          ),
          barrierDismissible: false,
        );
        return;
      }

      print("[FLASH] Starting ECU flashing...");
      final flashingResult = await App.dllFunctions!.startECUFlashing(
        flashDatasetFile!,
        flashData!.dwnldSeqFileUrl ?? '',
        flashData!.ecu2!,
        flashData?.seedkeyalgoFnIndexValues ?? "",
        selectedEcu.value!.ecuMapFile!,
      );
      print("[FLASH] ECU flashing finished, result: $flashingResult");
      stopwatch.stop();
      timerStatus.value = false;
      timerVisible.value = false;
      flashProgressVisible.value = false;
      swTimer?.cancel();
      percentTimer?.cancel();
      print("[FLASH] Timers stopped");
      isNavigate.value = false;
      print("[FLASH] Navigation re-enabled");

      isBusy.value = true;
      loaderText.value = "Loading...";
      await Future.delayed(const Duration(milliseconds: 50));
      if (flashingResult == null || flashingResult.isEmpty) {
        print("[FLASH] Flashing stopped: result null");
        messageTitle.value = "ERROR";
        message.value = "Flashing Stopped";
        status.value = "Flash result null";
      } else if (flashingResult != "NOERROR") {
        print("[FLASH] Flashing stopped with error: $flashingResult");
        messageTitle.value = "ERROR";
        message.value = "Flashing Stopped with following error";
        status.value = flashingResult;
      } else {
        print("[FLASH] Flashing successful");
        messageTitle.value = "Successful";
        message.value = "Flashing Successful";
        status.value = "";
      }

      isBusy.value = false;
      loaderText.value = "";
      print("[FLASH] Flags reset after flashing");
      print("[FLASH] Showing result dialog");
      Get.dialog(
        CustomPopup(
          title: messageTitle.value,
          message: "${message.value}\n${status.value}\n${serverMessage.value}",
          onButtonPressed: () => Get.back(),
        ),
        barrierDismissible: false,
      );

      extraViewVisible.value = false;
      print("[FLASH] extraViewVisible set to false");
    } catch (e) {
      isNavigate.value = false;
      print("[FLASH] Exception @StartFlashing(): $e");
      Get.dialog(
        CustomPopup(
          title: "Exception @StartFlashing()",
          message: e.toString(),
          onButtonPressed: () => Get.back(),
        ),
        barrierDismissible: false,
      );
    } finally {
      isNavigate.value = false;
      isFlashBtnVisible.value = true;
      print("[FLASH] Flash button re-enabled");
    }
  }

  void resetFlags({bool showFlashBtn = false}) {
    isBusy.value = false;
    loaderText.value = "";
    isFlashBtnVisible.value = showFlashBtn;
    stopwatch.stop();
    timerStatus.value = false;
    timerVisible.value = false;
    flashProgressVisible.value = false;
    swTimer?.cancel();
    percentTimer?.cancel();
    print("[FLASH] Timers stopped in _resetFlags");
  }

  RxString searchKey = "".obs;
  void searchFlashingFile() {
    try {
      if (staticFlashFileList.isNotEmpty) {
        if (searchKey.value.isNotEmpty) {
          flashFileList.assignAll(
            staticFlashFileList.where((file) => (file.dataFileName ?? "")
                .toLowerCase()
                .contains(searchKey.value.toLowerCase())),
          );
        } else {
          flashFileList.assignAll(staticFlashFileList);
        }
      }
    } catch (e) {
      print("Search error: $e");
    }
  }

  Future<void> setDongleProperties() async {
    try {
      final ecu = selectedEcu.value;

      if (ecu == null) {
        print("[DONGLE] No ECU selected");
        return;
      }

      print("""
[DONGLE] Setting properties:
Protocol: ${ecu.protocol?.autopeepal}
TX Header: ${ecu.txHeader}
RX Header: ${ecu.rxHeader}
""");

      await App.dllFunctions!.setDongleProperties(
        ecu.protocol!.autopeepal ?? '',
        ecu.txHeader ?? '',
        ecu.rxHeader ?? '',
      );

      print("[DONGLE] Properties set successfully");
    } catch (e, st) {
      print("[DONGLE][ERROR] $e");
      print("[DONGLE][STACKTRACE] $st");
    }
  }
}
