import 'dart:typed_data';
import 'package:ap_dongle_comm/utils/commController.dart';
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TerminalController extends GetxController {
  final logs = <Map<String, dynamic>>[].obs;
  final CommController _comm = Get.find<CommController>();
  
  var isProcessing = false.obs;

  Future<void> executeCommand(String textInput) async {
  if (textInput.trim().isEmpty) return;

  isProcessing.value = true;
  // Clear any leftover UI logs for a clean run
  _addLog("TX String: $textInput", Colors.cyan);

  try {
    // 1. Convert "0100" to [0x30, 0x31, 0x30, 0x30] (ASCII)
    // 2. Add Carriage Return (0x0D) - The ELM327 "Enter" key
    List<int> bytes = textInput.codeUnits.toList();
    if (bytes.isEmpty || bytes.last != 0x0D) {
      bytes.add(0x0D); 
    }

    Uint8List cmdBytes = Uint8List.fromList(bytes);

    // 3. Send and await the future managed by the persistent listener
    Uint8List? response = await _comm.sendCommand(cmdBytes);

    if (response != null && response.isNotEmpty) {
      String resultText = String.fromCharCodes(response).replaceAll(RegExp(r'[^\x20-\x7E]'), '.');
      _addLog("RX (Text): $resultText", Colors.greenAccent);
      _addLog("RX (Hex): ${_bytesToHex(response)}", Colors.grey);
    } else {
      _addLog("TIMEOUT: No response from dongle", Colors.orange);
    }
  } catch (e) {
    _addLog("ERROR: $e", Colors.redAccent);
  } finally {
    isProcessing.value = false;
  }
}
  void _addLog(String msg, Color color) {
    logs.add({"msg": msg, "color": color});
    print(msg);
  }

  String _bytesToHex(Uint8List b) => 
      hex.encode(b).toUpperCase().replaceAllMapped(RegExp(r".{2}"), (m) => "${m.group(0)} ");

  void clearTerminal() => logs.clear();
}