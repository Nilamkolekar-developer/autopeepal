import 'dart:async';
import 'dart:io';
import 'package:ap_dongle_comm/utils/model/sessionLogModel.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class SessionController extends GetxController {
  // Observable list of logs
  var logs = <SessionLogsModel>[].obs;
  final RxBool isMenuOpen = false.obs;
  // To track if a save operation is in progress
  var isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Start with empty logs or fetch initial history if needed
  }

  /// Add a new log entry (TX or RX)
  /// Example: addLog("Tx", "1003") or addLog("Rx", "No Resp From Dongle")
  void addLog(String header, String message) {
    logs.add(SessionLogsModel(
      header: header,
      message: message,
    ));
  }

  /// Clear all logs from the screen
  void clearLogs() {
    logs.clear();
  }

  /// Save current logs to a .txt file
  Future<void> saveLogs() async {
    if (logs.isEmpty) return;

    try {
      isSaving.value = true;
      
      StringBuffer buffer = StringBuffer();
      for (var log in logs) {
        // Formats as "Tx : 1003"
        buffer.writeln('${log.header} : ${log.message}');
      }

      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'Session_Log_${DateTime.now().millisecondsSinceEpoch}.txt';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsString(buffer.toString());

      Get.snackbar("Success", "Logs saved to Documents",
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar("Error", "Could not save logs",
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSaving.value = false;
    }
  }
}