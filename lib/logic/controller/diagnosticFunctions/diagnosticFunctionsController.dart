import 'dart:async';
import 'dart:convert';
import 'package:autopeepal/app.dart';
import 'package:autopeepal/common_widgets/commonLoader.dart';
import 'package:autopeepal/common_widgets/popup.dart';
import 'package:autopeepal/models/feature_model.dart';
import 'package:autopeepal/models/jobCard_model.dart';
import 'package:autopeepal/models/staticData.dart';
import 'package:autopeepal/models/user_model.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:autopeepal/utils/save_local_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppFeatureController extends GetxController {
  JobCardListModel? jobCardSession;
  RxString firmwareVersion = "".obs;
  RxString sessionId = "".obs;
  SaveLocalData? saveLocalData;
  AppFeatureController({
    this.jobCardSession,
  });

  Rx<TextEditingController> model = TextEditingController().obs;
  Rx<TextEditingController> regulation = TextEditingController().obs;
  Rx<TextEditingController> ecu = TextEditingController().obs;
  Rx<TextEditingController> verifyOTPController = TextEditingController().obs;

  // Reactive variables
  var featureList = <FeatureModel>[].obs;
  var connectorImage = ''.obs;
  var isEcuConnected = false.obs;
  var isEcuDisconnected = false.obs;
  var isDongleDisconnected = false.obs;
  var isBusy = false.obs;
  var loaderText = ''.obs;

  bool isPageLoaded = false;
  bool _isCheckingEcuStatus = false;

  RxString selectedModel = ''.obs;
  RxString selectedSubModel = ''.obs;
  RxString selectedEcu = ''.obs;
  RxString status = ''.obs;

  void setEcuInfo() {
    if (StaticData.ecuInfo.isNotEmpty) {
      selectedModel.value = StaticData.ecuInfo[0].modelName ?? '';
      selectedSubModel.value = StaticData.ecuInfo[0].submodelName ?? '';
      String ecus = StaticData.ecuInfo.map((e) => e.ecuName).join(', ');
      selectedEcu.value = ecus;
    }
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    setEcuInfo();
    final args = Get.arguments;

    if (args != null) {
      firmwareVersion.value = args['firmwareVersion'] ?? '';
      sessionId.value = args['sessionId'] ?? '';

      print("Firmware Version: ${firmwareVersion.value}");
      print("Session ID: ${sessionId.value}");
    }

    await initFeatures();
    checkConnection();
  }

  initFeatures() {
    featureList.clear();

    featureList.add(
        FeatureModel(name: 'ECU Information', image: 'assets/new/ic_dtc.png'));
    featureList.add(FeatureModel(name: 'DTC', image: 'assets/new/ic_dtc.png'));
    featureList.add(
        FeatureModel(name: 'Live Parameter', image: 'assets/new/ic_pid.png'));
    featureList.add(FeatureModel(
        name: 'Write Parameter', image: 'assets/new/ic_write.png'));
    featureList.add(
        FeatureModel(name: 'ECU Flashing', image: 'assets/new/ic_flash.png'));
    featureList.add(
        FeatureModel(name: 'Routine Test', image: 'assets/new/ic_routine.png'));
    featureList.add(
        FeatureModel(name: 'All DTC Details', image: 'assets/new/ic_dtc.png'));

    switch (App.connectedVia) {
      case 'USB':
        connectorImage.value = 'assets/images/ic_usb_white.png';
        break;
      case 'WIFI':
        connectorImage.value = 'assets/images/ic_wifi_white.png';
        break;
      case 'BLE':
        connectorImage.value = 'assets/images/ic_bluetooth_white.png';
        featureList
            .add(FeatureModel(name: 'IVN', image: 'assets/images/ic_pid.png'));
        break;
      default:
        Get.snackbar('Alert', 'Invalid Connectivity');
        break;
    }
  }

  Future<void> onFeatureTap(FeatureModel feature, BuildContext context) async {
    try {
      isBusy.value = true;
      loaderText.value = "Loading...";

      isPageLoaded = false;

      while (_isCheckingEcuStatus) {
        debugPrint("Waiting for check ECU status to complete");
        await Future.delayed(const Duration(seconds: 1));
      }

      switch (feature.name) {
        case 'DTC':
          await Get.toNamed(Routes.dtcScreen, arguments: {"onlyActive": true});
          break;

        case 'All DTC Details':
          await Get.toNamed(Routes.dtcScreen, arguments: {"onlyActive": false});
          break;

        case 'Live Parameter':
          await Get.toNamed(Routes.liveParameter);
          break;

        case 'Write Parameter':
          await Get.toNamed(Routes.writeParameter);
          break;

        case 'ECU Flashing':
          await Get.toNamed(Routes.ecuFlashing);
          break;

        case 'Routine Test':
          await Get.toNamed(Routes.routineTest);
          break;

        case 'ECU Information':
          await Get.toNamed(Routes.ecuInformation);
          break;
      }

      /// ⭐ RESTART ECU MONITORING AFTER RETURN
      checkConnection();
    } catch (e) {
      debugPrint("Feature Navigation Error: $e");
      checkConnection();
    } finally {
      isBusy.value = false;
    }
  }


  Future<void> disconnectDongle(BuildContext context) async {
    debugPrint("Opening disconnect dialog...");

    final answer = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomPopup1(
        title: "Alert",
        message: "Do you want to disconnect dongle?",
        showYesNo: true,
        onYesTap: () => Navigator.of(context, rootNavigator: true).pop(true),
        onNoTap: () => Navigator.of(context, rootNavigator: true).pop(false),
      ),
    );

    if (answer != true) return;

    try {
      isPageLoaded = false;
      debugPrint("ECU monitoring stopped.");

      isBusy.value = true;
      loaderText.value = "Disconnecting...";
      while (_isCheckingEcuStatus) {
        await Future.delayed(const Duration(milliseconds: 300));
      }

      debugPrint("Starting hardware disconnect...");

      await App.dllFunctions!.disconnectVCI1();
      String? userDetailLocalData =
          await SaveLocalData().getData("UserDetailL_LocalData");

      // ignore: unnecessary_null_comparison
      if (userDetailLocalData != null) {
        // ignore: unused_local_variable
        final userResModel =
            UserResModel.fromJson(jsonDecode(userDetailLocalData));
      }
      await saveLocalData?.getData('UserDetailL_LocalData');
    } catch (e) {
      debugPrint("Disconnect error: $e");
    } finally {
      isBusy.value = false;

      debugPrint("Navigating to dashboard");
      Get.offAllNamed(Routes.dashboardScreen);
    }
  }

  // Future<void> checkConnection() async {
  //   isPageLoaded = true;

  //   await App.dllFunctions!.setDongleProperties(
  //     StaticData.ecuInfo[0].protocol!.autopeepal ?? '',
  //     StaticData.ecuInfo[0].txHeader ?? '',
  //     StaticData.ecuInfo[0].rxHeader ?? '',
  //   );

  //   while (isPageLoaded) {
  //     _isCheckingEcuStatus = true;

  //     String? ecuStatus = await App.dllFunctions!.checkEcuStatus();

  //     _isCheckingEcuStatus = false;

  //     print("ECU STATUS RAW: $ecuStatus");

  //     if (ecuStatus.trim().isNotEmpty) {
  //       if (ecuStatus.contains("ECUERROR_NORESPONSEFROMECU")) {
  //         isDongleDisconnected.value = false;
  //         isEcuConnected.value = false;
  //         isEcuDisconnected.value = true;
  //         status.value = "ECU Disconnected";
  //       } else if (ecuStatus.contains("No Resp From Dongle")) {
  //         isDongleDisconnected.value = true;
  //         isEcuConnected.value = false;
  //         isEcuDisconnected.value = false;
  //         status.value = "Dongle Disconnected";
  //       } else {
  //         isDongleDisconnected.value = false;
  //         isEcuConnected.value = true;
  //         isEcuDisconnected.value = false;
  //         status.value = "Connected";
  //       }
  //     } else {
  //       /// SAME AS C# ELSE BLOCK
  //       isDongleDisconnected.value = true;
  //       isEcuConnected.value = false;
  //       isEcuDisconnected.value = false;
  //       status.value = "Dongle Disconnected";
  //     }

  //     await Future.delayed(const Duration(seconds: 3));
  //   }
  // }

  Future<void> checkConnection() async {
  try {
    isPageLoaded = true;

    // 🔁 Run like background thread (non-blocking)
    Future(() async {
      await App.dllFunctions!.setDongleProperties(
        StaticData.ecuInfo[0].protocol?.autopeepal ?? '',
        StaticData.ecuInfo[0].txHeader ?? '',
        StaticData.ecuInfo[0].rxHeader ?? '',
      );

      while (isPageLoaded) {
        try {
          _isCheckingEcuStatus = true;

          String? ecuStatus =
              await App.dllFunctions!.checkEcuStatus();

          _isCheckingEcuStatus = false;

          print("ECU STATUS RAW: $ecuStatus");

          // ✅ Safe null + empty check (matches C#)
          if (ecuStatus.trim().isNotEmpty) {
            if (ecuStatus.contains("ECUERROR_NORESPONSEFROMECU")) {
              isDongleDisconnected.value = false;
              isEcuConnected.value = false;
              isEcuDisconnected.value = true;
              status.value = "ECU Disconnected";
            } else if (ecuStatus.contains("No Resp From Dongle")) {
              isDongleDisconnected.value = true;
              isEcuConnected.value = false;
              isEcuDisconnected.value = false;
              status.value = "Dongle Disconnected";
            } else {
              isDongleDisconnected.value = false;
              isEcuConnected.value = true;
              isEcuDisconnected.value = false;
              status.value = "Connected";
            }
          } else {
            // ✅ SAME AS C# ELSE BLOCK
            isDongleDisconnected.value = true;
            isEcuConnected.value = false;
            isEcuDisconnected.value = false;
            status.value = "Dongle Disconnected";
          }
        } catch (e) {
          print("[CHECK CONNECTION ERROR] $e");

          // Optional: treat as disconnected
          isDongleDisconnected.value = true;
          isEcuConnected.value = false;
          isEcuDisconnected.value = false;
          status.value = "Error";
        }

        // ⏱ same as Task.Delay(3000)
        await Future.delayed(const Duration(seconds: 3));
      }

      print("🔴 checkConnection loop stopped");
    });
  } catch (ex) {
    print("[EXCEPTION] $ex");
  }
}

  String getStatusText(String status) {
    switch (status) {
      case "Connected":
        return "ECU Connected";

      case "ECU Disconnected":
        return "ECU Disconnected";

      case "Dongle Disconnected":
        return "Dongle Disconnected";

      default:
        return "Unknown";
    }
  }

  bool isPaused = false;
  Future<void> checkSessionLogs() async {
    try {
      isBusy.value = true;
      Get.dialog(const CommonLoader(message: "Scanning..."),
          barrierDismissible: false);

      await Future.delayed(const Duration(milliseconds: 100));
      isPaused = true;
      while (_isCheckingEcuStatus) {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      if (Get.isDialogOpen ?? false) Get.back();
      await Get.toNamed(Routes.SessionScreen);
      isPaused = false;
      print("Resumed ECU background status check.");
    } catch (ex) {
      isPaused = false;
      if (Get.isDialogOpen ?? false) Get.back();
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> fotaCommand() async {
    try {
      // 1. Check connectivity (Similar to App.ConnectedVia)
      if (App.connectedVia == "USB") {
        // Assuming you have a helper for dialogs or using Get.defaultDialog
        await Get.defaultDialog(
          title: "Alert!",
          middleText:
              "To update firmware of VCI, you need to connect VCI and application with WIFI",
          textConfirm: "OK",
          onConfirm: () => Get.back(),
        );
        return;
      }

      isBusy.value = true;

      // 2. Stop the background connection loop
      // Note: Based on our previous fix, use isPaused = true instead of killing the loop
      isPaused = true;

      // 3. Wait for any active hardware communication to finish
      while (_isCheckingEcuStatus) {
        await Future.delayed(const Duration(milliseconds: 1000));
      }

      // 4. Navigate to Settings Page
      // Using GetX navigation
      await Get.toNamed(Routes.firmwareUpdateScreen);

      // Optional: Resume monitoring when coming back from settings
      isPaused = false;
    } catch (ex) {
      print("FOTA Command Error: ${ex.toString()}");
      isPaused = false;
    } finally {
      isBusy.value = false;
    }
  }

}
