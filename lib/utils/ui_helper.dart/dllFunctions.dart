import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:typed_data';
import 'package:ap_diagnostic/enum/readDTCIndex.dart' show ReadDtcIndex, ClearDtcIndex;
import 'package:ap_diagnostic/models/readParameterPIDModel.dart';
import 'package:ap_diagnostic/usd_diagnostic.dart';
import 'package:ap_dongle_comm/utils/dongleComm.dart';
import 'package:ap_dongle_comm/utils/enums/command_ids.dart';
import 'package:ap_dongle_comm/utils/enums/connectivity.dart';
import 'package:ap_dongle_comm/utils/model/sessionLogModel.dart';
import 'package:autopeepal/models/doipConfigFile_model.dart';
import 'package:autopeepal/models/dtc_model.dart';
import 'package:autopeepal/models/liveParameter_model.dart';
import 'package:autopeepal/models/staticData.dart';


class DLLFunctions {
  final DongleComm mDongleComm;
  final UDSDiagnostic mUdsDiagnostic;
  DLLFunctions(this.mDongleComm, this.mUdsDiagnostic);

  String txHeaderTemp = '';
  String rxHeaderTemp = '';
  int protocolValue = 0;

  // =========================================================
  // 1️⃣ SetDongleProperties (protocol + headers ONLY)
  // C# : Task SetDongleProperties(string, string, string)
  // =========================================================
  Future<void> setDongleProperties(
    String protocolName,
    String txHeaderTemp,
    String rxHeaderTemp,
  ) async {
    try {
      final connectivity = mDongleComm.comm!.connectivity;

      // RP1210 / CAN FD
      if (connectivity == Connectivity.rp1210WiFi ||
          connectivity == Connectivity.rp1210Usb ||
          connectivity == Connectivity.canFdUsb ||
          connectivity == Connectivity.canFdWiFi) {
        final txArray = _hexToReversedUint32(txHeaderTemp);
        final rxArray = _hexToReversedUint32(rxHeaderTemp);

        await mDongleComm.rp1210SendCommand(
          txArray,
          rxArray,
          SubCommandId.setMsgFilter,
        );
      }

      // USB / WiFi / BLE
      else if (connectivity == Connectivity.usb ||
          connectivity == Connectivity.wiFi ||
          connectivity == Connectivity.ble) {
        final protocol = int.parse(protocolName, radix: 16);

        await mDongleComm.dongleSetProtocol(protocol);
        await mDongleComm.canSetTxHeader(txHeaderTemp);
        await mDongleComm.canSetRxHeaderMask(rxHeaderTemp);
      }
    } catch (e) {
      print("setDonglePropertiesWithHeaders error: $e");
    }
  }

  Future<String> setDongleProperties1() async {
    try {
      // ===============================
      // Read ECU info (same as C#)
      // ===============================
      final ecu = StaticData.ecuInfo.first;

      final String protocolNameValue = ecu.protocol.name!;
      protocolValue = int.parse(ecu.protocol.autopeepal!, radix: 16);

      // (kept for parity with C#, even if not used)
      protocolNameValue.replaceAll('-', '_');

      txHeaderTemp = ecu.txHeader!;
      rxHeaderTemp = ecu.rxHeader!;

      // ===============================
      // Set protocol & headers
      // ===============================
      await mDongleComm.dongleSetProtocol(protocolValue);
      await mDongleComm.canSetTxHeader(txHeaderTemp);
      await mDongleComm.canSetRxHeaderMask(rxHeaderTemp);
      await mDongleComm.canStartPadding("00");
      // await mDongleComm.canSetP2Max("2710"); // optional

      // ===============================
      // Read firmware version
      // ===============================
      final Uint8List? firmwareBytes = await mDongleComm.getFirmwareVersion();

      final firmwareVersion = "${firmwareBytes![3].toString().padLeft(2, '0')}."
          "${firmwareBytes[4].toString().padLeft(2, '0')}."
          "${firmwareBytes[5].toString().padLeft(2, '0')}";

      return firmwareVersion;
    } catch (e) {
      // Same behavior as C# (return empty string)
      return "";
    }
  }

  Future<String> setRp1210Properties() async {
    try {
      String status = '';

      // ===============================
      // Read ECU info
      // ===============================
      final ecuList = StaticData.ecuInfo;
      final ecu = ecuList.first;

      final String protocolNameValue = ecu.protocol.name!;
      protocolValue = int.parse(ecu.protocol.autopeepal!, radix: 16);

      // parity with C#
      protocolNameValue.replaceAll('-', '_');

      txHeaderTemp = ecu.txHeader!;
      rxHeaderTemp = ecu.rxHeader!;

      final Uint8List txArray = txHeaderTemp.toReversedUint32();
      final Uint8List rxArray = rxHeaderTemp.toReversedUint32();

      // ===============================
      // RP1210 Client Connect
      // ===============================
      final bool isConnected =
          await mDongleComm.rp1210ClientConnect(protocolNameValue);

      if (!isConnected) {
        mDongleComm.comm?.disconnectVCI();
        return "Failed to connect client.";
      }

      // ===============================
      // Set Flow Control (Primary ECU)
      // ===============================
      final bool flowOk = await mDongleComm.rp1210SendCommand(
        txArray,
        rxArray,
        SubCommandId.setFlowControl,
      );

      if (!flowOk) {
        mDongleComm.comm?.disconnectVCI();
        return "Failed to set flow control.";
      }

      // ===============================
      // Additional ECUs
      // ===============================
      if (ecuList.length > 1) {
        for (int i = 1; i < ecuList.length; i++) {
          final Uint8List txArr = ecuList[i].txHeader!.toReversedUint32();
          final Uint8List rxArr = ecuList[i].rxHeader!.toReversedUint32();

          final bool ok = await mDongleComm.rp1210SendCommand(
            txArr,
            rxArr,
            SubCommandId.setFlowControl,
          );

          if (!ok) {
            return "Failed to set flow control.";
          }
        }
      }

      // ===============================
      // Set Message Filter
      // ===============================
      final bool filterOk = await mDongleComm.rp1210SendCommand(
        txArray,
        rxArray,
        SubCommandId.setMsgFilter,
      );

      if (filterOk) {
        status = "Success";
      } else {
        mDongleComm.comm!.disconnectVCI();
        status = "Failed to set message filter.";
      }

      return status;
    } catch (e, stack) {
      mDongleComm.comm!.disconnectVCI();
      return "Exception @SetRP1210Properties(): $e $stack";
    }
  }

  Future<String> setDoipRp1210Properties(
      DoipConfigModel doipConfigModel) async {
    try {
      String status = '';

      // ===============================
      // Read ECU info
      // ===============================
      final ecu = StaticData.ecuInfo.first;

      final String protocolNameValue = ecu.protocol.name!;
      protocolValue = int.parse(ecu.protocol.autopeepal!, radix: 16);

      // (kept for parity with C#)
      final String value = protocolNameValue.replaceAll('-', '_');

      txHeaderTemp = ecu.txHeader!;
      rxHeaderTemp = ecu.rxHeader!;

      final Uint8List txArray = txHeaderTemp.toReversedUint32();
      final Uint8List rxArray = rxHeaderTemp.toReversedUint32();

      // ===============================
      // RP1210 Client Connect
      // ===============================
      final bool isConnected =
          await mDongleComm.rp1210ClientConnect(protocolNameValue);

      if (!isConnected) {
        mDongleComm.comm!.disconnectVCI();
        return "Failed to connect client.";
      }

      // ===============================
      // Set Device IP (DoIP)
      // ===============================
      final Uint8List staticIp = Uint8List.fromList(
          InternetAddress(doipConfigModel.staticIp ?? '').rawAddress);
      final Uint8List subnetMask = Uint8List.fromList(
          InternetAddress(doipConfigModel.subnetMask!).rawAddress);
      final Uint8List gatewayIp = Uint8List.fromList(
          InternetAddress(doipConfigModel.getwayIp!).rawAddress);

      final bool deviceIpOk = await mDongleComm.rp1210DoipSetDeviceIp(
        staticIp,
        subnetMask,
        gatewayIp,
      );

      if (!deviceIpOk) {
        mDongleComm.comm!.disconnectVCI();
        return "Failed to set Device IP.";
      }

      // ===============================
      // Set ECU IP
      // ===============================
      final Uint8List ecuIp = Uint8List.fromList(
          InternetAddress(doipConfigModel.ecuIp!).rawAddress);

      final bool ecuIpOk = await mDongleComm.rp1210DoipSetEcuIp(ecuIp);

      if (!ecuIpOk) {
        mDongleComm.comm!.disconnectVCI();
        return "Failed to set ECU IP.";
      }

      // ===============================
      // Activate DoIP Routing
      // ===============================
      mDongleComm.txArray =
          _hexStringToByteArray(StaticData.ecuInfo.first.txHeader!);
      mDongleComm.rxArray =
          _hexStringToByteArray(StaticData.ecuInfo.first.rxHeader!);

      final Uint8List? routineActivationResp =
          await mDongleComm.rp1210DoipSendMessage(
        Uint8List(4), // new byte[4]
        isRoutineActivation: true,
      );

      if (routineActivationResp != null &&
          routineActivationResp.length > 12 &&
          routineActivationResp[12] == 0x10) {
        status = "Success";
      } else {
        mDongleComm.comm!.disconnectVCI();
        status = "Failed to activate DoIP routing.";
      }

      return status;
    } catch (e, stack) {
      mDongleComm.comm!.disconnectVCI();
      return "Exception @SetDoipRP1210Properties(): $e $stack";
    }
  }

// Future<void> notifyBleData(bool isNotify) async {
//   try {
//     if (isNotify) {
//       // Subscribe BLE responses
//       await mDongleComm.comm.subUnsubBleResp(true);

//       // Set BLE protocol (0x15)
//       await mDongleComm.dongleSetProtocol(0x15);
//     } else {
//       // Unsubscribe BLE responses
//       await mDongleComm.comm.subUnsubBleResp(false);

//       // Restore previous protocol
//       await mDongleComm.dongleSetProtocol(protocolValue);
//     }
//   } catch (e) {
//debugPrint("notifyBleData error: $e");
//     // Same behavior as C# (silent catch)
//   }
// }

  Future<void> disconnectVCI1() async {
    try {
      final connectivity = mDongleComm.comm!.connectivity;
      if (connectivity == Connectivity.rp1210WiFi ||
          connectivity == Connectivity.rp1210Usb ||
          connectivity == Connectivity.canFdUsb ||
          connectivity == Connectivity.canFdWiFi ||
          connectivity == Connectivity.doipUsb ||
          connectivity == Connectivity.doipWiFi) {
        await mDongleComm.rp1210ClientDisconnect();
      }
      await mDongleComm.comm?.disconnectVCI();
    } catch (e) {
       print("❌ Error disconnecting VCI: $e");
    }
  }

  Future<String> checkEcuStatus() async {
    try {
      final resp = await mDongleComm.can2xTxRx(2, '1003');
      return resp.ecuResponseStatus ?? '';
    } catch (_) {
      return '';
    }
  }

  // List<SessionLogsModel> getLogs() {
  //   final logs = mDongleComm.logs; // <-- added missing semicolon
  //   final List<SessionLogsModel> sessionLogsModel = [];

  //   for (final item in logs!) {
  //     sessionLogsModel.add(SessionLogsModel(
  //       header: item.header,
  //       message: item.message,
  //       status: item.status == "NOERROR" ? '' : item.status,
  //     ));
  //   }

  //   return sessionLogsModel;
  // }

  // void clearLogs() {
  //   mDongleComm.logs = <SessionLogsModel>[];
  // }

  List<SessionLogsModel> getLogs() {
  print("DLLFunctions.getLogs: Start");

  // Check mDongleComm
  if (mDongleComm == null) {
    print("Error: mDongleComm is null!");
    return [];
  } else {
    print("DLLFunctions.getLogs: mDongleComm exists");
  }

  final logs = mDongleComm.logs;
  print("DLLFunctions.getLogs: raw logs = $logs");

  if (logs == null) {
    print("DLLFunctions.getLogs: logs list is null, returning empty list");
    return [];
  }

  final List<SessionLogsModel> sessionLogsModel = [];
  for (final item in logs) {
    print("DLLFunctions.getLogs: processing item = $item");
    sessionLogsModel.add(SessionLogsModel(
      header: item.header,
      message: item.message,
      status: item.status == "NOERROR" ? '' : item.status,
     // color: item.color, // optional, if SessionLogsModel has it
    ));
  }

  print(
      "DLLFunctions.getLogs: Finished, returning ${sessionLogsModel.length} items");
  return sessionLogsModel;
}

void clearLogs() {
  print("DLLFunctions.clearLogs: Start");
  if (mDongleComm == null) {
    print("Error: mDongleComm is null! Cannot clear logs");
    return;
  }

  mDongleComm.logs = <SessionLogsModel>[];
  print("DLLFunctions.clearLogs: Logs cleared");
}

  // Future<String> getFirmware() async {
  //   try {
  //     final firmwareVersion = await mDongleComm.getFirmwareVersion();
  //     final firmwareResult = firmwareVersion as Uint8List;

  //     final ver = '${firmwareResult[3].toString().padLeft(2, '0')}.'
  //         '${firmwareResult[4].toString().padLeft(2, '0')}.'
  //         '${firmwareResult[5].toString().padLeft(2, '0')}';

  //     return ver;
  //   } catch (e) {
  //     return '';
  //   }
  // }

  Future<String> getFirmware() async {
  try {
    final response = await mDongleComm.getFirmwareVersion();

    // ✅ Check null
    if (response == null) {
      print("Firmware response is null");
      return '';
    }

    // ✅ Check minimum length
    if (response.length < 6) {
      print("Firmware response too short: $response");
      return '';
    }

    final version =
        '${response[3].toString().padLeft(2, '0')}.'
        '${response[4].toString().padLeft(2, '0')}.'
        '${response[5].toString().padLeft(2, '0')}';

    print("Parsed Firmware Version: $version");

    return version;
  } catch (e) {
    print("Firmware Exception: $e");
    return '';
  }
}

  Future<bool> updateFirmware(String command) async {
    try {
      final hexCommand = toHex(command);
      final firmwareVersion = await mDongleComm.updateFirmware(hexCommand);

      return firmwareVersion == "20010000E1F0";
    } catch (e) {
      return false;
    }
  }

  /// Converts a string to its hexadecimal representation (like C# ToHex)
  String toHex(String input) {
    final buffer = StringBuffer();
    for (final c in input.codeUnits) {
      buffer.write(c.toRadixString(16).padLeft(2, '0').toUpperCase());
    }
    return buffer.toString();
  }

  Future<ReadDtcResponseModel?> readDtc(String dtcIndex) async {
    try {
      // Parse string to enum directly — will throw if dtcIndex is invalid
      final index = ReadDtcIndex.values.firstWhere(
        (e) => e.toString().split('.').last == dtcIndex,
      );

      // Call the async UDS diagnostic method
      final readDTCResponse = await mUdsDiagnostic.readDTC(index);

      // Map to your response model
      final readDtcResponseModel = ReadDtcResponseModel(
        dtcs: readDTCResponse.dtcs,
        status: readDTCResponse.status,
        noOfDtc: readDTCResponse.noofdtc,
      );

      return readDtcResponseModel;
    } catch (e) {
      // Return null if anything goes wrong, just like your C# catch
      print('Error reading DTC: $e');
      return null;
    }
  }

Future<String?> clearDtc(String dtcIndex) async {
  try {
    String? status = "";

    // Parse the string index to your Enum
    // In Dart, you'd typically use a lookup or .values.byName()
    ClearDtcIndex index = ClearDtcIndex.values.byName(dtcIndex);

    // In Dart, 'await' is sufficient. 
    // If mUdsDiagnostic.clearDTC is CPU-intensive, use compute() or Isolate.run()
    // but for I/O / Network, simple await is the standard.
    final result = await mUdsDiagnostic.clearDTC(index);

    // Instead of Serialize -> Deserialize, we typically access the map or use a Factory
    // Assuming 'result' is a Map or an object with a toJson/toMap method
    final responseJson = jsonEncode(result);
    final responseData = ClearDtcResponseModel.fromJson(jsonDecode(responseJson));

    status = responseData.ecuResponseStatus;
    return status;
    
  } catch (ex) {
    // Return empty string on error as per original logic
    return "";
  }
}
 
Future<List<ReadPidPresponseModel>?> readPid(List<PidCode> pidList) async {
  try {
    List<ReadParameterPID> list = [];

    for (var item in pidList) {
      List<PidVariable> variables = [];

      for (var vari in item.piCodeVariable ?? []) {
        // Calculate bit count: (end - start) + 1
        int startBit = vari.startBitPosition ?? 0;
        int endBit = vari.endBitPosition ?? 0;
        int noOfBits = endBit - startBit + 1;

        PidVariable pidVariable = PidVariable(
          datatype: vari.messageType,
          isBitcoded: vari.bitcoded,
          noofBits: noOfBits,
          noOfBytes: vari.length,
          offset: vari.offset,
          resolution: vari.resolution,
          startBit: startBit,
          startByte: vari.bytePosition,
          pidNumber: vari.id,
          pidName: vari.shortName,
          messages: [],
        );

        // Map messages if they exist
        if (vari.messages != null && vari.messages!.isNotEmpty) {
          pidVariable.messages = vari.messages!.map((mes) => 
            SelectedParameterMessage(
              code: mes.code,
              message: mes.message,
            )
          ).toList();
        }
        
        variables.add(pidVariable);
      }

      list.add(
        ReadParameterPID(
          pidId: item.id,
          variables: variables,
          totalLen: (item.code?.length ?? 0) ~/ 2, // integer division
          pid: item.code,
        ),
      );
    }

    // Call the diagnostic service
    final result = await mUdsDiagnostic.readParameters(list.length, list);

    // Convert result to List of Models
    // Assuming result is already a Map/List from a platform channel or library
    final String res = jsonEncode(result);
    final List<dynamic> decodedList = jsonDecode(res);
    
    return decodedList
        .map((json) => ReadPidPresponseModel.fromJson(json))
        .toList();

  } catch (ex) {
    print("Error reading PID: $ex");
    return null;
  }
}
  
}

  Uint8List _hexToReversedUint32(String hex) {
    final value = int.parse(hex, radix: 16);
    final data = ByteData(4)..setUint32(0, value);
    return Uint8List.fromList(
      data.buffer.asUint8List().reversed.toList(),
    );
  }

  Uint8List _hexStringToByteArray(String hex) {
    final cleanHex = hex.replaceAll(' ', '');
    final int len = cleanHex.length;
    final Uint8List result = Uint8List((len + 1) ~/ 2);

    int i = 0, j = 0;
    if (len % 2 == 1) {
      result[j++] = int.parse(cleanHex.substring(0, 1), radix: 16);
      i = 1;
    }
    for (; i < len; i += 2) {
      result[j++] = int.parse(cleanHex.substring(i, i + 2), radix: 16);
    }
    return result;
  }


extension HexUtils on String {
  Uint8List toReversedUint32() {
    final value = int.parse(this, radix: 16);
    final data = ByteData(4)..setUint32(0, value);
    return Uint8List.fromList(
      data.buffer.asUint8List().reversed.toList(),
    );
  }
}
