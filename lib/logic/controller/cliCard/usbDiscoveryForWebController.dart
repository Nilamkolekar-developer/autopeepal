import 'dart:typed_data';
import 'package:autopeepal/services/usb_socket_service_web.dart';
import 'package:get/get.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

class UsbController extends GetxController {
  // Use a nullable service because we create it only when a port is selected
  UsbSerialService? _service;
  
  var availablePorts = <String>[].obs;
  var isLoading = false.obs;
  var isConnected = false.obs;
  var selectedAddress = "".obs;

  @override
  void onInit() {
    super.onInit();
    refreshPorts();
  }

  void refreshPorts() {
    availablePorts.value = SerialPort.availablePorts;
  }

  Future<void> connectToUsb(String address) async {
    isLoading.value = true;
    selectedAddress.value = address;

    try {
      // 1. Determine Baud Rate from Vendor ID
      SerialPort tempPort = SerialPort(address);
      int vid = tempPort.vendorId ?? 0;
      int targetBaud = (vid == 4292) ? 460800 : 115200;

      // 2. Initialize Service with the specific COM address
      _service = UsbSerialService(address: address);
      
      // Listen for connection status updates
      _service!.connectionUpdates.listen((status) {
        isConnected.value = status;
      });

      // 3. Connect (This throws an exception if it fails)
      await _service!.connect(baudRate: targetBaud);

      // 4. Perform Security Handshake
      Uint8List securityKey = _hexToBytes("500A0147568AFE56214E238000FFC3");
      bool authorized = await _service!.sendSecurityKey(securityKey);
      
      if (authorized) {
        Get.snackbar("Success", "VCI Connected at $targetBaud Baud");
      } else {
        await _service!.disconnect();
        Get.snackbar("Auth Failed", "VCI Handshake failed. Check hardware.");
      }
    } catch (e) {
      isConnected.value = false;
      Get.snackbar("Error", "Could not open $address: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Uint8List _hexToBytes(String hex) {
    var result = Uint8List(hex.length ~/ 2);
    for (var i = 0; i < hex.length; i += 2) {
      result[i ~/ 2] = int.parse(hex.substring(i, i + 2), radix: 16);
    }
    return result;
  }

  @override
  void onClose() {
    _service?.dispose();
    super.onClose();
  }
}