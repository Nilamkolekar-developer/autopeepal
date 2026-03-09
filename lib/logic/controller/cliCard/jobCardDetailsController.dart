import 'package:autopeepal/models/jobCard_model.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:autopeepal/AppPreferences/app_areferences.dart';
import 'package:autopeepal/app.dart';
import 'package:autopeepal/common_widgets/commonLoader.dart';
import 'package:autopeepal/common_widgets/popup.dart';
import 'package:autopeepal/logic/controller/cliCard/drawerViewController.dart';
import 'package:autopeepal/models/all_models.dart';
import 'package:autopeepal/models/doipConfigFile_model.dart';
import 'package:autopeepal/models/staticData.dart';
import 'package:autopeepal/models/wifiDevice_model.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:autopeepal/services/connectionUsbService.dart';
import 'package:autopeepal/services/connectionWebUsbService.dart';
import 'package:autopeepal/services/connectionWifiService.dart';
import 'package:autopeepal/services/hotspot_service.dart';
import 'package:autopeepal/services/local_storage_services/localStorage_service.dart';
import 'package:autopeepal/utils/ui_helper.dart/enums.dart';
import 'package:flutter/material.dart';

class JobCardDetailsController extends GetxController {
  final jobCardNo = "".obs;
  final model = "".obs;
  final registrationNumber = "".obs;
  final kmCovered = "".obs;
  final chassisId = "".obs;
  final complaints = "".obs;

  RxBool isLoading = false.obs;
  RxList<VCIType> vciList = <VCIType>[].obs;

  RxString selectedModel = "".obs;
  RxString selectedVciType = "".obs;
  LocalStorage localStorage = LocalStorage();

  Rx<JobCardListModel?> jobCard = Rx<JobCardListModel?>(null);
  final MdnsDiscoveryService mdnsDiscoveryService = MdnsDiscoveryService();
  RxList<DiscoveredService> discoveredServices = <DiscoveredService>[].obs;
  Rx<SubModel?> selectedSubModel = Rx<SubModel?>(null);

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;

    if (arguments != null) {
      if (arguments is JobCardListModel) {
        jobCard.value = arguments;
      }
    }

    // final arguments = Get.arguments;

    // print("📥 Argument type: ${arguments.runtimeType}");

    // if (arguments == null) return;

    // if (arguments is JobCardListModel) {
    //   jobCard.value = arguments;
    // }

    // // else if (arguments is JobCardModel) {
    // //   jobCard.value = JobCardListModel(
    // //     id: arguments.id,
    // //     sessionId: arguments.jobCardSession,
    // //     jobcardName: arguments.jobCardName,
    // //     status: arguments.status,
    // //     chasisId: arguments.chasisId,
    // //     registrationNo: arguments.registrationNo,
    // //     complaints: arguments.complaints,
    // //     kmCovered: arguments.kmCovered,
    // //   );
    // // }

    // else if (arguments is JobCardModel) {
    //   print("📦 JobCardModel received:");
    //   print("ID: ${arguments.id}");
    //   print("JobCardName: ${arguments.jobCardName}");
    //   print("Model: ${arguments.vehicleModel?.name}");
    //   print("Session: ${arguments.jobCardSession}");

    //   jobCard.value = JobCardListModel(
    //     id: arguments.id,
    //     jobcardName: arguments.jobCardName,
    //     status: arguments.status,
    //     chasisId: arguments.chasisId,
    //     registrationNo: arguments.registrationNo,
    //     complaints: arguments.complaints,
    //     kmCovered: arguments.kmCovered,
    //     modelWithSubmodel:
    //         "${arguments.vehicleModel?.parent?.name ?? ''}-${arguments.vehicleModel?.name ?? ''} ",
    //     sessionId: arguments.jobCardSession?.isNotEmpty == true
    //         ? arguments.jobCardSession!.first.sessionId
    //         : null, // ⭐ FIX
    //   );

    //   print("✅ Converted JobCardListModel:");
    //   print("JobCardNo: ${jobCard.value?.jobcardName}");
    //   // print("Model: ${jobCard.value?.model}");
    //   print("SessionId: ${jobCard.value?.sessionId}");
    // }

   

    vciList.value = VCIType.values.where((e) => e != VCIType.NONE).toList();
    AppPreferences.getSelectedVCI().then((value) {
      if (value != null && value.isNotEmpty) {
        selectedVciType.value = value;
      }
    });
    mdnsDiscoveryService.startDiscovery();
  }

  void selectVCI(VCIType vci) {
    selectedVciType.value = vci.name;
    AppPreferences.setSelectedVCI(vci.name);
  }

  Future<void> wifiConnect(BuildContext context) async {
    try {
      isLoading.value = true;
      final loader = CommonLoader(message: "Scanning...");
      Get.dialog(loader, barrierDismissible: false);

      await Future.delayed(const Duration(milliseconds: 50));
      App.connectedVia = "WIFI";

      final connectionWifi = ConnectionWifi();
      final wifiDeviceList = await connectionWifi.getDeviceList();
      final controller = Get.find<DrawerViewController>();
      if (wifiDeviceList != null && wifiDeviceList.isNotEmpty) {
        controller.wifiDevices.value = wifiDeviceList
            .map((s) => WifiDevicesModel(name: s.name, ip: s.ip))
            .toList();

        if (context.mounted) {
          Get.back();
          Get.toNamed(Routes.wifiScreen, arguments: {
            'devices': wifiDeviceList,
            'jobCardSession': jobCard.value?.sessionId,
          });
        }
      } else {
        if (context.mounted) {
          Get.back();
          await showDialog(
            context: context,
            builder: (context) => CustomPopup(
              title: "Failed",
              message: "Dongle not found",
              onButtonPressed: () => Get.back(),
            ),
          );
        }
      }
    } catch (e, stack) {
      debugPrint("❌ WifiConnect error: $e");
      debugPrintStack(stackTrace: stack);
    } finally {
      isLoading.value = false;
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    }
  }

  Future<void> usbConnect(BuildContext context) async {
    isLoading.value = true;
    if (!(Get.isDialogOpen ?? false)) {
      Get.dialog(
        const CommonLoader(message: "Connecting..."),
        barrierDismissible: false,
      );
    }

    try {
      await Future.delayed(const Duration(milliseconds: 50));

      String firmwareVersion = '';
      String channelId = '';
      final ecuInfo = StaticData.ecuInfo;
      if (ecuInfo.isEmpty || ecuInfo.first.channelId == null) {
        await _showAlert(context, "Alert", "Invalid Channel Id Format");
        return;
      }

      final channelSplit = ecuInfo.first.channelId!.split('-');
      if (channelSplit.length > 1) {
        channelId = '0${channelSplit[1]}';
      } else {
        await _showAlert(context, "Alert", "Invalid Channel Id Format");
        return;
      }
      final vciType = VCIType.values.firstWhere(
        (e) => e.name == selectedVciType.value,
        orElse: () => VCIType.RP1210,
      );

      DoipConfigModel? doipConfigModel;
      if (vciType == VCIType.DOIP) {
        final doipConfigLocal =
            await AppPreferences.getStringValue("DoipConfig_LocalList");
        if (doipConfigLocal == null || doipConfigLocal.isEmpty) {
          await _showAlert(context, "Alert!",
              "DOIP Configuration data not available.\nPlease sync local data.");
          return;
        }
        final doipRoot =
            DoipConfigRootModel.fromJson(jsonDecode(doipConfigLocal));
        doipConfigModel = doipRoot.results
            ?.firstWhereOrNull((x) => x.ecu == ecuInfo.first.ecuID);

        if (doipConfigModel == null) {
          await _showAlert(
              context, "Alert!", "DOIP Configuration data not available.");
          return;
        }
      }

      dynamic connectionUSB;
      if (Platform.isAndroid) {
        connectionUSB = ConnectionUSB();
      } else if (Platform.isWindows) {
        connectionUSB = ConnectionUSBWindows();
      } else {
        await _showAlert(context, "Alert", "Unsupported platform");
        return;
      }

      final isConnected = await connectionUSB.connectUsb(vciType);
      if (!isConnected) {
        await _showAlert(context, "Alert", "Failed to connect dongle");
        return;
      }
      if (vciType == VCIType.CAN2X ||
          vciType == VCIType.CAN2XG ||
          vciType == VCIType.CAN2XGK) {
        final macResult =
            await connectionUSB.getDongleMacID(channelId: channelId);
        if (macResult[0] != "true") {
          await _showAlert(context, "Alert!", macResult[1]);
          return;
        }

        firmwareVersion = await App.dllFunctions!.setDongleProperties1();
        App.firmwareVersion = firmwareVersion;
        App.connectedVia = "USB";
      } else if (vciType == VCIType.RP1210 ||
          vciType == VCIType.CAN2xFD ||
          vciType == VCIType.DOIP) {
        final fwResult =
            await connectionUSB.getRP1210FWVersion(channelId, vciType);
        if (fwResult[0] != "true") {
          await _showAlert(context, "Alert!", fwResult[1]);
          return;
        }

        firmwareVersion = fwResult[1];
        App.firmwareVersion = firmwareVersion;

        final status = vciType == VCIType.DOIP
            ? await App.dllFunctions!.setDoipRp1210Properties(doipConfigModel!)
            : await App.dllFunctions!.setRp1210Properties();

        App.connectedVia = "USB";
        if (status != "Success") {
          await _showAlert(context, "Alert!", status);
          return;
        }
      } else {
        await _showAlert(context, "Alert", "Invalid VCI Type Selected");
        return;
      }
      if (firmwareVersion.isEmpty) {
        await _showAlert(context, "Alert", "Firmware version not found.");
        return;
      }
      if (Get.isDialogOpen ?? false) Get.back();
      Get.toNamed(Routes.diagnosticScreen, arguments: {
        'firmwareVersion': firmwareVersion,
        'sessionId': App.sessionId,
      });
    } catch (e, stack) {
      debugPrint("❌ USB Connect error: $e");
      debugPrintStack(stackTrace: stack);
    } finally {
      isLoading.value = false;

      if (Get.isDialogOpen ?? false) Get.back();
    }
  }

  Future<void> _showAlert(
      BuildContext context, String title, String message) async {
    await showDialog(
      context: context,
      builder: (context) => CustomPopup(
        title: title,
        message: message,
        onButtonPressed: () => Get.back(),
      ),
    );
  }
}
