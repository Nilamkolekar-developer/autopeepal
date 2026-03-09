import 'dart:async';
import 'dart:typed_data';
import 'package:ap_diagnostic/usd_diagnostic.dart';
import 'package:ap_dongle_comm/utils/commController.dart';
import 'package:ap_dongle_comm/utils/dongleComm.dart';
import 'package:ap_dongle_comm/utils/enums/connectivity.dart';
import 'package:autopeepal/app.dart';
import 'package:autopeepal/services/connectionWifiService.dart';
import 'package:autopeepal/utils/ui_helper.dart/dllFunctions.dart';
import 'package:autopeepal/utils/ui_helper.dart/enums.dart';
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

  Future<bool> connectUsb(VCIType vciType) async {
    try {
      List<UsbDevice> devices = await UsbSerial.listDevices();
      UsbDevice? selectedDevice;
      try {
        selectedDevice =
            devices.firstWhere((d) => d.vid == 4292 || d.vid == 6790);
      } catch (e) {
        return false;
      }
      port = await selectedDevice.create();
      if (port == null) return false;

      bool openResult = await port!.open();
      if (!openResult) return false;
      int baudRate = (selectedDevice.vid == 6790) ? 115200 : 460800;
      await port!.setPortParameters(
        baudRate,
        UsbPort.DATABITS_8,
        UsbPort.STOPBITS_1,
        UsbPort.PARITY_NONE,
      );

      await port!.setDTR(true);
      await port!.setRTS(true);

      return true;
    } catch (e) {
      await port?.close();
      return false;
    }
  }

  Future<bool> connectUsbForConfig() async {
    try {
      bool hardwareConnected = await connectUsb(VCIType.RP1210);
      if (!hardwareConnected || port == null) {
        print("❌ Hardware connection failed");
        // Fluttertoast.showToast(
        //     msg: "USB Hardware not found or Permission denied");
        return false;
      }
      final comm = Get.find<CommController>();
      await comm.connectUsb(port!);

      await Future.delayed(const Duration(milliseconds: 600));

      dongleCommWin = DongleComm(channelId: "00", isChannel: true);
      dongleCommWin!.comm = comm;
      dSDiagnostic = UDSDiagnostic(dongleCommWin!, dSDiagnostic);

      print("🔐 Starting Security Access on Mobile...");
     // Fluttertoast.showToast(msg: "Requesting Security Access...");
      Uint8List? securityAccess = await dongleCommWin!.securityAccess();

      if (securityAccess != null && securityAccess.length > 3) {
        if (securityAccess[3] == 0x00) {
          App.dllFunctions = DLLFunctions(dongleCommWin!, dSDiagnostic!);
         // Fluttertoast.showToast(msg: "✅ Security Access Granted");
          return true;
        } else {
          securityAccess[3].toRadixString(16).padLeft(2, '0');
          //Fluttertoast.showToast(msg: "❌ Access Denied. Error: 0x$errCode");
          return false;
        }
      } else {
       // Fluttertoast.showToast(msg: "⚠️ No response from VCI (Security)");
        return false;
      }
    } catch (e) {
      print("🔥 Mobile USB Exception: $e");
    //  Fluttertoast.showToast(msg: "Exception: ${e.toString()}");
      await port?.close();
      return false;
    }
  }

  Future<List<String>> getDongleMacID({String channelId = '00'}) async {
    try {
      comm ??= Get.put(CommController());
      dongleCommWin = DongleComm(channelId: channelId, isChannel: true);
      dongleCommWin!.comm = comm;
      if (port != null) {
        await comm!.connectUsb(port!);
      } else {
        return ["false", "USB Port not found"];
      }
      dSDiagnostic = UDSDiagnostic(dongleCommWin!, dSDiagnostic);
      print("Requesting Security Access...");
      Uint8List? securityAccess = await dongleCommWin!.securityAccess();
      if (securityAccess != null &&
          securityAccess.length > 3 &&
          securityAccess[3] == 0x00) {
        Uint8List? macResp = await dongleCommWin!.getWifiMacId();

        if (macResp != null && macResp.length >= 9) {
          String macId = macResp
              .sublist(3, 9)
              .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
              .join(":");
          App.dllFunctions = DLLFunctions(dongleCommWin!, dSDiagnostic!);

          return ["true", macId];
        }
      }
      return ["false", "Failed to Connect: Security access denied"];
    } catch (e) {
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

  Future<List<String>> getRP1210FWVersion(
      String channelId, VCIType vciType) async {
    List<String> retVal = ["false", ""];

    try {
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
          await port?.close();
          return ["false", "Invalid VCI type selected"];
      }
      dongleCommWin = DongleComm(channelId: channelId, isChannel: true);
      if (port != null) {
        dongleCommWin!.comm?.connectivity.value = connectivity;
      } else {
        return ["false", "USB Port not available"];
      }
      dSDiagnostic = UDSDiagnostic(dongleCommWin!, dSDiagnostic);
      String? fwVersion = await dongleCommWin!.rp1210ReadVersion();
      if (fwVersion.trim().isNotEmpty) {
        App.dllFunctions = DLLFunctions(
          dongleCommWin!,
          dSDiagnostic!,
        );

        retVal = ["true", fwVersion];
      } else {
        await port?.close();
        retVal = ["false", "Failed to read firmware version"];
      }
    } catch (e, stackTrace) {
      await port?.close();
      retVal = ["false", "Exception @getRP1210FWVersion(): $e"];
      print(stackTrace);
    }

    return retVal;
  }
}
