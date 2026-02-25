
import 'dart:async';
import 'dart:typed_data';
import 'package:autopeepal/services/usb_services.dart';
import 'package:autopeepal/services/usb_socket_services.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class UsbDiscoveryController extends GetxController {
  final UsbDiscoveryService _discoveryService = UsbDiscoveryService();
  UsbSerialService? usbSerialService;

  var discoveredDevices = <UsbDiscoveredDevice>[].obs;
  var isLoading = false.obs;
  var isConnecting = false.obs;
  var isConnected = false.obs;
  var selectedUsbDevice = UsbDiscoveredDevice(name: "", deviceId: 0, vid: 0, pid: 0).obs;

  @override
  void onInit() {
    super.onInit();
    _startListening();
    hardRefresh();
  }

  void _startListening() {
    _discoveryService.discoveredDevices.listen((device) {
      if (!discoveredDevices.any((d) => d.deviceId == device.deviceId)) {
        discoveredDevices.add(device);
      }
    });

    _discoveryService.deviceOffline.listen((device) {
      discoveredDevices.removeWhere((d) => d.deviceId == device.deviceId);
      if (selectedUsbDevice.value.deviceId == device.deviceId) {
        isConnected.value = false;
        usbSerialService?.disconnect();
      }
    });
  }

  Future<void> hardRefresh() async {
    isLoading.value = true;
    discoveredDevices.clear();
    await _discoveryService.startDiscovery();
    await Future.delayed(const Duration(seconds: 1));
    isLoading.value = false;
  }

  Future<void> connectToDevice(UsbDiscoveredDevice discovered) async {
    if (discovered.device == null) return;

    try {
      isConnecting.value = true;
      selectedUsbDevice.value = discovered;

      // Logic from ConnectionUSB.cs: 
      // Vendor ID 6790 = 115200 Baud
      // Vendor ID 4292 = 460800 Baud
      int targetBaud = (discovered.vid == 4292) ? 460800 : 115200;

      usbSerialService = UsbSerialService(device: discovered.device!);
      
      // 1. Open Port
      await usbSerialService!.connect(baudRate: targetBaud);
      
      // 2. Security Handshake (Logic from DongleComm.cs)
      // Sending Hex: 50 0A 01 47 56 8A FE 56 21 4E 23 80 00 FF C3
      Uint8List securityKey = _hexToBytes("500A0147568AFE56214E238000FFC3");
      
      Fluttertoast.showToast(msg: "Authenticating VCI...");
      bool authSuccess = await usbSerialService!.sendSecurityKey(securityKey);

      if (authSuccess) {
        isConnected.value = true;
        Fluttertoast.showToast(
          msg: "VCI Connected @ $targetBaud Baud",
          backgroundColor: Colors.green,
          textColor: Colors.white
        );
      } else {
        // Fallback: If 460800 fails, try 115200 (Some custom VCIs use standard baud)
        if (targetBaud == 460800) {
           //await _retryAtLowerBaud(securityKey);
        } else {
          throw Exception("VCI Handshake Failed: No Response");
        }
      }
    } catch (e) {
      isConnected.value = false;
      Fluttertoast.showToast(msg: "Connection Error: $e");
      await usbSerialService?.disconnect();
    } finally {
      isConnecting.value = false;
    }
  }

  // Future<void> _retryAtLowerBaud(Uint8List key) async {
  //   Fluttertoast.showToast(msg: "Retrying at 115200...");
  //   await usbSerialService?.disconnect();
  //   await Future.delayed(const Duration(milliseconds: 500));
  //   await usbSerialService?.connect(baudRate: 115200);
  //   bool success = await usbSerialService!.sendSecurityKey(key);
  //   isConnected.value = success;
  // }

  Uint8List _hexToBytes(String hex) {
    var result = Uint8List(hex.length ~/ 2);
    for (var i = 0; i < hex.length; i += 2) {
      result[i ~/ 2] = int.parse(hex.substring(i, i + 2), radix: 16);
    }
    return result;
  }

  Future<void> disconnectDevice() async {
    if (usbSerialService != null) {
      await usbSerialService!.disconnect();
      usbSerialService = null;
    }
    isConnected.value = false;
    Fluttertoast.showToast(msg: "USB Disconnected");
  }

  @override
  void onClose() {
    _discoveryService.dispose();
    //usbSerialService?.dispose();
    super.onClose();
  }
}