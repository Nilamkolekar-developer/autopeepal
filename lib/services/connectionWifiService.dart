import 'dart:async';
import 'dart:io';
import 'package:ap_diagnostic/usd_diagnostic.dart';
import 'package:ap_dongle_comm/utils/commController.dart';
import 'package:ap_dongle_comm/utils/dongleComm.dart';
import 'package:ap_dongle_comm/utils/enums/connectivity.dart';
import 'package:autopeepal/app.dart';
import 'package:autopeepal/services/hotspot_service.dart';
import 'package:autopeepal/utils/ui_helper.dart/dllFunctions.dart';
import 'package:autopeepal/utils/ui_helper.dart/enums.dart';
import 'package:ecu_seedkey/ecu_seedkey.dart';
import 'package:flutter/foundation.dart';

CommController? comm;
DongleComm? dongleCommWin;
UDSDiagnostic? dSDiagnostic;

class ConnectionWifi {
  Socket? _socket;

  Future<List<DiscoveredService>?> getDeviceList() async {
    final List<DiscoveredService> devices = [];
    final MdnsDiscoveryService mdns =
        MdnsDiscoveryService(serviceType: "_http._tcp");

    final completer = Completer<List<DiscoveredService>?>();

    late StreamSubscription sub;
    sub = mdns.discoveredServices.listen((service) {
      final name = service.name.toLowerCase();
      if (name.contains("obd2") || name.startsWith("ap")) {
        if (!devices.any((d) => d.ip == service.ip)) {
          devices.add(service);
        }
      }
    });
    await mdns.startDiscovery();
    Future.delayed(const Duration(seconds: 15), () async {
      await sub.cancel();
      await mdns.stopDiscovery();
      if (devices.isEmpty) {
        completer.complete(null);
      } else {
        completer.complete(devices);
      }
    });

    return completer.future;
  }

  Future<String> getDongleMacID(String ip,
      {String channelId = "00", int port = 6888}) async {
    try {
      comm ??= CommController();
      print("CommController initialized.");
      dongleCommWin = DongleComm(channelId: channelId, isChannel: true);
      dongleCommWin!.comm = comm;
      print(
          "DongleComm initialized with channelId: $channelId and comm assigned");
      print("Connecting to $ip:$port via WiFi...");
      await comm!.connectWifi(host: ip, port: port);
      print("WiFi connected.");
      dSDiagnostic ??= UDSDiagnostic(dongleCommWin!, ECUCalculateSeedkey());
      print("UDSDiagnostic initialized.");
      print("Sending Security Access command...");
      await dongleCommWin!.securityAccess();
      print("Security Access completed.");
      print("Sending Get MAC ID command...");
      Uint8List? macResp = await dongleCommWin!.getWifiMacId();
      print("Raw MAC response: $macResp");

      if (macResp == null || macResp.length < 9) {
        print("Error: Invalid MAC response");
        return "";
      }

      String macId = [
        macResp[3],
        macResp[4],
        macResp[5],
        macResp[6],
        macResp[7],
        macResp[8]
      ].map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase()).join(":");
      print("Parsed MAC ID: $macId");
      print("Sending Get Firmware Version command...");
      Uint8List? fwResp = await dongleCommWin!.getFirmwareVersion();
      print("Raw firmware response: $fwResp");

      if (fwResp != null && fwResp.length >= 6) {
        String ver =
            '${fwResp[3].toString().padLeft(2, '0')}.${fwResp[4].toString().padLeft(2, '0')}.${fwResp[5].toString().padLeft(2, '0')}';
        print("Dongle Firmware Version: $ver");
      }
      print("Initializing DLLFunctions...");
      App.dllFunctions = DLLFunctions(dongleCommWin!, dSDiagnostic!);
      print("DLLFunctions initialized.");

      return macId;
    } catch (e) {
      print("Error @getDongleMacID: $e");
      return "";
    } finally {
      try {} catch (_) {}
    }
  }

  Future<List<String>> getRP1210FWVersion(
      String ipAddress, VCIType vciType, String channelId) async {
    try {
      print("========== getRP1210FWVersion START ==========");

      print("[STEP] Closing existing socket...");
      await _socket?.close();

      String host = ipAddress;
      int port = 6888;

      if (ipAddress.contains(':')) {
        final parts = ipAddress.split(':');
        host = parts[0];
        port = int.tryParse(parts[1]) ?? 6888;
      }

      print("[INFO] Host: $host");
      print("[INFO] Port: $port");

      print("[STEP] Selecting connectivity type...");
      switch (vciType) {
        case VCIType.RP1210:
          print("[INFO] Selected: RP1210 WiFi");
          break;
        case VCIType.CAN2xFD:
          print("[INFO] Selected: CAN FD WiFi");
          break;
        case VCIType.DOIP:
          print("[INFO] Selected: DOIP WiFi");
          break;
        default:
          print("[ERROR] Invalid VCI Type");
          return ["false", "Invalid VCI type selected"];
      }

      comm ??= CommController();
      print("CommController initialized.");
      dongleCommWin = DongleComm(channelId: channelId, isChannel: true);
      dongleCommWin!.comm = comm;
      print(
          "DongleComm initialized with channelId: $channelId and comm assigned");
      print("Connecting to $host:$port via WiFi...");
      await comm!.connectWifi(host: host, port: port);
      print("WiFi connected.");
      dSDiagnostic ??= UDSDiagnostic(dongleCommWin!, ECUCalculateSeedkey());
      print("UDSDiagnostic initialized.");

      print("[STEP] Sending Firmware Request (not implemented yet)");
      String fwVersion = "x.x.x";

      print("[INFO] Firmware Version (dummy): $fwVersion");

      if (fwVersion.isNotEmpty) {
        print("[STEP] Initializing DLLFunctions...");
        App.dllFunctions = DLLFunctions(dongleCommWin!, dSDiagnostic!);

        print("[SUCCESS] DLLFunctions initialized");

        print("========== getRP1210FWVersion SUCCESS ==========");
        return ["true", fwVersion];
      } else {
        print("[ERROR] Firmware version empty");
        return ["false", "Failed to read firmware version"];
      }
    } catch (e, stackTrace) {
      print("========== ERROR in getRP1210FWVersion ==========");
      print("[ERROR] $e");
      print("[STACKTRACE] $stackTrace");

      return ["false", "Exception @getRP1210FWVersion(): $e \n $stackTrace"];
    }
  }
}
