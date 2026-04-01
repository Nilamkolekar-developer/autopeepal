import 'dart:typed_data';
import 'package:ap_diagnostic/usd_diagnostic.dart';
import 'package:ap_dongle_comm/utils/commController.dart';
import 'package:ap_dongle_comm/utils/dongleComm.dart';
import 'package:ap_dongle_comm/utils/enums/connectivity.dart';
import 'package:autopeepal/app.dart';
import 'package:autopeepal/utils/ui_helper.dart/dllFunctions.dart';
import 'package:autopeepal/utils/ui_helper.dart/enums.dart';
import 'package:get/get.dart';
import 'package:libserialport/libserialport.dart';
import 'package:ecu_seedkey/ecu_seedkey.dart';

class ConnectionUSBWindows {
  SerialPort? serialPort;
  dynamic dongleCommWin;
  dynamic dSDiagnostic;

  Future<bool> connectUsb(VCIType vciType) async {
    try {
      print("🔍 Checking available serial ports...");
      final portNames = SerialPort.availablePorts;
      print("📋 Available ports: $portNames");

      String? targetPortName;

      for (var name in portNames) {
        final tempPort = SerialPort(name);
        final description = tempPort.description ?? "";
        print("🔹 Port: $name, Description: $description");

        if (description.contains("Silicon Labs CP210x") ||
            description.contains("CH340")) {
          targetPortName = name;
          print("✅ Target port found: $targetPortName");
          break;
        }
      }

      if (targetPortName == null) {
        print("❌ No compatible USB port found.");
        return false;
      }

      final isCH340 =
          (SerialPort(targetPortName).description ?? "").contains("CH340");
      int baudRate = isCH340 ? 115200 : 460800;
      print("⚡ Using baud rate: $baudRate");

      final comm = Get.put(CommController());
      print("🔌 Attempting to connect via CommController...");
      await comm.connectDesktopUsb(targetPortName, baudRate);

      if (comm.isConnected.value) {
        print("✅ Serial device linked to CommController on $targetPortName.");
        return true;
      } else {
        print("❌ Connection failed after attempting.");
      }

      return false;
    } catch (e) {
      print("🔥 Error connecting: $e");
      return false;
    }
  }

  Future<bool> connectUsbForConfig() async {
    try {
      print("🔍 Checking available serial ports...");
      final portNames = SerialPort.availablePorts;
      print("📋 Available ports: $portNames");

      String? targetPortName;

      for (var name in portNames) {
        final tempPort = SerialPort(name);
        final desc = tempPort.description ?? "";
        print("🔹 Port: $name, Description: $desc");

        if (desc.contains("Silicon Labs CP210x")) {
          targetPortName = name;
          print("✅ Target port found for config: $targetPortName");
          break;
        }
      }

      if (targetPortName == null) {
        print("❌ No serial device found for config.");
        return false;
      }

      final comm = Get.put(CommController());
      print(
          "🔌 Attempting to connect via CommController to $targetPortName...");
      await comm.connectDesktopUsb(targetPortName, 460800);

      if (!comm.isConnected.value) {
        print("❌ CommController failed to connect to $targetPortName");
        return false;
      }

      print("✅ Serial device linked via CommController for Config.");

      // Initialize dongleCommWin
      dongleCommWin = DongleComm(channelId: "00", isChannel: true);
      dongleCommWin!.comm = comm;
      dSDiagnostic = UDSDiagnostic(dongleCommWin!, ECUCalculateSeedkey());

      print("🔐 Requesting Security Access from dongle...");
      Uint8List? securityAccess = await dongleCommWin!.securityAccess();
      print(
          "📨 Security Access Response: ${securityAccess != null ? securityAccess.map((e) => e.toRadixString(16).padLeft(2, '0')).join(' ') : 'NULL'}");

      if (securityAccess != null &&
          securityAccess.length > 3 &&
          securityAccess[3] == 0x00) {
        print("✅ Security Access Success!");
        App.dllFunctions = DLLFunctions(dongleCommWin!, dSDiagnostic!);
        return true;
      } else {
        print("❌ Security Access Failed or Invalid Response.");
        return false;
      }
    } catch (e) {
      print("🔥 Error in connectUsbForConfig: $e");
      return false;
    }
  }

  Future<List<String>> getDongleMacID({String channelId = '00'}) async {
    try {
      final comm = Get.find<CommController>();
      if (!comm.isConnected.value) {
        return ["false", "CommController: Serial port not connected"];
      }
      dongleCommWin = DongleComm(channelId: channelId, isChannel: true);
      dongleCommWin!.comm = comm;
      dSDiagnostic = UDSDiagnostic(dongleCommWin!, ECUCalculateSeedkey());
      print("🔐 Requesting Security Access...");
      Uint8List? securityAccess = await dongleCommWin!.securityAccess();

      if (securityAccess != null &&
          securityAccess.length > 3 &&
          securityAccess[3] == 0x00) {
        print("✅ Security Access Granted. Requesting MAC ID...");
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

      return ["false", "Security access denied or No Response"];
    } catch (e) {
      print("🔥 Exception in getDongleMacID: $e");
      return ["false", "Exception: $e"];
    }
  }

  Future<List<String>> getRP1210FWVersion(
      String channelId, VCIType vciType) async {
    List<String> retVal = ["false", "Unknown error"];

    try {
      // ignore: unused_local_variable
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
          serialPort?.close();
          return ["false", "Invalid VCI type selected"];
      }
      dongleCommWin = DongleComm(
        channelId: channelId,
        isChannel: true,
      );
      final comm = Get.find<CommController>();
      if (!comm.isConnected.value) {
        return ["false", "CommController: Serial port not connected"];
      }
      dongleCommWin!.comm = comm;
      dSDiagnostic = UDSDiagnostic(dongleCommWin!, ECUCalculateSeedkey());
      String fwVersion = "x.x.x";

      if (fwVersion.trim().isNotEmpty) {
        App.dllFunctions = DLLFunctions(dongleCommWin!, dSDiagnostic!);

        retVal = ["true", fwVersion];
      } else {
        serialPort?.close();
        retVal = ["false", "Failed to read firmware version"];
      }
    } catch (e) {
      serialPort?.close();
      print("🔥 Exception in getRP1210FWVersion: $e");
      retVal = ["false", "Exception @GetRP1210FWVersion(): $e"];
    }

    return retVal;
  }
}
