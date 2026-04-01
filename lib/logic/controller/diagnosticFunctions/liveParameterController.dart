import 'dart:convert';
import 'package:autopeepal/app.dart';
import 'package:autopeepal/models/liveParameter_model.dart';
import 'package:autopeepal/models/staticData.dart';
import 'package:autopeepal/services/iFilesaver_service.dart';
import 'package:autopeepal/views/screens/diagnostic_functions/recordPlayScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:autopeepal/utils/save_local_data.dart';

class LiveParameterController extends GetxController {
  RxBool isBusy = false.obs;
  RxString loaderText = ''.obs;
  RxBool showGroupOverlay = false.obs;
  Rx<EcuModel?> selectedEcu = Rx<EcuModel?>(null);
  RxList<EcuModel> ecusList = <EcuModel>[].obs;

  RxList<PidCode> pidList = <PidCode>[].obs;
  RxList<PidCode> staticPidList = <PidCode>[].obs;

  RxList<PidGroupModel> groupList = <PidGroupModel>[].obs;

  // Selected PIDs list
  RxList<PidCode> selectedPidList = <PidCode>[].obs;

  // Track the currently changed variable
  Rx<PiCodeVariable?> checkChangedPid = Rx<PiCodeVariable?>(null);

  @override
  void onInit() {
    super.onInit();
    getPidList();
  }

  /// Load PIDs from local storage
  Future<void> getPidList() async {
    try {
      isBusy.value = true;
      loaderText.value = 'Loading...';

      await Future.delayed(const Duration(milliseconds: 100));

      ecusList.clear();
      StaticData.pidGroups = [];

      int count = 0;
      for (var ecu in StaticData.ecuInfo) {
        count++;
        int pidDataset = ecu.pidDatasetId!;
        String pidLocalData =
            await SaveLocalData().getData("PidDataset_$pidDataset");
        var pidLocal = Results.fromJson(jsonDecode(pidLocalData));

        ecusList.add(EcuModel(
          ecuName: ecu.ecuName,
          opacity: count == 1 ? 1.0 : 0.5,
          protocol: ecu.protocol,
          txHeader: ecu.txHeader,
          rxHeader: ecu.rxHeader,
          pidList: pidLocal.codes!.where((x) => x.read ?? false).toList()
            ..sort((a, b) => (a.priority ?? 0).compareTo(b.priority ?? 0)),
        ));
      }

      pidList.value = ecusList.first.pidList;
      staticPidList.value = List<PidCode>.from(pidList);

      // Build groups from variables
      // if (StaticData.pidGroups.isEmpty) {
      //   for (var pid in pidList) {
      //     for (var vari in pid.piCodeVariable ?? []) {
      //       for (var group in vari.group) {
      //         if (group != null &&
      //             !StaticData.pidGroups.any((x) => x.id == group.id)) {
      //           StaticData.pidGroups.add(PidGroupModel(
      //             id: group.id,
      //             groupName: group.value,
      //             isSelected: false,
      //           ));
      //         }
      //       }
      //     }
      //   }
      // }

      for (var pid in pidList) {
        for (var vari in pid.piCodeVariable ?? []) {
          for (var group in vari.group ?? []) {
            if (group != null &&
                !StaticData.pidGroups.any((x) => x.id == group['id'])) {
              StaticData.pidGroups.add(PidGroupModel(
                id: group['id'],
                groupName: group['value'],
                isSelected: false,
              ));
            }
          }
        }
      }

      // Add "Select All" group
      StaticData.pidGroups.add(PidGroupModel(
        id: 1000,
        groupName: 'Select All',
        isSelected: false,
      ));

      groupList.value = List<PidGroupModel>.from(StaticData.pidGroups);
      selectedEcu.value = ecusList.first;
    } catch (e) {
      print('Error in getPidList: $e');
    } finally {
      isBusy.value = false;
      loaderText.value = '';
    }
  }

  /// Handle individual PID checkbox tap
  void handlePidCheckboxTap(PiCodeVariable pidVar, {bool byGroup = false}) {
    checkChangedPid.value = pidVar;
    onCheckBoxChanged(byGroup ? "ByGroup" : "");
  }

  /// Checkbox change logic
  void onCheckBoxChanged(String groupType) {
    final PiCodeVariable? pidVar = checkChangedPid.value;
    if (pidVar == null) return;

    if (groupType != "ByGroup") {
      pidVar.selected = !pidVar.selected;
    }

    for (var item in pidList) {
      final vari = item.piCodeVariable?.firstWhereOrNull(
        (v) => v.selected == pidVar.selected && v.id == pidVar.id,
      );
      if (vari != null) {
        var selectedPid = selectedPidList.firstWhereOrNull(
          (x) => x.id == item.id,
        );

        if (pidVar.selected) {
          if (selectedPid == null) {
            selectedPid = PidCode(
              code: item.code,
              resetValue: item.resetValue,
              reset: item.reset,
              id: item.id,
              read: item.read,
              write: item.write,
              writePid: item.writePid,
              totalLen: item.totalLen,
              ioCtrl: item.ioCtrl,
              ioCtrlPid: item.ioCtrlPid,
              isActive: item.isActive,
              isStatic: item.isStatic,
              piCodeVariable:
                  item.piCodeVariable!.where((x) => x.selected).toList(),
            );
            selectedPidList.add(selectedPid);
          } else {
            selectedPid.piCodeVariable =
                item.piCodeVariable!.where((x) => x.selected).toList();
          }
        } else {
          if (selectedPid != null) {
            selectedPid.piCodeVariable
                ?.removeWhere((y) => !y.selected && y.id == pidVar.id);
            if (selectedPid.piCodeVariable == null ||
                selectedPid.piCodeVariable!.isEmpty) {
              selectedPidList.remove(selectedPid);
            }
          }
        }
        break;
      }
    }
  }

 /// Group checkbox logic (Select All or individual group)
void handleGroupCheckboxChanged(PidGroupModel group) {
  if (group.id == 1000) {
    // Select All tapped
    bool newValue = !group.isSelected.value;
    group.isSelected.value = newValue;

    // Update all groups
    for (var g in groupList) {
      g.isSelected.value = newValue;
    }

    // Update all PIDs
    for (var pid in pidList) {
      if (pid.piCodeVariable != null) {
        for (var v in pid.piCodeVariable!) {
          v.selected = newValue;
        }
      }
    }

    // Update selectedPidList
    selectedPidList.value = newValue ? List<PidCode>.from(pidList) : <PidCode>[];
  } else {
    // Normal group selection
    group.isSelected.value = !group.isSelected.value;

    for (var pid in pidList) {
      if (pid.piCodeVariable != null) {
        for (var v in pid.piCodeVariable!) {
          if (v.group.any((g) => g['id'] == group.id)) {
            v.selected = group.isSelected.value;
          }
        }
      }
    }

    // Refresh selectedPidList
    selectedPidList.value = pidList
        .where((p) =>
            p.piCodeVariable != null &&
            p.piCodeVariable!.any((v) => v.selected))
        .toList();
  }
}

  // Future<void> onTabClicked(EcuModel tappedEcu) async {
  //   print("🔹 ECU TAB CLICKED: ${tappedEcu.ecuName}");

  //   isBusy.value = true;
  //   loaderText.value = "Loading...";

  //   await Future.delayed(const Duration(milliseconds: 100));

  //   /// ✅ Set selected ECU
  //   selectedEcu.value = tappedEcu;
  //   selectedEcu.refresh();

  //   print("✅ Selected ECU set: ${selectedEcu.value?.ecuName}");

  //   /// ✅ Update PID list properly
  //   pidList.clear();
  //   pidList.addAll(tappedEcu.pidList);

  //   staticPidList.clear();
  //   staticPidList.addAll(tappedEcu.pidList);

  //   pidList.refresh();
  //   staticPidList.refresh();

  //   print("📦 PID LIST LOADED: ${pidList.length} items");

  //   /// ✅ Set dongle properties
  //   print("📡 Setting dongle properties...");
  //   await setDongleProperties();
  //   print("✅ Dongle properties set");

  //   isBusy.value = false;
  //   loaderText.value = "";

  //   print("🏁 ECU TAB PROCESS COMPLETED\n");
  // }
  Future<void> onTabClicked(EcuModel tappedEcu) async {
  print("🔹 ECU TAB CLICKED: ${tappedEcu.ecuName}");

  isBusy.value = true;
  loaderText.value = "Loading...";

  await Future.delayed(const Duration(milliseconds: 100));

  /// ✅ Set ECU
  selectedEcu.value = tappedEcu;
  selectedEcu.refresh();

  /// 🚨 RESET ALL STATE
  selectedPidList.clear();
  searchKey = "";
  showGroupOverlay.value = false;

  /// ✅ Load fresh PID list
  pidList.value = List<PidCode>.from(tappedEcu.pidList);
  staticPidList.value = List<PidCode>.from(tappedEcu.pidList);

  /// 🚨 CLEAR GROUP FILTER SELECTION
  for (var g in groupList) {
    g.isSelected.value = false;
  }

  /// Refresh UI
  pidList.refresh();
  staticPidList.refresh();

  print("📦 PID LIST LOADED: ${pidList.length} items");

  /// ✅ Set dongle properties
  await setDongleProperties();

  isBusy.value = false;
  loaderText.value = "";

  print("🏁 ECU TAB PROCESS COMPLETED\n");
}

  /// Set dongle properties
  Future<void> setDongleProperties() async {
    if (selectedEcu.value == null) return;
    try {
      await App.dllFunctions!.setDongleProperties(
        selectedEcu.value!.protocol?.autopeepal ?? '',
        selectedEcu.value!.txHeader ?? '',
        selectedEcu.value!.rxHeader ?? '',
      );
    } catch (e) {
      print("Error setting dongle properties: $e");
    }
  }

  final IFileSaver saveFile =
      IFileSaver(); // Create this at the top of your widget/class
  /// Continue button logic
  Future<void> continueClicked(
      BuildContext context, IFileSaver fileSaver) async {
    if (selectedPidList.isEmpty) {
      Get.defaultDialog(
        title: "Alert",
        middleText: "Please select any parameter",
      );
      return;
    }

    await Get.to(() => RecordPlayScreen(
          selectedPIDs: List<PidCode>.from(selectedPidList),
          fileSaver: fileSaver, // Pass your actual IFileSaver instance here
        ));
  }

  String searchKey = "";
  void searchPid() {
    if (searchKey.isNotEmpty) {
      pidList.value = staticPidList
          .where((t) => t.piCodeVariable!.any((s) =>
              (s.shortName).toLowerCase().contains(searchKey.toLowerCase())))
          .toList();
    } else {
      pidList.value = List.from(staticPidList);
    }
  }
}
