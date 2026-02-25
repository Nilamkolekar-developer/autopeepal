import 'package:get/get.dart';
import 'package:flutter/material.dart';

class Writeparametercontroller extends GetxController {

  RxString selectedFile = "".obs;

  final List<String> Files = [
    "Hex File",
    "Json File",
  ];

  Rx <TextEditingController> currentValueController = TextEditingController().obs;
   Rx <TextEditingController> newValueController = TextEditingController().obs;
  final Map<String, String> currentValues = {
    "Hex File": "0x1A2B",
    "Json File": '{"mode": "default"}',
  };

  @override
  void onInit() {
    super.onInit();

    ever(selectedFile, (value) {
      if (value.isNotEmpty) {
        currentValueController.value.text = currentValues[value] ?? "";
        newValueController.value.text;
      }
    });
  }
}