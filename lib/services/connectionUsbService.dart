import 'dart:async';
import 'dart:typed_data';
import 'package:ap_diagnostic/usd_diagnostic.dart';
import 'package:ap_dongle_comm/utils/commController.dart';
import 'package:ap_dongle_comm/utils/dongleComm.dart';
import 'package:ap_dongle_comm/utils/enums/connectivity.dart';
import 'package:autopeepal/app.dart';
import 'package:autopeepal/utils/ui_helper.dart/dllFunctions.dart';
import 'package:autopeepal/utils/ui_helper.dart/enums.dart';
import 'package:ecu_seedkey/ecu_seedkey.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import 'package:usb_serial/usb_serial.dart';

class ConnectionUSB {
  UsbPort? port;
  UsbDevice? device;
  DongleComm? dongleCommWin;
  UDSDiagnostic? dSDiagnostic;
  List<UsbPort> portList = [];

  static const String ACTION_USB_PERMISSION =
      "com.hoho.android.usbserial.examples.USB_PERMISSION";

  // Future<bool> connectUsb(VCIType vciType) async {
  //   try {
  //     List<UsbDevice> devices = await UsbSerial.listDevices();
  //     UsbDevice? selectedDevice;

  //     try {
  //       selectedDevice =
  //           devices.firstWhere((d) => d.vid == 4292 || d.vid == 6790);
  //     } catch (e) {
  //       print("❌ No compatible USB device found");
  //       return false;
  //     }

  //     port = await selectedDevice.create();
  //     if (port == null) return false;

  //     bool openResult = await port!.open();
  //     if (!openResult) return false;

  //     int baudRate = (selectedDevice.vid == 6790) ? 115200 : 460800;

  //     await port!.setPortParameters(
  //       baudRate,
  //       UsbPort.DATABITS_8,
  //       UsbPort.STOPBITS_1,
  //       UsbPort.PARITY_NONE,
  //     );
  //     await port!.setDTR(true);
  //     await port!.setRTS(true);

  //     await Future.delayed(const Duration(milliseconds: 1500));

  //     final comm = Get.put(CommController());
  //     await comm.connectUsb(port!, baudRate,selectedDevice); // ← listener starts here

  //     if (comm.isConnected.value) {
  //       print("✅ USB connected");
  //       return true;
  //     }
  //     return false;
  //   } catch (e) {
  //     print("🔥 connectUsb error: $e");
  //     await port?.close();
  //     return false;
  //   }
  // }
  Future<bool> connectUsb(VCIType vciType) async {
    try {
      List<UsbDevice> devices = await UsbSerial.listDevices();
      UsbDevice? selectedDevice;

      try {
        // 4292 = Silicon Labs (CP2102), 6790 = QinHeng (CH340)
        selectedDevice =
            devices.firstWhere((d) => d.vid == 4292 || d.vid == 6790);
      } catch (e) {
        print("❌ No compatible USB device found");
        return false;
      }

      port = await selectedDevice.create();
      if (port == null) return false;

      // Determine the correct enum based on the selected VCI Type
      final Connectivity targetUsbType = _mapVciToUsbConnectivity(vciType);

      // CH340 usually caps at 115200, CP2102 handles 460800
      int baudRate = (selectedDevice.vid == 6790) ? 115200 : 460800;

      final comm =
          Get.find<CommController>(); // Use find if already put, or put if new

      // Pass the targetUsbType to the CommController
      await comm.connectUsb(port!, baudRate, targetUsbType);

      if (comm.isConnected.value) {
        print("✅ USB connected as $targetUsbType");
        return true;
      }
      return false;
    } catch (e) {
      print("🔥 connectUsb error: $e");
      await port?.close();
      return false;
    }
  }

  Connectivity _mapVciToUsbConnectivity(VCIType vciType) {
    switch (vciType) {
      case VCIType.RP1210:
        return Connectivity.rp1210Usb;
      case VCIType.CAN2xFD:
        return Connectivity.canFdUsb;
      case VCIType.DOIP:
        return Connectivity.doipUsb;
      default:
        return Connectivity.usb; // Fallback for standard CAN2X/G/GK
    }
  }

  Future<bool> connectUsbForConfig() async {
    try {
      // ✅ STEP 2: Get the SAME CommController connectUsb already set up
      // DO NOT call comm.connectUsb(port!) again — it's already running
      final comm = Get.find<CommController>();
      if (!comm.isConnected.value) {
        print("❌ CommController failed to connect to $port");
        return false;
      }
      // ✅ STEP 3: Drain boot noise
      await Future.delayed(const Duration(milliseconds: 2000));
      await comm.clearBuffer();

      // ✅ STEP 4: Setup dongle
      dongleCommWin = DongleComm(channelId: "00", isChannel: true);
      dongleCommWin!.comm = comm;
      dSDiagnostic = UDSDiagnostic(dongleCommWin!, ECUCalculateSeedkey());

      // ✅ STEP 5: Security access
      print("🔐 Requesting Security Access...");
      Uint8List? securityAccess = await dongleCommWin!.securityAccess();
      print(
          "📨 Response: ${securityAccess?.map((e) => e.toRadixString(16).padLeft(2, '0')).join(' ') ?? 'NULL'}");

      if (securityAccess != null &&
          securityAccess.length > 3 &&
          securityAccess[3] == 0x00) {
        print("✅ Security Access granted");
        App.dllFunctions = DLLFunctions(dongleCommWin!, dSDiagnostic!);
        Fluttertoast.showToast(msg: "VCI Connected");
        return true;
      } else {
        final errHex = (securityAccess != null && securityAccess.length > 3)
            ? '0x${securityAccess[3].toRadixString(16).padLeft(2, '0')}'
            : 'null/short response';
        print("❌ Security Access denied: $errHex");
        Fluttertoast.showToast(msg: "Access denied: $errHex");
        return false;
      }
    } catch (e) {
      print("🔥 connectUsbForConfig error: $e");
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
      await port?.close();
      port = null;
      return false;
    }
  }

  Future<Object> getDongleMacID({String channelId = '00'}) async {
    try {
      print("🔍 Starting getDongleMacID...");

      final comm = Get.find<CommController>();
      if (!comm.isConnected.value) {
        print("❌ CommController failed to connect to $port");
        return false;
      }
      // ✅ STEP 3: Drain boot noise
      await Future.delayed(const Duration(milliseconds: 2000));
      await comm.clearBuffer();

      // ✅ STEP 4: Init objects
      dongleCommWin = DongleComm(channelId: channelId, isChannel: true);
      dongleCommWin!.comm = comm;
      dSDiagnostic = UDSDiagnostic(dongleCommWin!, ECUCalculateSeedkey());

      // ✅ STEP 5: Security access
      print("🔐 Requesting Security Access...");
      Uint8List? securityAccess = await dongleCommWin!.securityAccess();

      if (securityAccess == null) {
        print("❌ No response from dongle");
        return ["false", "No response from dongle"];
      }

      print(
          "📨 Security Response: ${securityAccess.map((e) => e.toRadixString(16).padLeft(2, '0')).join(' ')}");

      if (securityAccess.length <= 3) {
        return ["false", "Invalid security response"];
      }

      if (securityAccess[3] != 0x00) {
        return [
          "false",
          "Security denied: 0x${securityAccess[3].toRadixString(16).padLeft(2, '0')}"
        ];
      }

      print("✅ Security Access Granted");

      // ✅ STEP 6: Get MAC
      print("📡 Requesting MAC ID...");
      Uint8List? macResp = await dongleCommWin!.getWifiMacId();

      if (macResp == null || macResp.length < 9) {
        print("❌ Invalid MAC response: ${macResp?.length ?? 0} bytes");
        return ["false", "Invalid MAC response"];
      }

      String macId = macResp
          .sublist(3, 9)
          .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
          .join(":");

      print("✅ MAC ID: $macId");

      // ✅ STEP 7: Final init
      App.dllFunctions = DLLFunctions(dongleCommWin!, dSDiagnostic!);

      return ["true", macId];
    } catch (e) {
      print("🔥 Exception in getDongleMacID: $e");
      return ["false", "Exception: $e"];
    }
  }

  Future<List<UsbDevice>> findAllDrivers() async {
    try {
      portList.clear();
      List<UsbDevice> devices = await UsbSerial.listDevices();
      final allowedDevices = [
        {'vid': 0x1B4F, 'pid': 0x0008},
        {'vid': 0x09D8, 'pid': 0x0420},
        {'vid': 4292, 'pid': null},
        {'vid': 6790, 'pid': null},
      ];
      List<UsbDevice> matchedDrivers = devices.where((device) {
        return allowedDevices.any((target) =>
            device.vid == target['vid'] &&
            (target['pid'] == null || device.pid == target['pid']));
      }).toList();
      for (var device in matchedDrivers) {
        UsbPort? port = await device.create();
        if (port != null) {
          portList.add(port);
        }
      }

      return matchedDrivers;
    } catch (e) {
      print("Error finding drivers: $e");
      return [];
    }
  }

  Future<Object> getRP1210FWVersion(String channelId, VCIType vciType) async {
    try {
      print("🔍 Starting getRP1210FWVersion...");

      // ✅ STEP 2: Get the SAME CommController connectUsb already set up
      final comm = Get.find<CommController>();
      if (!comm.isConnected.value) {
        print("❌ CommController failed to connect to $port");
        return false;
      }
      // ✅ STEP 3: Map connectivity based on vciType
      Connectivity connectivity;
      switch (vciType) {
        case VCIType.RP1210:
          connectivity = Connectivity.rp1210Usb;
          break;
        case VCIType.CAN2xFD:
          connectivity = Connectivity.canFdUsb;
          break;
        case VCIType.DOIP:
          connectivity = Connectivity.doipUsb;
          break;
        default:
          Fluttertoast.showToast(msg: "Invalid VCI type");
          return ["false", "Invalid VCI type"];
      }

      // ✅ STEP 4: Drain boot noise
      await Future.delayed(const Duration(milliseconds: 2000));
      await comm.clearBuffer();

      // ✅ STEP 5: Init objects + set connectivity
      dongleCommWin = DongleComm(channelId: channelId, isChannel: true);
      dongleCommWin!.comm = comm;
      dongleCommWin!.comm?.connectivity.value = connectivity;
      dSDiagnostic = UDSDiagnostic(dongleCommWin!, ECUCalculateSeedkey());

      // ✅ STEP 6: Get FW version
      print("📡 Requesting Firmware Version...");
      String? fwVersion = "x.x.x";
      //await dongleCommWin!.rp1210ReadVersion();

      if (fwVersion.trim().isEmpty) {
        print("❌ Empty or null firmware version response");
        Fluttertoast.showToast(msg: "Failed to read firmware version");
        return ["false", "Failed to read firmware version"];
      }

      print("✅ FW Version: $fwVersion");
      App.dllFunctions = DLLFunctions(dongleCommWin!, dSDiagnostic!);
      Fluttertoast.showToast(msg: "FW Version: ${fwVersion.trim()}");
      return ["true", fwVersion.trim()];
    } catch (e) {
      print("🔥 Exception in getRP1210FWVersion: $e");
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
      return ["false", "Exception: $e"];
    }
  }
}
