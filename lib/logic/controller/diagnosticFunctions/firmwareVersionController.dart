import 'package:autopeepal/common_widgets/popup.dart';
import 'package:autopeepal/models/updateFirmware_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:autopeepal/app.dart';
import 'package:autopeepal/services/api_services.dart';

class SettingsController extends GetxController {
  final AuthApiService apiServices = AuthApiService();
  final RxString binFileUrl = "".obs;
  final RxString serverFirmware = "".obs;
  final RxString currentVersion = "".obs;
  FirmwareManagerPartition? SelectedFirmware;
  @override
  void onInit() {
    super.onInit();
    currentVersion.value = App.firmwareVersion;
    getFota();
  }

  var loaderText = ''.obs;

  var isBusy = false.obs;

  Future<void> upgradeCommand() async {
    try {
      if (SelectedFirmware == null) return;
      if (App.connectedVia == "USB") {
        await Get.defaultDialog(
          title: "Alert",
          middleText:
              "To update firmware, first connect app with dongle via WIFI",
          textConfirm: "OK",
          onConfirm: () => Get.back(),
        );
        return;
      }

      isBusy.value = true;
      loaderText.value = "Initiating update...";
      var success =
          await App.dllFunctions!.updateFirmware(SelectedFirmware!.firmware!);

      if (success) {
        await Get.defaultDialog(
          title: "Success",
          middleText:
              "Dongle Firmware Update Started.\nWait till only first 3 lights are ON and Connect Again.",
          textConfirm: "OK",
          onConfirm: () => Get.back(),
        );
      } else {
        await Get.defaultDialog(
          title: "Error",
          middleText: "Failed to update new firmware",
          textConfirm: "OK",
          onConfirm: () => Get.back(),
        );
      }
    } catch (ex) {
      print("Upgrade Error: ${ex.toString()}");
    } finally {
      isBusy.value = false;
    }
  }

  var btnEnable = false.obs;

  Future<void> getFota() async {
    try {
      isBusy.value = true;
      loaderText.value = "Loading...";
      String? currentFV = await App.dllFunctions!.getFirmware();
      if (currentFV.isNotEmpty) {
        var result = await AuthApiService.getLatestFirmwareVersion("apsimp001");

        if (result.message == "success") {
          if (result.results != null && result.results!.isNotEmpty) {
            var item = result.results!
                .firstWhereOrNull((x) => x.partNo?.partNumber == "apsimp001");

            if (item != null) {
              if (item.firmwareManagerPartition != null &&
                  item.firmwareManagerPartition!.isNotEmpty) {
                SelectedFirmware = item.firmwareManagerPartition!
                    .firstWhereOrNull((x) => x.startAddr == "10000");

                if (SelectedFirmware != null) {
                  serverFirmware.value = SelectedFirmware!.version ?? "";
                  btnEnable.value = (currentFV != serverFirmware.value);
                } else {
                  Get.dialog(
                    CustomPopup(
                      title: "Error",
                      message: "Latest firmware not found",
                      onButtonPressed: () => Get.back(),
                    ),
                    barrierDismissible: false,
                  );
                }
              } else {
                Get.dialog(
                  CustomPopup(
                    title: "Error",
                    message: "Latest firmware list not found",
                    onButtonPressed: () => Get.back(),
                  ),
                  barrierDismissible: false,
                );
              }
            } else {
              Get.dialog(
                CustomPopup(
                  title: "Error",
                  message: "Firmware not found",
                  onButtonPressed: () => Get.back(),
                ),
                barrierDismissible: false,
              );
            }
          } else {
            Get.dialog(
              CustomPopup(
                title: "Error",
                message: "Firmware list not found",
                onButtonPressed: () => Get.back(),
              ),
              barrierDismissible: false,
            );
          }
        } else {
          Get.dialog(
            CustomPopup(
              title: "Error",
              message: result.message ?? "API Error",
              onButtonPressed: () => Get.back(),
            ),
            barrierDismissible: false,
          );
        }
      } else {
        Get.dialog(
          CustomPopup(
            title: "Error",
            message: "Dongle firmware version not found.",
            onButtonPressed: () => Get.back(),
          ),
          barrierDismissible: false,
        );
      }
    } catch (ex) {
      debugPrint("GetFota Exception: ${ex.toString()}");
      Get.dialog(
        CustomPopup(
          title: "Exception",
          message: ex.toString(),
          onButtonPressed: () => Get.back(),
        ),
        barrierDismissible: false,
      );
    } finally {
      isBusy.value = false;
    }
  }
}
