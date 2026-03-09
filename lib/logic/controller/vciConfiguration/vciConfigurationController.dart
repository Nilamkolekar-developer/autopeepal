import 'package:autopeepal/app.dart';
import 'package:autopeepal/common_widgets/popup.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Vciconfigurationcontroller extends GetxController {
  Rx<TextEditingController> ssidController = TextEditingController().obs;
  Rx<TextEditingController> passwordController = TextEditingController().obs;

  RxBool isBusy = false.obs;

  Future<void> submit() async {
    final ssid = ssidController.value.text.trim();
    final password = passwordController.value.text.trim();

    if (ssid.isEmpty) {
      _showErrorPopup("Please enter SSID");
      return;
    }

    if (password.isEmpty || password.length < 8) {
      _showErrorPopup("Password must be at least 8 characters");
      return;
    }

    try {
      isBusy.value = true;

      // Fluttertoast.showToast(
      //     msg: "📤 Writing SSID...", gravity: ToastGravity.BOTTOM);
      await Future.delayed(const Duration(milliseconds: 100));

      bool resp = await App.dllFunctions!.writeSSID(ssid);

      if (resp) {
        // Fluttertoast.showToast(
        //     msg: "✅ SSID Updated", backgroundColor: Colors.green);
        await Future.delayed(const Duration(milliseconds: 800));

        // Fluttertoast.showToast(
        //     msg: "📤 Writing Password...", gravity: ToastGravity.BOTTOM);
        resp = await App.dllFunctions!.writePassword(password);

        if (resp) {
          // Fluttertoast.showToast(
          //     msg: "✅ Password Updated", backgroundColor: Colors.green);
          _showSuccessPopup();
        } else {
          // Fluttertoast.showToast(
          //     msg: "❌ Password Write Failed", backgroundColor: Colors.red);
          _showErrorPopup("Could not change Password");
        }
      } else {
        // Fluttertoast.showToast(
        //     msg: "❌ SSID Write Failed", backgroundColor: Colors.red);
        _showErrorPopup("Could not change SSID");
      }
    } catch (e) {
      // Fluttertoast.showToast(
      //     msg: "🔥 Error: $e", toastLength: Toast.LENGTH_LONG);
      print("Error in submit: $e");
    } finally {
      isBusy.value = false;
    }
  }

  void _showErrorPopup(String message) {
    Get.dialog(
      CustomPopup(
        title: "Failed",
        message: message,
        onButtonPressed: () => Get.back(),
      ),
      barrierDismissible: false,
    );
  }

  void _showSuccessPopup() {
    Get.dialog(
      CustomPopup(
        title: "Success",
        message:
            "Hotspot configuration changed successfully.\nPLEASE REMOVE DONGLE & CONNECT AGAIN",
        onButtonPressed: () {
          Get.back();
          Get.back();
        },
      ),
      barrierDismissible: false,
    );
  }
}
