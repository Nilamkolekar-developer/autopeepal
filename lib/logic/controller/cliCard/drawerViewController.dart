import 'package:ap_dongle_comm/utils/enums/connectivity.dart';
import 'package:autopeepal/AppPreferences/app_areferences.dart';
import 'package:autopeepal/app.dart';
import 'package:autopeepal/models/doipConfigFile_model.dart';
import 'package:autopeepal/models/staticData.dart';
import 'package:autopeepal/models/wifiDevice_model.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:autopeepal/services/connectionWifiService.dart';
import 'package:autopeepal/utils/ui_helper.dart/enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class DrawerViewController extends GetxController {
  var isLoading = false.obs;
  RxString loaderMessage = "Connecting...".obs;
  final _storage = GetStorage();

  /// Device list and selected device
  var wifiDevices = <WifiDevicesModel>[].obs;
  var selectedDevice = Rx<WifiDevicesModel?>(null);

  void selectDevice(WifiDevicesModel device) {
    selectedDevice.value = device;
  }

  final ConnectionWifi connectionWifi = ConnectionWifi();

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> connectDevice(
      WifiDevicesModel device, BuildContext context) async {
    print("=== connectDevice START ===");
    print("Selected Device: ${device.name}, IP: ${device.ip}");

    try {
      isLoading.value = true;
      loaderMessage.value = "Connecting...";
      await Future.delayed(const Duration(milliseconds: 50));

      // ---------------- Extract Channel ID ----------------
      String channelId = '';
      print("StaticData.ecuInfo: ${StaticData.ecuInfo}");
      final parts = StaticData.ecuInfo[0].channelId?.split('-');
      print("Channel ID parts: $parts");
      if (parts != null && parts.length > 1) {
        channelId = "0${parts[1]}";
        print("Parsed channelId: $channelId");
      } else {
        print("Invalid Channel ID Format");
        return;
      }

      // ---------------- Selected VCI Type ----------------
      final vciTypeStr = await AppPreferences.getSelectedVCI() ?? '';
      print("VCI Type from storage: $vciTypeStr");

      if (vciTypeStr.isEmpty) {
        print("No VCI selected");
        return;
      }

      final selectedVCIType = VCIType.values.firstWhere(
        (e) => e.name.toUpperCase() == vciTypeStr.toUpperCase(),
        orElse: () => VCIType.CAN2X,
      );
      print("Selected VCIType: $selectedVCIType");

      // ---------------- DOIP Config ----------------
      DoipConfigModel? doipConfig;
      if (selectedVCIType == VCIType.DOIP) {
        final doipConfigLocal = _storage.read('DoipConfig_LocalList') ?? '';
        print("DoipConfig_LocalList from storage: $doipConfigLocal");

        if (doipConfigLocal.isEmpty) return;

        final doipRoot = DoipConfigRootModel.fromJson(doipConfigLocal);
        doipConfig = doipRoot.results!.firstWhere(
          (x) => x.ecu == StaticData.ecuInfo[0].ecuID,
          orElse: () {
            print(
                "DOIP Configuration not found for ECU: ${StaticData.ecuInfo[0].ecuID}");
            throw Exception("DOIP Configuration not found");
          },
        );
        print("DOIP Configuration found: $doipConfig");
      }

      // ---------------- CAN2X / CAN2XG / CAN2XGK ----------------
      if ([VCIType.CAN2X, VCIType.CAN2XG, VCIType.CAN2XGK]
          .contains(selectedVCIType)) {
        print("Connecting via CAN2X/CAN2XG/CAN2XGK");

        final macId = await connectionWifi.getDongleMacID(
          device.ip!,
          channelId: channelId,
          selectedType: _mapVciToUsbConnectivity(selectedVCIType),
        );
        print("MAC ID: $macId");

        if (macId.isEmpty) {
          print("Failed to get MAC ID");
          return;
        }

        print("MAC ID found, fetching firmware...");
        final firmware = await App.dllFunctions?.setDongleProperties1() ?? '';
        print("Firmware version: $firmware");

        if (firmware.isNotEmpty) {
          App.firmwareVersion = firmware;
          App.connectedVia = "WIFI";

          print("Navigating to Diagnostic Screen");
          Get.toNamed(Routes.diagnosticScreen, arguments: {
            'firmwareVersion': firmware,
            'sessionId': App.sessionId,
          });
        } else {
          print("Firmware not found");
        }
      }

      // ---------------- RP1210 / CAN2xFD / DOIP ----------------
      else if ([VCIType.RP1210, VCIType.CAN2xFD, VCIType.DOIP]
          .contains(selectedVCIType)) {
        print("Connecting via RP1210/CAN2xFD/DOIP");

        final fwVersion = await connectionWifi.getRP1210FWVersion(
            device.ip!, selectedVCIType, channelId);
        print("RP1210 FW Response: $fwVersion");

        if (fwVersion[0] == "true") {
          App.firmwareVersion = fwVersion[1];

          final status = selectedVCIType == VCIType.DOIP
              ? await App.dllFunctions?.setDoipRp1210Properties(doipConfig!) ??
                  "Error"
              : await App.dllFunctions?.setRP1210Properties() ?? "Error";

          print("Setup status: $status");
          App.connectedVia = "WIFI";

          if (status != "Success") return;

          Get.toNamed(Routes.diagnosticScreen, arguments: {
            'firmwareVersion': fwVersion[1],
            'sessionId': App.sessionId,
          });
        } else {
          print("Failed to get FW version: ${fwVersion[1]}");
        }
      }

      // ---------------- Invalid VCI ----------------
      else {
        print("Invalid VCI Type Selected");
      }
    } catch (e, stack) {
      print("Connection Error: $e");
      print(stack);
    } finally {
      isLoading.value = false;
      print("=== connectDevice END ===");
    }
  }
    Connectivity _mapVciToUsbConnectivity(VCIType vciType) {
    switch (vciType) {
      case VCIType.RP1210:
        return Connectivity.rp1210WiFi;
      case VCIType.CAN2xFD:
        return Connectivity.canFdWiFi;
      case VCIType.DOIP:
        return Connectivity.doipWiFi;
      default:
        return Connectivity.wiFi; // Fallback for standard CAN2X/G/GK
    }
  }
}
