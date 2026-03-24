import 'dart:convert';
import 'package:get/get.dart';
import 'package:autopeepal/app.dart';
import 'package:autopeepal/models/liveParameter_model.dart';
import 'package:autopeepal/models/staticData.dart';
import 'package:autopeepal/utils/save_local_data.dart';


class EcuInformationController extends GetxController {
  RxBool isBusy = false.obs;
  RxString loaderText = "".obs;
  RxString errorMessage = "".obs;

  RxList<EcuModel> ecusList = <EcuModel>[].obs;
  Rx<EcuModel?> selectedEcu = Rx<EcuModel?>(null);
  RxList<PidCode> selectedParameterList = <PidCode>[].obs;

  RxList<ReadPidResponseModel> readPidAndroid =
      <ReadPidResponseModel>[].obs;

  int count1 = 0;

  @override
  void onInit() {
    super.onInit();
    getPidList();
  }

  /// =========================
  /// GET PID LIST
  /// =========================
  Future<void> getPidList() async {
  isBusy.value = true;
  loaderText.value = "Loading...";
  errorMessage.value = "";

  await Future.delayed(const Duration(milliseconds: 20));

  try {
    count1 = 0;
    StaticData.pidGroups = [];
    ecusList.clear();

    for (var ecu in StaticData.ecuInfo) {
      count1++;

      // ✅ PRINT PROTOCOL HERE
      print("ECU: ${ecu.ecuName}, Protocol: ${ecu.protocol}");

      final pidDataset = ecu.pidDatasetId;
      final data =
          await SaveLocalData().getData("PidDataset_$pidDataset");

      if (data.isEmpty) continue;

      final result = Results.fromJson(jsonDecode(data));

      final pidList = (result.codes ?? [])
          .where((e) => e.ecuParameter == true)
          .toList()
        ..sort((a, b) =>
            (a.priority ?? 0).compareTo(b.priority ?? 0));

      ecusList.add(EcuModel(
        ecuName: ecu.ecuName,
        opacity: count1 == 1 ? 1.0 : 0.5,
        protocol: ecu.protocol,
        txHeader: ecu.txHeader,
        rxHeader: ecu.rxHeader,
        pidList: pidList,
      ));
    }

    if (ecusList.isNotEmpty) {
      selectedEcu.value = ecusList.first;
      selectedParameterList.assignAll(ecusList.first.pidList);

      if (selectedParameterList.isNotEmpty) {
        await getPidsValue();
      } else {
        errorMessage.value = "Parameter not found.";
      }
    } else {
      errorMessage.value = "No ECU data available.";
    }
  } catch (e) {
    errorMessage.value = e.toString();
  } finally {
    isBusy.value = false;
    loaderText.value = "";
  }
}
  /// =========================
  /// GET PID VALUES
  /// =========================
  Future<void> getPidsValue() async {
  try {
    print("🚀 Calling readPid...");
    print("Selected ECU: ${selectedEcu.value?.ecuName}");
    print("Protocol: ${selectedEcu.value?.protocol}");
    print("PID count: ${selectedParameterList.length}");

    final response = await App.dllFunctions!
        .readPid(selectedParameterList);

    print("📥 Response received: $response");

    if (response != null) {
      print("✅ Response is not null. Length: ${response.length}");

      readPidAndroid.assignAll(response);

      print("📊 Assigned to readPidAndroid");
      setPidValue();
    } else {
      print("❌ Response is null");
    }
  } catch (e) {
    print("🔥 Error in getPidsValue: $e");
    errorMessage.value = e.toString();
  }
}
  /// =========================
  /// SET PID VALUE
  /// =========================
  void setPidValue() {
  if (readPidAndroid.isEmpty) {
    print("❌ readPidAndroid is empty");
    return;
  }

  print("🚀 Setting PID values...");
  print("Total PID responses: ${readPidAndroid.length}");

  for (var pid in readPidAndroid) {
    print("➡️ Processing PID ID: ${pid.pidId}, Status: ${pid.status}");

    final pidModel = selectedParameterList.firstWhereOrNull(
      (x) => x.id == pid.pidId,
    );

    if (pidModel == null) {
      print("⚠️ No matching pidModel found for PID ID: ${pid.pidId}");
      continue;
    }

    if (pid.status == "NOERROR") {
      print("✅ PID ${pid.pidId} status OK");

      for (var variable in (pidModel.piCodeVariable ?? [])) {
        final item = (pid.variables ?? []).firstWhereOrNull(
          (x) => x.pidNumber == variable.id,
        );

        if (item != null) {
          print(
              "📊 Variable ID: ${variable.id}, Value: ${item.responseValue}");

          variable.showResolution = item.responseValue;
        } else {
          print(
              "⚠️ No variable match for Variable ID: ${variable.id}");
        }
      }
    } else {
      print("❌ PID ${pid.pidId} Error Status: ${pid.status}");

      for (var v in (pidModel.piCodeVariable ?? [])) {
        v.showResolution = pid.status;
      }
    }
  }

  print("🔄 Refreshing selectedParameterList...");
  selectedParameterList.refresh(); // 🔥 VERY IMPORTANT
}

  /// =========================
  /// TAB CLICK
  /// =========================
  Future<void> onTabClicked(EcuModel ecu) async {
    isBusy.value = true;
    loaderText.value = "Loading...";

    await Future.delayed(const Duration(milliseconds: 50));

    try {
      selectedEcu.value = ecu;
      selectedParameterList.clear();

      for (var e in ecusList) {
  //e.opacity = 0.5 

  if (e.ecuName == ecu.ecuName) {
   // e.opacity = 1.0;

    selectedParameterList.assignAll(e.pidList);

    if (selectedParameterList.isNotEmpty) {
      await setDongleProperties();
      await getPidsValue();
    } else {
      errorMessage.value = "Parameter not found.";
    }
    break;
  }
}
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isBusy.value = false;
      loaderText.value = "";
    }
  }

  /// =========================
  /// SET DONGLE
  /// =========================
  Future<void> setDongleProperties() async {
    final ecu = selectedEcu.value;
    if (ecu == null) return;

    await App.dllFunctions!.setDongleProperties(
      ecu.protocol?.autopeepal ?? "",
      ecu.txHeader ?? "",
      ecu.rxHeader ?? "",
    );
  }
}