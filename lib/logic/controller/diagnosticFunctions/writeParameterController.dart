import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:autopeepal/app.dart';
import 'package:autopeepal/common_widgets/popup.dart';
import 'package:autopeepal/models/liveParameter_model.dart';
import 'package:autopeepal/models/staticData.dart';
import 'package:autopeepal/utils/save_local_data.dart';

class WriteParameterController extends GetxController {
  /// 🔹 Observables
  RxBool isBusy = false.obs;
  RxString loaderText = "".obs;
  RxString selectedPidName = "".obs;
  EcuModel? selectedEcu;
  RxList<EcuModel> ecuList = <EcuModel>[].obs;

  RxList<PidCode> staticPidList = <PidCode>[].obs;
  RxList<PidCode> pidList = <PidCode>[].obs;

  PidCode? selectedPidCode;
  RxString title = "Select a parameter to write".obs;
  RxString writeBtnText = "Write".obs;
  RxBool pidViewVisible = false.obs;

  RxString newValue = "".obs;
  Rx<TextEditingController> currentValueController =
      Rx(TextEditingController());
  Rx<TextEditingController> newValueController = Rx(TextEditingController());

  /// 🔹 PID Read Responses
  RxList<ReadPidResponseModel> readPidAndroid = <ReadPidResponseModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    getPidList();
  }

  @override
  void onClose() {
    currentValueController.value.dispose();
    newValueController.value.dispose();
    super.onClose();
  }

  /// 🔹 Get PID list for all ECUs from local storage
  Future<void> getPidList() async {
    isBusy.value = true;
    loaderText.value = "Loading...";
    await Future.delayed(const Duration(milliseconds: 10));

    try {
      ecuList.clear();
      for (var ecu in StaticData.ecuInfo) {
        final pidDatasetId = ecu.pidDatasetId;
        final pidLocalData =
            await SaveLocalData().getData("PidDataset_$pidDatasetId");

        if (pidLocalData.isNotEmpty) {
          final pidJson = jsonDecode(pidLocalData);
          final List<dynamic> codesJson = pidJson['codes'] ?? [];
          final List<PidCode> allPidList =
              codesJson.map((e) => PidCode.fromJson(e)).toList();

          final pidListForEcu = allPidList
              .where((x) => x.write == true)
              .toList()
            ..sort((a, b) => (a.priority ?? 0).compareTo(b.priority ?? 0));

          ecuList.add(EcuModel(
            ecuName: ecu.ecuName,
            opacity: ecuList.isEmpty ? 1.0 : 0.5,
            pidList: pidListForEcu,
            protocol: ecu.protocol,
            txHeader: ecu.txHeader,
            rxHeader: ecu.rxHeader,
            firingSequence: ecu.firingSequence,
            noOfInjectors: ecu.noOfInjectors,
          ));
        }
      }

      if (ecuList.isNotEmpty) {
        selectedEcu = ecuList.first;
        staticPidList.value = List<PidCode>.from(selectedEcu!.pidList);
        pidList.value = List<PidCode>.from(selectedEcu!.pidList);
      }

      await setDongleProperties();
    } catch (e) {
      print("❌ Error in getPidList: $e");
    } finally {
      isBusy.value = false;
      loaderText.value = "";
    }
  }

  /// 🔹 PID selection logic with IQA/Injector Handling
  Future<void> selectPidClicked(PidCode pid) async {
    selectedPidCode = pid;
    selectedPidName.value = pid.shortName ?? "";
    pidViewVisible.value = false;
    isBusy.value = true;
    loaderText.value = "Loading...";
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      if (pid.piCodeVariable != null && pid.piCodeVariable!.isNotEmpty) {
        // Sort variables by priority
        pid.piCodeVariable!
            .sort((a, b) => (a.priority ?? 0).compareTo(b.priority ?? 0));

        // Handle Reset State
        if (pid.reset ?? false) {
          writeBtnText.value = "Reset";
          for (var v in pid.piCodeVariable!) {
            v.writeValue = pid.resetValue!.obs;
            v.isReset = true;
          }
        } else {
          writeBtnText.value = "Write";
        }

        // Handle IQA Injector reordering based on firing sequence
        if (pid.piCodeVariable![0].messageType == "IQA") {
          if ((selectedEcu?.noOfInjectors ?? 0) == 0 ||
              (selectedEcu?.firingSequence ?? '').isEmpty) {
            _showDialog("Alert",
                "Injector or Firing Sequence data missing for this ECU.");
            return;
          }

          final firingOrder = selectedEcu!.firingSequence!
              .split(',')
              .map((s) => int.parse(s.trim()) - 1)
              .toList();

          if (firingOrder.length != (selectedEcu?.noOfInjectors ?? 0)) {
            _showDialog(
                "Alert", "Injector count does not match Firing Sequence.");
            return;
          }

          // Reorder the variables list based on the firing sequence
          pid.piCodeVariable = [
            ...firingOrder.map((i) => pid.piCodeVariable![i]),
            ...pid.piCodeVariable!
                .asMap()
                .entries
                .where((e) => !firingOrder.contains(e.key))
                .map((e) => e.value)
          ];
        }

        await getPidsValue();
      }
    } catch (e) {
      print("❌ Error in selectPidClicked: $e");
    } finally {
      isBusy.value = false;
      loaderText.value = "";
    }
  }

  Future<void> getPidsValue() async {
    try {
      if (selectedPidCode == null) return;

      // Build list with single PID
      List<PidCode> selectedPid = [selectedPidCode!];

      // Call DLL function to read the PID
      List<ReadPidResponseModel>? result =
          await App.dllFunctions!.readPid(selectedPid);

      if (result != null) {
        readPidAndroid.assignAll(result);
      }

      // Update PID values in the UI
      setPidValue();
    } catch (ex, stackTrace) {
      print("❌ Error in getPidsValue: $ex\n$stackTrace");
    }
  }

  void setPidValue() {
    if (readPidAndroid.isEmpty || selectedPidCode?.piCodeVariable == null)
      return;

    for (var pid in readPidAndroid) {
      if (pid.status == "NOERROR") {
        // Loop through variables in the selected PID
        for (var variable in selectedPidCode!.piCodeVariable!) {
          // Check if the PID response has variables
          if (pid.variables != null && pid.variables!.isNotEmpty) {
            final item = pid.variables!.firstWhere(
              (x) => x.pidNumber == variable.id,
              orElse: () => Variable(pidNumber: 0, responseValue: ""),
            );

            // Update reactive value for UI
            variable.showResolution.value = item.responseValue!;

            // Clear writeValue if not a reset variable
            if (!variable.isResetRx.value) {
              variable.writeValue.value = "";
            }
          }
        }
      } else {
        // PID read returned an error
        for (var variable in selectedPidCode!.piCodeVariable!) {
          variable.showResolution.value = "ERR";
          if (!variable.isResetRx.value) variable.writeValue.value = "";
        }
      }
    }

    // Update controllers after parsing PID values
    updateControllers();
  }

  void updateControllers() {
    if (selectedPidCode?.piCodeVariable?.isNotEmpty ?? false) {
      final variable = selectedPidCode!.piCodeVariable!.first;
      currentValueController.value.text = variable.showResolution.value;
      print(
          "Updated currentValueController: ${currentValueController.value.text}");

      // Initialize newValueController only if empty
      if (newValueController.value.text.isEmpty) {
        newValueController.value.text = variable.writeValue.value;
        print(
            "Initialized newValueController: ${newValueController.value.text}");
      }

      // Keep reactive value in sync without overwriting user input
      if (!Get.focusScope!.hasFocus) {
        newValue.value = newValueController.value.text;
        print("Updated reactive newValue: ${newValue.value}");
      }
    }
  }

  Future<void> btnWriteClicked() async {
    try {
      if (selectedPidCode == null) return;

      // --- STEP 1: Sync UI Controller to Data Model ---
      // This ensures that whatever you typed in the TextField is actually
      // processed by the byte-conversion logic below.
      if (selectedPidCode!.reset != true &&
          (selectedPidCode!.piCodeVariable?.isNotEmpty ?? false)) {
        // Pull value from the newValueController and sync to the first variable
        selectedPidCode!.piCodeVariable!.first.writeValue.value =
            newValueController.value.text;
      }

      // 1. Initialize the byte array
      Uint8List writeInput = Uint8List(selectedPidCode!.totalLen ?? 0);
      List<VariantDataLists> variantDataLists = [];

      // 2. Handle RESET logic (Big Endian conversion)
      if (selectedPidCode!.reset == true) {
        int decimalValue =
            int.tryParse(selectedPidCode!.resetValue ?? "0") ?? 0;
        ByteData bd = ByteData(4)..setUint32(0, decimalValue, Endian.big);
        Uint8List byteArray = bd.buffer.asUint8List();

        int bytesToCopy = byteArray.length < writeInput.length
            ? byteArray.length
            : writeInput.length;
        writeInput.setRange(
            0, bytesToCopy, byteArray.sublist(byteArray.length - bytesToCopy));
      }

      // 3. Loop through PID variables to build write payload
      for (int i = 0; i < (selectedPidCode!.piCodeVariable?.length ?? 0); i++) {
        var variable = selectedPidCode!.piCodeVariable![i];

        if (selectedPidCode!.reset != true) {
          String writeValueStr = variable.writeValue.value.trim();

          // --- IQA Handling ---
          if (variable.messageType.contains("IQA")) {
            if (writeValueStr.length != 7) {
              _showErrorPopup("Please enter a valid 7-character IQA value");
              return;
            }
            Uint8List iqaBytes =
                Uint8List.fromList(utf8.encode(writeValueStr.toUpperCase()));
            writeInput.setRange(7 * i, (7 * i) + 7, iqaBytes);
            newValue.value = "IQA";
          }

          // --- ASCII Handling (e.g. VIN) ---
          else if (variable.messageType.contains("ASCII")) {
            if (writeValueStr.length > (variable.length ?? 0)) {
              _showErrorPopup(
                  "Value too long. Max length is ${variable.length}");
              return;
            } else {
              Uint8List val = Uint8List.fromList(utf8.encode(writeValueStr));
              int startIdx = (variable.bytePosition ?? 1) - 1;

              // Write the actual string bytes
              writeInput.setRange(startIdx, startIdx + val.length, val);

              // AUTO-PADDING: Most ECUs require exact lengths (e.g., 17 for VIN).
              // Pad remaining space with ASCII Space (0x20)
              int expectedLen = variable.length ?? 0;
              if (val.length < expectedLen) {
                for (int p = startIdx + val.length;
                    p < startIdx + expectedLen;
                    p++) {
                  writeInput[p] = 0x20;
                }
              }
            }
          }

          // --- CONTINUOUS Handling (Numeric scaling) ---
          else if (variable.messageType.contains("CONTINUOUS")) {
            double? currentWriteVal =
                double.tryParse(variable.writeValue.value);
            double min = variable.min?.toDouble() ?? -double.maxFinite;
            double max = variable.max?.toDouble() ?? double.maxFinite;

            if (currentWriteVal != null &&
                currentWriteVal >= min &&
                currentWriteVal <= max) {
              // Formula: (Value - Offset) / Resolution
              double rawVal = (currentWriteVal - (variable.offset ?? 0)) /
                  (variable.resolution ?? 1);
              int encodedInt = rawVal.toInt();
              int len = variable.length ?? 1;

              int startIdx = (variable.bytePosition ?? 1) - 1;
              for (int j = 0; j < len; j++) {
                // Fill Big Endian
                writeInput[startIdx + (len - 1 - j)] =
                    (encodedInt >> (j * 8)) & 0xFF;
              }
            } else {
              _showErrorPopup(
                  "Please enter a numeric value between $min and $max");
              return;
            }
          }
        }

        // 4. Build VariantDataList for logging/status
        variantDataLists.add(VariantDataLists(
          pidId: variable.id,
          startByte: variable.bytePosition,
          datatype: variable.messageType,
          resolution: variable.resolution,
          offset: variable.offset,
          unit: variable.unit,
          pidName: variable.shortName,
          beforeValue: variable.showResolution.value,
        ));
      }

      print(
          "🔹 Final Generated writeInput (Hex): ${writeInput.map((e) => e.toRadixString(16).padLeft(2, '0')).join()}");

      // 5. Call the write function
      await writeParameter(writeInput, selectedPidCode!, variantDataLists);
    } catch (ex, stackTrace) {
      print("❌ Exception @btnWriteClicked: $ex\n$stackTrace");
      _showErrorPopup("Unexpected error: ${ex.toString()}");
    }
  }

// Helper to avoid duplicate code
  void _showErrorPopup(String message) {
    Get.dialog(CustomPopup(
      title: "Alert",
      message: message,
      onButtonPressed: () => Get.back(),
    ));
  }

  String serverMessage = "";
  String messageTitle = "";
  String message = "";
  String status = "";

  Future<void> writeParameter(Uint8List writeInput, PidCode pid,
      List<VariantDataLists> variantList) async {
    bool confirm = await Get.dialog<bool>(CustomPopup(
          title: "Confirm Write",
          message:
              "Update ${pid.shortName} to ${newValueController.value.text}?",
          onButtonPressed: () => Get.back(result: true),
        )) ??
        false;

    if (!confirm) return;

    isBusy.value = true;
    loaderText.value = "Writing to ECU...";

    final modelDetail = StaticData.ecuInfo
        .firstWhereOrNull((x) => x.ecuName == selectedEcu?.ecuName);
    if (modelDetail == null) {
      isBusy.value = false;
      return;
    }

    int startByte = (selectedPidCode!.piCodeVariable?.first.bytePosition ?? 1);

    List<WriteParameterPid> pidListToWrite = [
      WriteParameterPid(
        seedKeyIndex: modelDetail.seedKeyIndex,
        writePamIndex: modelDetail.writePidIndex,
        writeInput: writeInput,
        writePid: pid.writePid,
        pid: pid.code,
        startByte: startByte,
        totalBytes: pid.totalLen,
        variantList: variantList,
      )
    ];

    final result = await App.dllFunctions!
        .writePid(modelDetail.writePidIndex ?? '', pidListToWrite);

    if (result != null &&
        result.isNotEmpty &&
        result.first.status == "NOERROR") {
      // 🔹 FIX 3: THE IMMEDIATE REFRESH
      print("✅ Write Successful. Refreshing...");
      await Future.delayed(
          const Duration(milliseconds: 600)); // Delay for ECU NVM write
      await getPidsValue(); // Refresh Current Value (22 F1 9A)

      newValueController.value.clear();
      newValue.value = "";
      isBusy.value = false;

      _showDialog("Success", "Value updated and verified.");
    } else {
      isBusy.value = false;
      _showDialog("Failed", result?.first.status ?? "Communication Error");
    }
  }

  void _showDialog(String title, String msg) {
    Get.dialog(CustomPopup(
        title: title, message: msg, onButtonPressed: () => Get.back()));
  }

  Future<void> setDongleProperties() async {
    if (selectedEcu == null) return;
    await App.dllFunctions!.setDongleProperties(
      selectedEcu!.protocol?.autopeepal ?? '',
      selectedEcu!.txHeader ?? '',
      selectedEcu!.rxHeader ?? '',
    );
  }
}
