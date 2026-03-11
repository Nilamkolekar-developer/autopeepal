import 'dart:io';
import 'package:ap_dongle_comm/utils/model/sessionLogModel.dart';
import 'package:autopeepal/app.dart';
import 'package:autopeepal/common_widgets/popup.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class SessionLogsController extends GetxController {
  var logsList = <SessionLogsModel>[].obs;
  var isBusy = false.obs;
  var loaderText = ''.obs;
  VoidCallback? onScrollToBottom;

  @override
  void onInit() {
    super.onInit();
    getLogs();
  }

  Future<void> getLogs() async {
    print("getLogs: Start");

    try {
      isBusy.value = true;
      loaderText.value = "Loading logs...";
      print("getLogs: isBusy set to true, loaderText updated");

      await Future.delayed(Duration(milliseconds: 100));
      print("getLogs: Delay finished");
      final dll = App.dllFunctions;
      print("getLogs: dllFunctions = $dll");

      if (dll == null) {
        print("Error: App.dllFunctions is null!");
        logsList.value = [];
        return;
      }

      final fetchedLogs = await dll.getLogs();
      print("getLogs: fetchedLogs = $fetchedLogs");
      logsList.value = fetchedLogs.map((e) {
        print("Mapping log item: $e");
        return e;
      }).toList(growable: true);

      print("getLogs: logsList updated with ${logsList.length} items");
      onScrollToBottom?.call();
      print("getLogs: onScrollToBottom called");
    } catch (ex, stacktrace) {
      print("Error fetching logs: $ex");
      print("Stacktrace: $stacktrace");
    } finally {
      isBusy.value = false;
      loaderText.value = '';
      print("getLogs: Finished, isBusy reset, loaderText cleared");
    }
  }

  void clearLogs() {
    try {
      logsList.clear();
      App.dllFunctions?.clearLogs();
    } catch (ex) {
      print("Error clearing logs: $ex");
    }
  }

  Future<void> saveLogs() async {
    if (logsList.isEmpty) return;

    try {
      isBusy.value = true;
      loaderText.value = "Saving logs...";
      await Future.delayed(Duration(milliseconds: 500));

      StringBuffer buffer = StringBuffer();
      for (var log in logsList) {
        buffer.writeln("${log.header} ${log.message} ${log.status}");
      }

      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          "ATPLTechbud_Session_Log_${DateFormat('yyyy_MM_dd_HH_mm_ss').format(DateTime.now())}.txt";
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(buffer.toString());
      Get.dialog(
        CustomPopup(
          title: "Success",
          message: "Logs saved to Documents",
          onButtonPressed: () => Get.back(),
        ),
        barrierDismissible: false,
      );
    } catch (ex) {
      print("Error saving logs: $ex");
      Get.dialog(
        CustomPopup(
          title: "Error",
          message: "Could not save logs",
          onButtonPressed: () => Get.back(),
        ),
        barrierDismissible: false,
      );
    } finally {
      if (Get.isDialogOpen ?? false) Get.back();
      isBusy.value = false;
      loaderText.value = '';
    }
  }
}
