import 'dart:convert';

import 'package:autopeepal/app.dart';
import 'package:autopeepal/common_widgets/popup.dart';
import 'package:autopeepal/models/iorTest_model.dart';
import 'package:autopeepal/models/liveParameter_model.dart';
import 'package:autopeepal/models/staticData.dart';
import 'package:autopeepal/utils/save_local_data.dart';
import 'package:autopeepal/views/screens/diagnostic_functions/iorPreconditionTest.dart';
import 'package:autopeepal/views/screens/diagnostic_functions/iorTestPlayPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RoutineTestController extends GetxController {
  RxList<EcuTestRoutine> ecuList = <EcuTestRoutine>[].obs;
  Rx<EcuTestRoutine?> selectedEcu = Rx<EcuTestRoutine?>(null);
  RxList<IorResult> iorTestList = <IorResult>[].obs;

  RxBool isBusy = false.obs;
  RxString routineNotice = ''.obs;
  RxString routineListStatus = 'Loading...'.obs;
  final SaveLocalData saveLocalData = SaveLocalData();
  @override
  void onInit() {
    super.onInit();
    getIorTest();
  }

  Future<void> getIorTest() async {
    try {
      print("------ START getIorTest ------");
      isBusy.value = true;
      routineListStatus.value = "Loading...";
      print("Loading started...");

      await Future.delayed(Duration(milliseconds: 200));

      int count = 0;
      final jsonListData = await SaveLocalData().getData("IOR_LocalList");
      print("--- IOR_LocalList Data ---");
      print(jsonListData);

      if (jsonListData.isEmpty) {
        routineListStatus.value = "Test not found. Please update local data.";
        await CustomPopup(
          title: 'Error',
          message: 'Test not found. Please update local data.',
        );
        isBusy.value = false;
        print("IOR_LocalList not found or empty.");
        return;
      }

      final data = IorTestModel.fromJson(jsonDecode(jsonListData));
      print("Parsed IorTestModel: ${data.results?.length ?? 0} results");

      if (data.results == null || data.results!.isEmpty) {
        routineListStatus.value = "Routine Test Not Available.";
        await CustomPopup(
          title: 'Error',
          message: "Routine Test Not Available.",
        );
        isBusy.value = false;
        print("No results found in IorTestModel.");
        return;
      }

      // Check if all ECUs are null
      if (data.results!.every((r) => r.ecu?.id == null)) {
        routineListStatus.value =
            "No valid ECU data found. Please update local data.";
        await CustomPopup(
          title: 'Error',
          message: "No valid ECU data found. Please update local data.",
        );
        isBusy.value = false;
        print("All ECUs are null in the local data.");
        return;
      }

      // Group IOR results by ECU ID
      final Map<int, List<IorResult>> ecuGroup1 = {};
      for (var r in data.results!) {
        final ecuId = r.ecu?.id ?? 0; // fallback for null IDs
        ecuGroup1.putIfAbsent(ecuId, () => []).add(r);
      }
      print("Grouped IOR results by ECU ID: ${ecuGroup1.keys}");

      ecuList.clear(); // Clear previous ECUs

      // Populate ECU list
      for (var ecu in StaticData.ecuInfo) {
        count++;
        final pidDataset = ecu.pidDatasetId;

        // Load PID dataset local data
        final pidLocalData =
            await SaveLocalData().getData("PidDataset_$pidDataset");
        print("PID Dataset $pidDataset Data: $pidLocalData");

        // ignore: unnecessary_null_comparison
        final pidLocal = pidLocalData != null
            ? Results.fromJson(jsonDecode(pidLocalData))
            : null;
        // ignore: unused_local_variable
        final pidList = pidLocal?.codes ?? [];

        // Get IOR list for this ECU, fallback to empty list
        final iorList = ecuGroup1[ecu.ecuID] ?? [];
        print(
            "ECU ${ecu.ecuName} (ID ${ecu.ecuID}) - IOR list length: ${iorList.length}");

        ecuList.add(EcuTestRoutine(
          id: ecu.ecuID,
          ecuName: ecu.ecuName,
          opacity: count == 1 ? 1.0 : 0.5,
          protocol: ecu.protocol,
          txHeader: ecu.txHeader,
          rxHeader: ecu.rxHeader,
          iorList: iorList,
          noOfInjectors: ecu.noOfInjectors,
        ));
      }
      print("Selected ECU: ${selectedEcu.value?.ecuName}");

      selectedEcu.value = ecuList.isNotEmpty ? ecuList.first : null;
      print("Selected ECU: ${selectedEcu.value?.ecuName}");
      iorTestList.value = selectedEcu.value?.iorList ?? [];
      // ignore: invalid_use_of_protected_member
      print("IOR Test List length: ${iorTestList.value.length}");

      routineListStatus.value =
          // ignore: invalid_use_of_protected_member
          iorTestList.value.isNotEmpty ? "" : "Routine Test Not Available.";
      print("Routine List Status: ${routineListStatus.value}");
      isBusy.value = false;
      print("------ END getIorTest ------");
    } catch (ex) {
      isBusy.value = false;
      routineListStatus.value = "Error loading data.";
      print("Error in getIorTest: $ex");
    }
  }

  Future<void> selectEcuClicked(EcuTestRoutine? ecu) async {
    try {
      isBusy.value = true; // isBusy is RxBool

      if (ecu == null) return;

      selectedEcu.value = ecu; // selectedEcu is Rx<EcuTestRoutine?>

      await Future.delayed(const Duration(milliseconds: 100));

      // Call the method that handles the ECU selection
      handleEcuClicked(); // replace with your actual method
    } catch (e) {
      print("Error in selectEcuClicked: $e");
    } finally {
      isBusy.value = false;
    }
  }

  void handleEcuClicked() {
    try {
      // Clear previous IOR test list
      iorTestList.value = [];

      for (var ecu in ecuList) {
        if (selectedEcu.value?.id == ecu.id) {
          // Set selected ECU opacity
          ecu.opacity = 1.0;

          // Set IOR test list for the selected ECU
          iorTestList.value = List<IorResult>.from(ecu.iorList ?? []);
        } else {
          // Dim unselected ECUs
          ecu.opacity = 0.5;
        }
      }

      // Trigger UI update (if using GetX)
      ecuList.refresh();
      iorTestList.refresh();

      print("Selected ECU: ${selectedEcu.value?.ecuName}");
      print("IOR Test List length: ${iorTestList.length}");
    } catch (ex) {
      print("Exception in selectEcuClicked: $ex");
    }
  }

  var selectedTest = Rx<IorResult?>(null);
  Future<void> selectIorTestClicked(IorResult? test) async {
    try {
      isBusy.value = true; // isBusy is RxBool

      if (test == null) return;

      selectedTest.value = test; // selectedTest is Rx<IorResult?>

      // Small delay to mimic async behavior
      await Future.delayed(const Duration(milliseconds: 100));

      // Call the method that handles the selected test
      handleIorTestSelection(); // replace with your actual logic
    } catch (e) {
      print("Error in selectIorTestClicked: $e");
    } finally {
      isBusy.value = false;
    }
  }

  RxBool isNoticeVisible = false.obs;
  Future<void> handleIorTestSelection() async {
    try {
      if (selectedTest.value == null) return;

      // Update notice text
      routineNotice.value =
          "${selectedTest.value!.notice}.\n\nDo you want to continue this test?";

      // Show the notice banner by updating the reactive variable
      isNoticeVisible.value = true;

      // Optional: wait a little if you want to animate before next action
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      print("Error in handleIorTestSelection: $e");
    }
  }

  Future<void> cancelRoutineClicked() async {
    try {
      // Hide the notice banner by updating the reactive variable
      isNoticeVisible.value = false;

      // Optional delay to let the animation finish (300ms)
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      print("Error in cancelRoutineClicked: $e");
    }
  }

  Future<void> okRoutineClicked() async {
    try {
      // Call the handler for OK routine
      handleOkRoutine(); // Replace with your actual logic
    } catch (e) {
      print("Error in okRoutineClicked: $e");
    }
  }

  Future<void> handleOkRoutine() async {
    try {
      print("=== handleOkRoutine START ===");
      isBusy.value = true;

      // Hide the notice banner
      print("Hiding notice banner...");
      isNoticeVisible.value = false;
      await Future.delayed(const Duration(milliseconds: 300));
      print("Notice banner hidden.");

      // Get selected ECU info
      final selected = selectedEcu.value;
      if (selected == null) {
        print("No ECU selected. Aborting.");
        return;
      }

      final ecuInfo = StaticData.ecuInfo.firstWhere(
        (e) => e.ecuID == selected.id,
        orElse: () => throw Exception("ECU info not found"),
      );
      print("ECU info retrieved: $ecuInfo");

      final seedIndex = ecuInfo.seedKeyIndex ?? '';
      final writeFnIndex = ecuInfo.writePidIndex ?? '';
      print("Seed Index: $seedIndex, WriteFn Index: $writeFnIndex");

      // Set dongle properties
      print("Setting dongle properties...");
      await App.dllFunctions?.setDongleProperties(
        selected.protocol?.autopeepal ?? '',
        selected.txHeader ?? '',
        selected.rxHeader ?? '',
      );
      print("Dongle properties set.");

      // Validate number of injectors

      if (selected.noOfInjectors == 0) {
        print("No injectors available. Showing alert.");
        await Get.dialog(
          CustomPopup(
            title: "Alert!",
            message: "Number of Injectors not available",
          ),
          barrierDismissible: false,
        );
        return;
      }

      // Validate firing sequence
      final firingSeq = ecuInfo.firingSequence ?? '';
      if (firingSeq.isEmpty) {
        print("Firing sequence missing. Showing alert.");
        await Get.dialog(
          CustomPopup(
            title: "Alert!",
            message: "Firing Sequence is not available",
          ),
          barrierDismissible: false,
        );
        return;
      }

      // Parse firing order safely
      final firingOrder = firingSeq
          .split(',')
          .map((seq) => int.tryParse(seq.trim()) ?? -1)
          .map((n) => n - 1)
          .toList();

      if (firingOrder.length != selected.noOfInjectors ||
          firingOrder.contains(-2)) {
        print("Firing order length mismatch. Showing alert.");
        await Get.dialog(
          CustomPopup(
            title: "Alert!",
            message: "Number of Injectors does not match with Firing Sequence",
          ),
          barrierDismissible: false,
        );
        return;
      }

      // Navigate based on preconditions
      final preConditions = selectedTest.value?.preConditions ?? [];
      if (preConditions.isEmpty) {
        print("No preconditions, navigating to IorTestPlayPage...");

        Get.offAll((dynamic SeedIndex, dynamic WriteFnIndex, dynamic NoOfInj) =>
            IorTestPlayPage(
                IorResult, SeedIndex, WriteFnIndex, NoOfInj, firingOrder));
      } else {
        print("Preconditions exist, navigating to IorPreconditionPage...");
        await Navigator.push(
          Get.context!,
          MaterialPageRoute(
            builder: (_) => IorPreconditionPage(
              selectedTest.value!,
              seedIndex,
              writeFnIndex,
              selected.noOfInjectors,
              firingOrder,
            ),
          ),
        );
      }

      print("=== handleOkRoutine END ===");
    } catch (e, stack) {
      print("Error in handleOkRoutine: $e\n$stack");
      await Get.dialog(
        CustomPopup(
          title: "Error",
          message: "An error occurred: $e",
        ),
        barrierDismissible: false,
      );
    } finally {
      isBusy.value = false;
      print("isBusy set to false.");
    }
  }

  List<PidCode> pidList = [];
  Future<int> getNoOfCylAndFiringSeq() async {
    int noOfCylinders = 0;

    try {
      if (pidList.isNotEmpty) {
        // Find the PidCode with code "22F191" (case-insensitive)
        final noOfCylinderDid = pidList.firstWhere(
          (x) => x.code!.toUpperCase() == "22F191",
        );

        // Prepare list of PIDs to read
        final cylPidList = [noOfCylinderDid];

        // Call the DLL function to read PIDs
        final List<ReadPidResponseModel>? readPidResp =
            await App.dllFunctions!.readPid(cylPidList);

        // Check response
        if (readPidResp!.isNotEmpty && readPidResp[0].status == "NOERROR") {
          final resp =
              readPidResp[0].variables![0].responseValue!.replaceAll(" ", "");
          noOfCylinders = int.tryParse(resp) ?? 0;
        }
      }
    } catch (e) {
      print("Error in getNoOfCylAndFiringSeq: $e");
    }

    return noOfCylinders;
  }
}
