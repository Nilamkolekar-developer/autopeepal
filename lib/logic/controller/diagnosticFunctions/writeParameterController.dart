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
  // EcuModel? selectedEcu;
  Rxn<EcuModel> selectedEcu = Rxn<EcuModel>();
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
  Future<void> onInit() async {
    super.onInit();
    await getPidList();
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
        selectedEcu.value = ecuList.first;
        staticPidList.value = List<PidCode>.from(selectedEcu.value!.pidList);
        pidList.value = List<PidCode>.from(selectedEcu.value!.pidList);
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
            v.writeValue = pid.resetValue!;
            v.isReset = true;
          }
        } else {
          writeBtnText.value = "Write";
        }

        // Handle IQA Injector reordering based on firing sequence
        if (pid.piCodeVariable![0].messageType == "IQA") {
          if ((selectedEcu.value?.noOfInjectors ?? 0) == 0 ||
              (selectedEcu.value?.firingSequence ?? '').isEmpty) {
            _showDialog("Alert",
                "Injector or Firing Sequence data missing for this ECU.");
            return;
          }

          final firingOrder = selectedEcu.value!.firingSequence!
              .split(',')
              .map((s) => int.parse(s.trim()) - 1)
              .toList();

          if (firingOrder.length != (selectedEcu.value?.noOfInjectors ?? 0)) {
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
            variable.showResolution = item.responseValue!;

            // Clear writeValue if not a reset variable
            if (!variable.isResetRx.value) {
              variable.writeValue = "";
            }
          }
        }
      } else {
        // PID read returned an error
        for (var variable in selectedPidCode!.piCodeVariable!) {
          variable.showResolution = "ERR";
          if (!variable.isResetRx.value) variable.writeValue = "";
        }
      }
    }

    // Update controllers after parsing PID values
    updateControllers();
  }

  void updateControllers() {
    if (selectedPidCode?.piCodeVariable?.isNotEmpty ?? false) {
      final variable = selectedPidCode!.piCodeVariable!.first;
      currentValueController.value.text = variable.showResolution!;
      print(
          "Updated currentValueController: ${currentValueController.value.text}");

      // Initialize newValueController only if empty
      if (newValueController.value.text.isEmpty) {
        newValueController.value.text = variable.writeValue!;
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
      if (selectedPidCode == null) {
        print("❌ No PID selected. Exiting write operation.");
        return;
      }

      print(
          "🔹 btnWriteClicked called for PID: ${selectedPidCode!.code} (${selectedPidCode!.shortName})");
      print("🔹 New value controller: ${newValueController.value.text}");

      // --- STEP 1: Sync UI Controller to Data Model ---
      if (selectedPidCode!.reset != true &&
          (selectedPidCode!.piCodeVariable?.isNotEmpty ?? false)) {
        selectedPidCode!.piCodeVariable!.first.writeValue =
            newValueController.value.text;
        print(
            "🔹 Synced writeValue to first PiCodeVariable: ${selectedPidCode!.piCodeVariable!.first.writeValue}");
      }

      // 1. Initialize the byte array
      Uint8List writeInput = Uint8List(selectedPidCode!.totalLen ?? 0);
      List<VariantDataLists> variantDataLists = [];
      print("🔹 Initialized writeInput of length ${writeInput.length}");

      // 2. Handle RESET logic (Big Endian conversion)
      if (selectedPidCode!.reset == true) {
        int decimalValue =
            int.tryParse(selectedPidCode!.resetValue ?? "0") ?? 0;
        print("🔹 RESET mode active. Decimal value: $decimalValue");

        ByteData bd = ByteData(4)..setUint32(0, decimalValue, Endian.big);
        Uint8List byteArray = bd.buffer.asUint8List();

        int bytesToCopy = byteArray.length < writeInput.length
            ? byteArray.length
            : writeInput.length;
        writeInput.setRange(
            0, bytesToCopy, byteArray.sublist(byteArray.length - bytesToCopy));

        print(
            "🔹 writeInput after RESET conversion: ${writeInput.map((e) => e.toRadixString(16).padLeft(2, '0')).join()}");
      }

      // 3. Loop through PID variables to build write payload
      for (int i = 0; i < (selectedPidCode!.piCodeVariable?.length ?? 0); i++) {
        var variable = selectedPidCode!.piCodeVariable![i];
        print(
            "🔹 Processing variable ${variable.shortName} of type ${variable.messageType}");

        if (selectedPidCode!.reset != true) {
          String writeValueStr = variable.writeValue!.trim();
          print("🔹 Write value string: $writeValueStr");

          // --- IQA Handling ---
          if (variable.messageType.contains("IQA")) {
            print("🔹 IQA type detected");
            if (writeValueStr.length != 7) {
              Get.dialog(
                  CustomPopup(
                      title: "Alert!",
                      message: "Please enter a valid 7-character IQA value"),
                  barrierDismissible: false);

              return;
            }
            Uint8List iqaBytes =
                Uint8List.fromList(utf8.encode(writeValueStr.toUpperCase()));
            writeInput.setRange(7 * i, (7 * i) + 7, iqaBytes);
            newValue.value = "IQA";
            print(
                "🔹 IQA bytes written: ${iqaBytes.map((e) => e.toRadixString(16).padLeft(2, '0')).join()}");
          }

          // --- ASCII Handling (e.g., VIN) ---
          else if (variable.messageType.contains("ASCII")) {
            print("🔹 ASCII type detected");
            if (writeValueStr.length > (variable.length)) {
              Get.dialog(
                  CustomPopup(
                      title: "Alert!",
                      message:
                          "Value too long. Max length is ${variable.length}"),
                  barrierDismissible: false);

              return;
            } else {
              Uint8List val = Uint8List.fromList(utf8.encode(writeValueStr));
              int startIdx = (variable.bytePosition) - 1;
              writeInput.setRange(startIdx, startIdx + val.length, val);

              // AUTO-PADDING
              int expectedLen = variable.length;
              if (val.length < expectedLen) {
                for (int p = startIdx + val.length;
                    p < startIdx + expectedLen;
                    p++) {
                  writeInput[p] = 0x20;
                }
              }
              print(
                  "🔹 ASCII bytes written (with padding if any): ${writeInput.sublist(startIdx, startIdx + expectedLen).map((e) => e.toRadixString(16).padLeft(2, '0')).join()}");
            }
          }

          // --- CONTINUOUS Handling (Numeric scaling) ---
          else if (variable.messageType.contains("CONTINUOUS")) {
            print("🔹 CONTINUOUS type detected");
            double? currentWriteVal = double.tryParse(variable.writeValue!);
            double min = variable.min?.toDouble() ?? -double.maxFinite;
            double max = variable.max?.toDouble() ?? double.maxFinite;

            if (currentWriteVal != null &&
                currentWriteVal >= min &&
                currentWriteVal <= max) {
              double rawVal = (currentWriteVal - (variable.offset ?? 0)) /
                  (variable.resolution ?? 1);
              int encodedInt = rawVal.toInt();
              int len = variable.length;
              int startIdx = (variable.bytePosition) - 1;

              for (int j = 0; j < len; j++) {
                writeInput[startIdx + (len - 1 - j)] =
                    (encodedInt >> (j * 8)) & 0xFF;
              }

              print(
                  "🔹 CONTINUOUS bytes written: ${writeInput.sublist(startIdx, startIdx + len).map((e) => e.toRadixString(16).padLeft(2, '0')).join()}");
            } else {
              Get.dialog(
                  CustomPopup(
                      title: "Alert",
                      message:
                          "Please enter a numeric value between $min and $max"),
                  barrierDismissible: false);

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
          beforeValue: variable.showResolution,
        ));
      }

      print(
          "🔹 Final Generated writeInput (Hex): ${writeInput.map((e) => e.toRadixString(16).padLeft(2, '0')).join()}");
      print("🔹 VariantDataLists prepared: $variantDataLists");

      // 5. Call the write function
      await writeParameter(writeInput, selectedPidCode!, variantDataLists);
      print("🔹 writeParameter call completed");
    } catch (ex, stackTrace) {
      print("❌ Exception @btnWriteClicked: $ex\n$stackTrace");
      Get.dialog(
          CustomPopup(
              title: "Exception @btnWriteClicked:",
              message: "$ex\n$stackTrace"),
          barrierDismissible: false);
    }
  }

  String serverMessage = "";
  String messageTitle = "";
  String message = "";
  String status = "";

  Future<void> writeParameter(Uint8List writeInput, PidCode pid,
      List<VariantDataLists> variantList) async {
    print("🔹 writeParameter called for PID: ${pid.code} (${pid.shortName})");

    if (variantList.isEmpty) {
      Get.dialog(CustomPopup(
          title: "Alert",
          message: "Please select a parameter",
          onButtonPressed: () => Get.back()));
      return;
    }

    bool confirm = false;
    if (selectedPidCode!.reset != true) {
      confirm = await Get.dialog<bool>(
            CustomPopup2(
              title: "Alert!!",
              message: selectedPidCode!.reset != true
                  ? "Are you sure you want to write this new value?"
                  : "Are you sure you want to reset?",
              confirmText: "Yes",
              cancelText: "No",
              showCancel: true,
            ),
          ) ??
          false;
    }

    print("🔹 User confirmation: $confirm");
    if (!confirm) {
      print("❌ Write canceled by user.");
      return;
    }

    isBusy.value = true;
    loaderText.value = "Writing to ECU...";
    await Future.delayed(const Duration(milliseconds: 50)); // small UI delay

    final modelDetail = StaticData.ecuInfo
        .firstWhereOrNull((x) => x.ecuName == selectedEcu.value?.ecuName);
    if (modelDetail == null) {
      isBusy.value = false;
      loaderText.value = "";
      print("❌ ECU model not found. Aborting write.");
      return;
    }

    int? startByte =
        variantList.map((v) => v.startByte).reduce((a, b) => a! < b! ? a : b);
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

    String messageTitle = "";
    String message = "";
    String status = "";

    if (result != null && result.isNotEmpty) {
      for (var item in result) {
        if (item.status == "NOERROR") {
          await getPidsValue();
          newValueController.value.clear();
          newValue.value = "";

          messageTitle = "Success";
          message = "Writing Successful";
        } else {
          messageTitle = "Writing Failed";
          message = "${item.status}\n\n"; // append ServerMessage if needed
          status = item.status ?? '';
        }

        // Show alert like .NET ShowAlertDialog
        await Get.dialog(
          CustomPopup(
            title: messageTitle,
            message: "$status\n$message",
            onButtonPressed: () => Get.back(),
          ),
        );
      }
    } else {
      messageTitle = "Writing Failed";
      message = "Communication Error";
      status = "Error";

      await Get.dialog(
        CustomPopup(
          title: messageTitle,
          message: "$status\n$message",
          onButtonPressed: () => Get.back(),
        ),
      );
    }

    isBusy.value = false;
    loaderText.value = "";
    print("🔹 Write operation completed. isBusy set to false.");
  }

  void _showDialog(String title, String msg) {
    Get.dialog(CustomPopup(
        title: title, message: msg, onButtonPressed: () => Get.back()));
  }

  Future<void> setDongleProperties() async {
    // ignore: unnecessary_null_comparison
    if (selectedEcu == null) return;
    await App.dllFunctions!.setDongleProperties(
      selectedEcu.value!.protocol?.autopeepal ?? '',
      selectedEcu.value!.txHeader ?? '',
      selectedEcu.value!.rxHeader ?? '',
    );
  }

  void switchTab(EcuModel ecu) {
    selectedEcu.value = ecu;

    staticPidList.value = List<PidCode>.from(ecu.pidList);
    pidList.value = List<PidCode>.from(ecu.pidList);

    selectedPidName.value = "";
    selectedPidCode = null;

    currentValueController.value.clear();
    newValueController.value.clear();

    setDongleProperties();
  }
}
