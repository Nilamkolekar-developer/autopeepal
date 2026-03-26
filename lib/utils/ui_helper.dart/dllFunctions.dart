import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:typed_data';
import 'package:ap_diagnostic/enum/readDTCIndex.dart'
    show ReadDtcIndex, ClearDtcIndex;
import 'package:ap_diagnostic/enum/seedkeyIndexType.dart';
import 'package:ap_diagnostic/enum/writeParameter.dart';
import 'package:ap_diagnostic/models/flashingMtrixModel.dart';
import 'package:ap_diagnostic/models/freezeFrameModel.dart';
import 'package:ap_diagnostic/models/readDtcResponseModel.dart';
import 'package:ap_diagnostic/models/readParameterPIDModel.dart';
import 'package:ap_diagnostic/models/writeParameterPIDModel.dart'
   ;
import 'package:ap_diagnostic/structure/flash_structures.dart';
import 'package:ap_diagnostic/usd_diagnostic.dart';
import 'package:ap_dongle_comm/utils/dongleComm.dart';
import 'package:ap_dongle_comm/utils/enums/command_ids.dart';
import 'package:ap_dongle_comm/utils/enums/connectivity.dart';
import 'package:ap_dongle_comm/utils/model/responseArrayStatusModel.dart';
import 'package:ap_dongle_comm/utils/model/sessionLogModel.dart';
import 'package:autopeepal/models/doipConfigFile_model.dart';
import 'package:autopeepal/models/dtc_model.dart' hide ReadDtcResponseModel;
import 'package:autopeepal/models/flashRecord_model.dart';
import 'package:autopeepal/models/freezeFrame_model.dart'
    hide
        FreezeFrameModel,
        FreezeFrameResponseModel,
        FreezeFrameCode,
        FreezeFrame;
import 'package:autopeepal/models/liveParameter_model.dart'
    hide FrameOfPidMessage, PIDFrameId;
import 'package:autopeepal/models/staticData.dart';
import 'package:autopeepal/models/unlockecu_model.dart';
import 'package:autopeepal/models/writeParameter_model.dart';

class DLLFunctions {
  final DongleComm mDongleComm;
  final UDSDiagnostic mUdsDiagnostic;
  DLLFunctions(this.mDongleComm, this.mUdsDiagnostic);

  String txHeaderTemp = '';
  String rxHeaderTemp = '';
  int protocolValue = 0;

  Future<String> setDongleProperties1() async {
    try {
      final ecu = StaticData.ecuInfo.first;
      final String protocolNameValue = ecu.protocol!.name!;
      protocolValue = int.parse(ecu.protocol!.autopeepal!, radix: 16);
      protocolNameValue.replaceAll('-', '_');
      txHeaderTemp = ecu.txHeader!;
      rxHeaderTemp = ecu.rxHeader!;
      await mDongleComm.dongleSetProtocol(protocolValue);
      await mDongleComm.canSetTxHeader(txHeaderTemp);
      await mDongleComm.canSetRxHeaderMask(rxHeaderTemp);
      await mDongleComm.canStartPadding("00");
      final Uint8List? firmwareBytes = await mDongleComm.getFirmwareVersion();

      final firmwareVersion = "${firmwareBytes![3].toString().padLeft(2, '0')}."
          "${firmwareBytes[4].toString().padLeft(2, '0')}."
          "${firmwareBytes[5].toString().padLeft(2, '0')}";

      return firmwareVersion;
    } catch (e) {
      return "";
    }
  }

  Future<void> setDongleProperties(
      String protocolName, String txHeaderTemp, String rxHeaderTemp) async {
    try {
      print("🔹 setDongleProperties called");
      print("  protocolName: '$protocolName'");
      print("  txHeaderTemp: '$txHeaderTemp'");
      print("  rxHeaderTemp: '$rxHeaderTemp'");

      // Ensure headers are not empty
      if ((txHeaderTemp.isEmpty || rxHeaderTemp.isEmpty) &&
          (protocolName.isEmpty)) {
        print(
            "⚠️ All headers and protocol are empty. Cannot set dongle properties.");
        return;
      }

      // Get current connectivity type
      final connectivity = mDongleComm.comm?.connectivity;
      if (connectivity == null) {
        print("⚠️ Dongle connectivity is null");
        return;
      }
      print("🔹 Connectivity: $connectivity");

      // RP1210 / CAN FD path
      if (connectivity == Connectivity.rp1210WiFi ||
          connectivity == Connectivity.rp1210Usb ||
          connectivity == Connectivity.canFdUsb ||
          connectivity == Connectivity.canFdWiFi) {
        if (txHeaderTemp.isEmpty || rxHeaderTemp.isEmpty) {
          print(
              "⚠️ txHeaderTemp or rxHeaderTemp is empty, cannot convert to Uint32");
          return;
        }
        final txArray = _hexToReversedUint32(txHeaderTemp);
        final rxArray = _hexToReversedUint32(rxHeaderTemp);

        print(
            "🔹 Sending RP1210 command with txArray: $txArray, rxArray: $rxArray");
        await mDongleComm.rp1210SendCommand(
          txArray,
          rxArray,
          SubCommandId.setMsgFilter,
        );
        print("✅ RP1210 dongle properties set successfully");
      }
      // Standard USB / WiFi / BLE path
      else if (connectivity == Connectivity.usb ||
          connectivity == Connectivity.wiFi ||
          connectivity == Connectivity.ble) {
        if (protocolName.isEmpty) {
          print("⚠️ protocolName is empty, skipping dongleSetProtocol");
        } else {
          try {
            final protocol = int.parse(protocolName, radix: 16);
            await mDongleComm.dongleSetProtocol(protocol);
            print("✅ Dongle protocol set: $protocol");
          } catch (e) {
            print("❌ Failed to parse protocolName '$protocolName': $e");
          }
        }

        if (txHeaderTemp.isNotEmpty) {
          await mDongleComm.canSetTxHeader(txHeaderTemp);
          print("✅ Tx Header set: $txHeaderTemp");
        } else {
          print("⚠️ Tx Header is empty, skipped canSetTxHeader");
        }

        if (rxHeaderTemp.isNotEmpty) {
          await mDongleComm.canSetRxHeaderMask(rxHeaderTemp);
          print("✅ Rx Header mask set: $rxHeaderTemp");
        } else {
          print("⚠️ Rx Header is empty, skipped canSetRxHeaderMask");
        }
      } else {
        print("⚠️ Unsupported connectivity: $connectivity");
      }
    } catch (e) {
      print("❌ Error in setDongleProperties: $e");
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

      final String protocolNameValue = ecu.protocol!.name!;
      protocolValue = int.parse(ecu.protocol!.autopeepal!, radix: 16);

      // parity with C#disconnectVCI1
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
       await mDongleComm.rp1210ClientDisconnect();
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
      await mDongleComm.rp1210ClientDisconnect();
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
       await mDongleComm.rp1210ClientDisconnect();
        status = "Failed to set message filter.";
      }

      return status;
    } catch (e, stack) {
      await mDongleComm.rp1210ClientDisconnect();
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

      final String protocolNameValue = ecu.protocol!.name!;
      protocolValue = int.parse(ecu.protocol!.autopeepal!, radix: 16);

      // (kept for parity with C#)
      protocolNameValue.replaceAll('-', '_');

      txHeaderTemp = ecu.txHeader!;
      rxHeaderTemp = ecu.rxHeader!;

      txHeaderTemp.toReversedUint32();
      rxHeaderTemp.toReversedUint32();

      // ===============================
      // RP1210 Client Connect
      // ===============================
      final bool isConnected =
          await mDongleComm.rp1210ClientConnect(protocolNameValue);

      if (!isConnected) {
   await mDongleComm.rp1210ClientDisconnect();();
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
      await mDongleComm.rp1210ClientDisconnect();
        return "Failed to set Device IP.";
      }

      // ===============================
      // Set ECU IP
      // ===============================
      final Uint8List ecuIp = Uint8List.fromList(
          InternetAddress(doipConfigModel.ecuIp!).rawAddress);

      final bool ecuIpOk = await mDongleComm.rp1210DoipSetEcuIp(ecuIp);

      if (!ecuIpOk) {
      await mDongleComm.rp1210ClientDisconnect();
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
       await mDongleComm.rp1210ClientDisconnect();
        status = "Failed to activate DoIP routing.";
      }

      return status;
    } catch (e, stack) {
     await mDongleComm.rp1210ClientDisconnect();
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
      await mDongleComm.resetDongle();
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

  List<SessionLogsModel> getLogs() {
    print("DLLFunctions.getLogs: Start");

    // Check mDongleComm
    print("DLLFunctions.getLogs: mDongleComm exists");

    final logs = mDongleComm.logs;
    print("DLLFunctions.getLogs: raw logs = $logs");

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

    mDongleComm.logs = <SessionLogsModel>[];
    print("DLLFunctions.clearLogs: Logs cleared");
  }

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

      final version = '${response[3].toString().padLeft(2, '0')}.'
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
    print("🔹 [readDtc] Start - Received index string: $dtcIndex");

    try {
      // 1️⃣ Map string index to enum
      ReadDtcIndex index = ReadDtcIndex.values.firstWhere(
        (e) => e.toString().split('.').last == dtcIndex,
        orElse: () {
          print("❌ No matching ReadDtcIndex enum found for: $dtcIndex");
          throw Exception("Invalid DTC index: $dtcIndex");
        },
      );
      print("✅ [readDtc] Mapped string '$dtcIndex' to enum: $index");

      // 2️⃣ Prepare response model
      ReadDtcResponseModel readDtcResponseModel = ReadDtcResponseModel();

      int attempt = 0;

      // 3️⃣ Retry loop for BUSY or invalid dongle responses
      do {
        attempt++;
        print("⏳ [readDtc] Attempt #$attempt to read DTC...");

        // Call UDS diagnostic layer
        final rawResponse = await mUdsDiagnostic.readDTC(index);

        // Map raw response to our UI model
        readDtcResponseModel.dtcs = rawResponse.dtcs;
        readDtcResponseModel.status = rawResponse.status;
        readDtcResponseModel.noofdtc = rawResponse.noofdtc;

        print("📡 [readDtc] Status received: ${readDtcResponseModel.status}");
        print(
            "📡 [readDtc] Number of DTCs: ${readDtcResponseModel.dtcs?.length ?? 0}");

        if (readDtcResponseModel.status ==
                "GENERALERROR_INVALIDRESPFROMDONGLE" ||
            readDtcResponseModel.status?.contains("BUSY") == true) {
          print("⏳ [readDtc] ECU busy or invalid response, retrying...");
          await Future.delayed(const Duration(milliseconds: 100));
        } else {
          break;
        }
      } while (attempt < 10);

      if (readDtcResponseModel.dtcs != null) {
        print(
            "✅ [readDtc] Success - DTCs parsed: ${readDtcResponseModel.dtcs!.length}");
      } else {
        print("⚠️ [readDtc] Warning - dtcs array is null");
      }

      return readDtcResponseModel;
    } catch (e, st) {
      print("❌ [readDtc] EXCEPTION: $e");
      print("❌ StackTrace: $st");
      return null;
    }
  }

  Future<String> clearDtc(String dtcIndexString) async {
    try {
      print("🔹 clearDtc() called");
      print("🔹 Received dtcIndexString: $dtcIndexString");

      // Convert String -> Enum
      ClearDtcIndex index = ClearDtcIndex.values.byName(dtcIndexString);
      print("🔹 Converted Enum Index: $index");

      int attempt = 0;
      String status = "";

      do {
        attempt++;
        print("⏳ [clearDtc] Attempt #$attempt");

        // Call UDS layer
        final result = await mUdsDiagnostic.clearDTC(index);

        print("🔹 Raw result: $result");

        // Convert result -> JSON
        String res = jsonEncode(result);
        var decoded = jsonDecode(res);

        ClearDtcResponseModel response =
            ClearDtcResponseModel.fromJson(decoded);

        status = response.ecuResponseStatus ?? "";

        print("📡 ECU Status: $status");

        // Retry conditions
        if (status == "GENERALERROR_INVALIDRESPFROMDONGLE" ||
            status.contains("BUSY")) {
          print("⏳ ECU busy / invalid response... retrying");
          await Future.delayed(const Duration(milliseconds: 150));
        } else {
          break;
        }
      } while (attempt < 10);

      print("✅ Final ClearDTC Status: $status");

      return status;
    } catch (e, stack) {
      print("❌ Error in clearDtc()");
      print("❌ Error: $e");
      print("❌ StackTrace: $stack");
      return "";
    }
  }

  // Future<List<ReadPidResponseModel>?> readPid(List<PidCode> pidList) async {
  //   try {
  //     dynamic result;

  //     // Build ReadParameterPID list
  //     List<ReadParameterPID> list = [];

  //     for (var item in pidList) {
  //       List<PidVariable> variables = [];

  //       for (var vari in item.piCodeVariable ?? []) {
  //         int startBit = vari.startBitPosition ?? 0;
  //         int endBit = vari.endBitPosition ?? 0;
  //         int noOfBits = endBit - startBit + 1;

  //         PidVariable pidVariable = PidVariable(
  //           datatype: vari.messageType,
  //           isBitcoded: vari.bitcoded ?? false,
  //           noofBits: noOfBits,
  //           noOfBytes: vari.length ?? 0,
  //           offset: vari.offset?.toDouble() ?? 0.0,
  //           resolution: vari.resolution?.toDouble() ?? 1.0,
  //           startBit: startBit,
  //           startByte: vari.bytePosition ?? 0,
  //           pidNumber: vari.id ?? 0,
  //           pidName: vari.shortName ?? "",
  //           messages: (vari.messages as List<dynamic>?)?.map((mes) {
  //                 if (mes is SelectedParameterMessage) {
  //                   return mes;
  //                 } else if (mes is Map<String, dynamic>) {
  //                   return SelectedParameterMessage.fromJson(mes);
  //                 } else {
  //                   return SelectedParameterMessage(
  //                     code: mes['code'] ?? "",
  //                     message: mes['message'] ?? "",
  //                   );
  //                 }
  //               }).toList() ??
  //               [],
  //         );

  //         variables.add(pidVariable);
  //       }

  //       list.add(
  //         ReadParameterPID(
  //           pidId: item.id ?? 0,
  //           variables: variables,
  //           totalLen: (item.code?.length ?? 0) ~/ 2,
  //           pid: item.code ?? "",
  //         ),
  //       );
  //     }

  //     // Call readParameters (simulating Task.Run in C#)
  //     result = await mUdsDiagnostic.readParameters(list.length, list);

  //     if (result == null) return null;

  //     // Convert result to JSON string then decode to List<ReadPidResponseModel>
  //     final String res = jsonEncode(result);
  //     final List<dynamic> resListDecoded = jsonDecode(res);

  //     return resListDecoded
  //         .map((json) => ReadPidResponseModel.fromJson(json))
  //         .toList();
  //   } catch (ex) {
  //     print("Error reading PIDs: $ex"); // Log the actual exception
  //     return null;
  //   }
  // }

  Future<List<ReadPidResponseModel>?> readPid(List<PidCode> pidList) async {
  try {
    print("🚀 readPid() called");
    print("📌 Total PID requested: ${pidList.length}");

    dynamic result;

    // Build ReadParameterPID list
    List<ReadParameterPID> list = [];

    for (var item in pidList) {
      print("➡️ Building PID: ${item.id}, Code: ${item.code}");

      List<PidVariable> variables = [];

      for (var vari in item.piCodeVariable ?? []) {
        int startBit = vari.startBitPosition ?? 0;
        int endBit = vari.endBitPosition ?? 0;
        int noOfBits = endBit - startBit + 1;

        print(
            "   🔹 Variable ID: ${vari.id}, StartBit: $startBit, EndBit: $endBit");

        PidVariable pidVariable = PidVariable(
          datatype: vari.messageType,
          isBitcoded: vari.bitcoded ?? false,
          noofBits: noOfBits,
          noOfBytes: vari.length ?? 0,
          offset: vari.offset?.toDouble() ?? 0.0,
          resolution: vari.resolution?.toDouble() ?? 1.0,
          startBit: startBit,
          startByte: vari.bytePosition ?? 0,
          pidNumber: vari.id ?? 0,
          pidName: vari.shortName ?? "",
          messages: (vari.messages as List<dynamic>?)?.map((mes) {
                if (mes is SelectedParameterMessage) {
                  return mes;
                } else if (mes is Map<String, dynamic>) {
                  return SelectedParameterMessage.fromJson(mes);
                } else {
                  return SelectedParameterMessage(
                    code: mes['code'] ?? "",
                    message: mes['message'] ?? "",
                  );
                }
              }).toList() ??
              [],
        );

        variables.add(pidVariable);
      }

      list.add(
        ReadParameterPID(
          pidId: item.id ?? 0,
          variables: variables,
          totalLen: (item.code?.length ?? 0) ~/ 2,
          pid: item.code ?? "",
        ),
      );
    }

    print("📤 Sending request to mUdsDiagnostic.readParameters...");
    print("📦 Total packets: ${list.length}");

    // Call readParameters
    result = await mUdsDiagnostic.readParameters(list.length, list);

    print("📥 Raw result from device: $result");

    if (result == null) {
      print("❌ Result is null from readParameters");
      return null;
    }

    // Convert result
    final String res = jsonEncode(result);
    print("📄 Encoded JSON: $res");

    final List<dynamic> resListDecoded = jsonDecode(res);
    print("📊 Decoded response count: ${resListDecoded.length}");

    final parsedList = resListDecoded
        .map((json) => ReadPidResponseModel.fromJson(json))
        .toList();

    print("✅ Parsed ReadPidResponseModel count: ${parsedList.length}");

    for (var item in parsedList) {
      print("➡️ PID: ${item.pidId}, Status: ${item.status}");
    }

    return parsedList;
  } catch (ex) {
    print("🔥 Error reading PIDs: $ex");
    return null;
  }
}

  // Future<List<WriteParameterStatus>?> writePid(
  //     String writePidIndex, List<WriteParameterPid> pidList) async {
  //   try {
  //     // Parse the write parameter index enum
  //     final WriteParameterIndex index = WriteParameterIndex.values
  //         .firstWhere((e) => e.toString().split('.').last == writePidIndex);

  //     List<WriteParameterPID> list = [];

  //     for (var item in pidList) {
  //       // Parse seed key index enum
  //       final SEEDKEYINDEXTYPE seedIndex = SEEDKEYINDEXTYPE.values.firstWhere(
  //           (e) => e.toString().split('.').last == item.seedKeyIndex);

  //       final WriteParameterIndex writeIndex = WriteParameterIndex.values
  //           .firstWhere(
  //               (e) => e.toString().split('.').last == item.writePamIndex);

  //       // Debug print
  //       print(
  //           "🔹 PID: ${item.writePid}, SeedKeyIndex: $seedIndex, WriteParamIndex: $writeIndex");

  //       // Build variant data list
  //       List<VariantDataList> variantDataLists = [];

  //       for (var v in item.variantList ?? []) {
  //         variantDataLists.add(VariantDataList(
  //           datatype: v.datatype,
  //           isBitcoded: v.isBitcoded,
  //           noofBits: v.noofBits,
  //           noOfBytes: v.noOfBytes,
  //           offset: v.offset,
  //           pidId: v.pidId,
  //           pidName: v.pidName,
  //           resolution: v.resolution,
  //           startBit: v.startBit,
  //           startByte: v.startByte,
  //           unit: v.unit,
  //         ));
  //       }

  //       list.add(WriteParameterPID(
  //         seedKeyIndex: seedIndex,
  //         writePamIndex: writeIndex,
  //         writeInputSize: item.writeParaDataSize,
  //         writeInput: item.writeInput,
  //         writePid: item.writePid,
  //         readParameterPidDataType: item.readParameterPidDataType,
  //         pid: item.pid,
  //         startByte: item.startByte,
  //         totalBytes: item.totalBytes,
  //         variantList: variantDataLists,
  //       ));
  //     }

  //     // Call UDS diagnostic write method
  //     final result =
  //         await mUdsDiagnostic.writeParameters(pidList.length, index, list);

  //     // Convert result to JSON string and back to List
  //     final resJson = jsonEncode(result);
  //     final resList = (jsonDecode(resJson) as List)
  //         .map((e) => WriteParameterStatus.fromJson(e))
  //         .toList();

  //     return resList;
  //   } catch (e) {
  //     print("Error in writePid: $e");
  //     return null;
  //   }
  // }


Future<List<WriteParameterStatus>?> writePid(
    String writePidIndex, List<WriteParameterPid> pidList) async {
  try {

    print("========== WRITE PID START ==========");
    print("Incoming writePidIndex: $writePidIndex");
    print("PID List Length: ${pidList.length}");

    // Parse write parameter index
    final WriteParameterIndex index = WriteParameterIndex.values
        .firstWhere((e) => e.toString().split('.').last == writePidIndex);

    print("Parsed WriteParameterIndex: $index");

    List<WriteParameterPID> list = [];

    for (var item in pidList) {

      print("------------- PID ITEM -------------");
      print("writePid: ${item.writePid}");
      print("seedKeyIndex (raw): ${item.seedKeyIndex}");
      print("writePamIndex (raw): ${item.writePamIndex}");
      print("writeParaDataSize: ${item.writeParaDataSize}");
      print("writeInput: ${item.writeInput}");
      print("pid: ${item.pid}");
      print("startByte: ${item.startByte}");
      print("totalBytes: ${item.totalBytes}");

      // Parse seed key index
      final SEEDKEYINDEXTYPE seedIndex =
          SEEDKEYINDEXTYPE.values.firstWhere(
              (e) => e.toString().split('.').last == item.seedKeyIndex);

      print("Parsed SeedKeyIndex Enum: $seedIndex");

      // Parse write parameter index
      final WriteParameterIndex writeIndex =
          WriteParameterIndex.values.firstWhere(
              (e) => e.toString().split('.').last == item.writePamIndex);

      print("Parsed WriteParamIndex Enum: $writeIndex");

      // Build variant data list
      List<VariantDataList> variantDataLists = [];

      if (item.variantList != null) {

        print("Variant List Count: ${item.variantList!.length}");

        for (var v in item.variantList!) {

          print("  ---- Variant ----");
          print("  pidId: ${v.pidId}");
          print("  pidName: ${v.pidName}");
          print("  datatype: ${v.datatype}");
          print("  isBitcoded: ${v.isBitcoded}");
          print("  noOfBits: ${v.noofBits}");
          print("  noOfBytes: ${v.noOfBytes}");
          print("  startByte: ${v.startByte}");
          print("  startBit: ${v.startBit}");
          print("  offset: ${v.offset}");
          print("  resolution: ${v.resolution}");
          print("  unit: ${v.unit}");

          variantDataLists.add(VariantDataList(
            datatype: v.datatype,
            isBitcoded: v.isBitcoded,
            noofBits: v.noofBits,
            noOfBytes: v.noOfBytes,
            offset: v.offset,
            pidId: v.pidId,
            pidName: v.pidName,
            resolution: v.resolution,
            startBit: v.startBit,
            startByte: v.startByte,
            unit: v.unit,
          ));
        }
      }

      list.add(WriteParameterPID(
        seedKeyIndex: seedIndex,
        writePamIndex: writeIndex,
        writeInputSize: item.writeParaDataSize,
        writeInput: item.writeInput,
        writePid: item.writePid,
        readParameterPidDataType: item.readParameterPidDataType,
        pid: item.pid,
        startByte: item.startByte,
        totalBytes: item.totalBytes,
        variantList: variantDataLists,
      ));

      print("PID Added to Write List");
    }

    print("Final WriteParameterPID List Length: ${list.length}");

    print("Calling writeParameters()...");
    print("Parameters:");
    print("  PID Count: ${pidList.length}");
    print("  Write Index: $index");

    // Call UDS diagnostic write method
    final result =
        await mUdsDiagnostic.writeParameters(pidList.length, index, list);

    print("Raw Result from writeParameters(): $result");

    if (result == null) {
      print("⚠ writeParameters returned NULL");
      return null;
    }

    print("Converting result to JSON...");

    final resJson = jsonEncode(result);

    print("JSON Result: $resJson");

    final resList = (jsonDecode(resJson) as List)
        .map((e) => WriteParameterStatus.fromJson(e))
        .toList();

    print("Parsed WriteParameterStatus List Length: ${resList.length}");

    print("========== WRITE PID END ==========");

    return resList;

  } catch (e, stack) {

    print("❌ Error in writePid: $e");
    print("StackTrace: $stack");

    return null;
  }
}



  String byteArrayToString(List<int> bytes) {
    return bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join()
        .toUpperCase();
  }

  void cancel() {
    throw UnimplementedError('Cancel() is not implemented yet.');
  }

  // Future<String?> startECUFlashing(
  //   String flashJson,
  //   String interpreter,
  //   Ecu2 ecu2,
  //   String sklFN,
  //   List<EcuMapFile> ecuMapFiles,
  // ) async {
  //   try {
  //     flashingPercent != 0.0; // Assuming flashingPercent is RxInt or similar

  //     // Deserialize JSON
  //     final jsonData = FlashingMatrixData.fromJson(jsonDecode(flashJson));

  //     // Replace "-" with "_" and parse enum
  //     sklFN = sklFN.replaceAll('-', '_');
  //     final seedkeyindx = SEEDKEYINDEXTYPE.values.firstWhere(
  //       (e) =>
  //           e.toString().split('.').last.toUpperCase() == sklFN.toUpperCase(),
  //       orElse: () => SEEDKEYINDEXTYPE.values.first, // default fallback
  //     );

  //     final flashConfig = FlashConfig(
  //       seedKeyIndex: seedkeyindx,
  //       // Add other properties if needed
  //     );

  //     await startTesterPresent();

  //     final response = await mUdsDiagnostic.flashInterpreter(
  //       flashConfig,
  //       jsonData.noOfSectors ?? 0,
  //       jsonData.sectorData!.cast<FlashingMatrix>(),
  //       interpreter,
  //     );

  //     await stopTesterPresent();

  //     return response;
  //   } catch (e) {
  //     return null;
  //   }
  // }

  Future<String?> startECUFlashing(
  String flashJson,
  String interpreter,
  Ecu2 ecu2,
  String sklFN,
  List<EcuMapFile> ecuMapFiles,
) async {
  try {
    print("🚀 [FLASH] ===== START ECU FLASHING =====");

    print("📥 [INPUT] sklFN (raw): $sklFN");
    print("📥 [INPUT] interpreter: $interpreter");
    print("📥 [INPUT] ECU: ${ecu2.ecu}");
    print("📥 [INPUT] flashJson length: ${flashJson.length}");

    // 🔄 Fix protocol string
    sklFN = sklFN.replaceAll('-', '_');
    print("🔄 [PROCESS] sklFN normalized: $sklFN");

    // 📦 Parse JSON
    final jsonMap = jsonDecode(flashJson);
    print("📦 [JSON] Parsed successfully");

    final jsonData = FlashingMatrixData.fromJson(jsonMap);
    print("📦 [JSON] noOfSectors: ${jsonData.noOfSectors}");
    print("📦 [JSON] sectorData count: ${jsonData.sectorData?.length}");

    // 🔐 Enum parsing
    final seedkeyindx = SEEDKEYINDEXTYPE.values.firstWhere(
      (e) {
        final enumName = e.toString().split('.').last;
        print("🔍 [ENUM CHECK] comparing $enumName with $sklFN");
        return enumName.toUpperCase() == sklFN.toUpperCase();
      },
      orElse: () {
        print("⚠️ [ENUM] No match found, using default");
        return SEEDKEYINDEXTYPE.values.first;
      },
    );

    print("✅ [ENUM] Selected: $seedkeyindx");

    final flashConfig = FlashConfig(
      seedKeyIndex: seedkeyindx,
    );

    print("⚙️ [CONFIG] FlashConfig created");

    // ▶️ Start tester present
    print("📡 [UDS] Starting tester present...");
    await startTesterPresent();
    print("✅ [UDS] Tester present started");

    // 🚀 Flash start
    print("🚀 [FLASH] Calling flashInterpreter...");
    final response = await mUdsDiagnostic.flashInterpreter(
      flashConfig,
      jsonData.noOfSectors ?? 0,
      jsonData.sectorData!,
      interpreter,
    );

    print("📥 [FLASH RESPONSE]: $response");

    // ⛔ Stop tester present
    print("🛑 [UDS] Stopping tester present...");
    await stopTesterPresent();
    print("✅ [UDS] Tester present stopped");

    print("🎉 [FLASH] ===== COMPLETED SUCCESS =====");

    return response;
  } catch (e, stackTrace) {
    print("❌ [ERROR] Flashing failed: $e");
    print("📍 [STACKTRACE]: $stackTrace");

    return null;
  }
}

  double? flashingPercent;

  Future<void> startTesterPresent() async {
    // Check connectivity type
    if (mDongleComm.comm!.connectivity != Connectivity.doipUsb &&
        mDongleComm.comm!.connectivity != Connectivity.doipWiFi) {
      // Call CAN start method
      await mDongleComm.canStartTP();
      // You can handle `result` if needed
    }
  }

  Future<void> stopTesterPresent() async {
    // Check connectivity type
    if (mDongleComm.comm!.connectivity != Connectivity.doipUsb &&
        mDongleComm.comm!.connectivity != Connectivity.doipWiFi) {
      // Call CAN stop method
      await mDongleComm.canStopTP();
      // You can handle `result` if needed
    }
  }

  Future<void> txHeader(String txHeader) async {
    // Call the CAN set TX header method
    final setHeader = await mDongleComm.canSetTxHeader(txHeader);

    // Assuming setHeader is List<int> (byte array equivalent in Dart)
    final headerResponse = byteArrayToString(setHeader);

    // Print debug info
    print(
        "------DTC TX Header Set------ $txHeader , Header Response-- $headerResponse");
  }

  Future<void> rxHeader(String rxHeader) async {
    // Call the CAN set RX header mask method
    final setHeader = await mDongleComm.canSetRxHeaderMask(rxHeader);

    // Assuming setHeader is List<int> (byte array equivalent in Dart)
    final headerResponse = byteArrayToString(setHeader);

    // Print debug info
    print(
        "------DTC RX Header Set------ $rxHeader , RX Header Response-- $headerResponse");
  }

  Future<String?> unlockEcu(ResultUnlock unlockData) async {
    try {
      // Extract data from unlockData
      final txId = unlockData.txId;
      final txFrame = unlockData.txFrame;
      final txFrequency = unlockData.txFrequency;
      final txTotalTime = unlockData.txTotalTime;
      final rxId = unlockData.rxId;
      final protocolValue = unlockData.protocol!.autopeepal;

      // Set dongle properties
      setDongleProperties(protocolValue!, txId!, rxId!);

      // Start ECU unlocking
      final response = await mUdsDiagnostic.startEcuUnlocking(
          txFrame!, txFrequency!, txTotalTime!);

      return response;
    } catch (e) {
      return null;
    }
  }

  Future<WriteParameterStatus?> writeAtuatorTest(
    String writeParaIndex,
    String seedKeyIndex,
    List<List<int>> command,
  ) async {
    try {
      final writeIndex = WriteParameterIndex.values.firstWhere(
        (e) => e.toString().split('.').last == writeParaIndex,
      );

      final seedIndex = SEEDKEYINDEXTYPE.values.firstWhere(
        (e) => e.toString().split('.').last == seedKeyIndex,
      );

      // Convert List<List<int>> → List<Uint8List>
      final commandBytes = command.map((e) => Uint8List.fromList(e)).toList();

      final result = await mUdsDiagnostic.actuatorTestWriteParameters(
        writeIndex,
        seedIndex,
        commandBytes,
      );

      final res = jsonEncode(result);
      final resp = WriteParameterStatus.fromJson(jsonDecode(res));

      return resp;
    } catch (e) {
      return null;
    }
  }

 Future<TestRoutineResponseModel?> setTestRoutineCommand(
  String seedKey,
  String writeParaIndex,
  String startCommand,
) async {
  try {
    // Convert string → enum
    final seedIndex = SEEDKEYINDEXTYPE.values
        .firstWhere((e) => e.name == seedKey);

    final writeIndex = WriteParameterIndex.values
        .firstWhere((e) => e.name == writeParaIndex);

    // Call API / SDK method
    final result = await mUdsDiagnostic.startIdIOR(
      seedIndex,
      writeIndex,
      startCommand,
    );

    // Convert result → JSON → Model
    final json = jsonEncode(result);
    final response =
        TestRoutineResponseModel.fromJson(jsonDecode(json));

    return response;
  } catch (e) {
    return null;
  }
}

  Future<TestRoutineResponseModel?> continueIorTest(
    String seedKey,
    String writeParaIndex,
    String startCommand,
    String requestCommand,
    String stopCommand,
    bool testCondition,
    int bitPosition,
    List<String> activeCommand,
    String stoppedCommand,
    String failCommand,
    bool isStop,
    int timeBase,
    bool isTimebase,
  ) async {
    TestRoutineResponseModel response = TestRoutineResponseModel();

    try {
      // Parse enums
      SEEDKEYINDEXTYPE seedIndex = SEEDKEYINDEXTYPE.values.byName(seedKey);
      WriteParameterIndex writeIndex =
          WriteParameterIndex.values.byName(writeParaIndex);

      final result = await mUdsDiagnostic.iorTestParameters2(
        seedKeyIndex1: seedIndex,
        writeParameterIndex: writeIndex,
        startCommand: startCommand,
        requestCommand: requestCommand,
        stopCommand: stopCommand,
        inputTestCondition: testCondition,
        bitPosition: bitPosition,
        activeCommands: activeCommand,
        completeCommand: stoppedCommand,
        failCommand: failCommand,
        isStop: isStop,
        timeBase: timeBase,
        isTimebase: isTimebase,
      );

      // Convert result to model
      // ignore: unnecessary_null_comparison
      if (result != null) {
        response =
            TestRoutineResponseModel.fromJson(result as Map<String, dynamic>);
      }

      return response;
    } catch (e) {
      return null;
    }
  }

  Future<TestRoutineResponseModel?> requestIorTest(
      String requestCommand) async {
    try {
      final result = await mUdsDiagnostic.requestIdIOR(requestCommand);

      final response =
          TestRoutineResponseModel.fromJson(result as Map<String, dynamic>);

      return response;
    } catch (e) {
      return null;
    }
  }

  Future<TestRoutineResponseModel?> stopIorTest(String stopCommand) async {
    try {
      final result = await mUdsDiagnostic.stopIdIOR(stopCommand);

      final response =
          TestRoutineResponseModel.fromJson(result as Map<String, dynamic>);

      return response;
    } catch (e) {
      return null;
    }
  }

  Future<List<IvnReadDtcResponseModel>?> ivnReadDtc(
      List<String> frameIDC) async {
    try {
      List<IvnResponseArrayStatus>? ivnReadDTCResponse = [];
      List<IvnReadDtcResponseModel> frameResponseList = [];

      // Call dongle method
      ivnReadDTCResponse = await mDongleComm.setIvnFrame(frameIDC);

      if (ivnReadDTCResponse != null && ivnReadDTCResponse.isNotEmpty) {
        for (var item in ivnReadDTCResponse) {
          IvnReadDtcResponseModel ivnReadDtcResponseModel =
              IvnReadDtcResponseModel();

          ivnReadDtcResponseModel.actualDataBytes = item.actualDataBytes;

          ivnReadDtcResponseModel.ecuResponse =
              convertedByteToString(item.ecuResponse);

          ivnReadDtcResponseModel.ecuResponseStatus = item.ecuResponseStatus;

          ivnReadDtcResponseModel.frame = item.frame;

          frameResponseList.add(ivnReadDtcResponseModel);
        }
      }

      return frameResponseList;
    } catch (e) {
      return null;
    }
  }

  static String convertedByteToString(List<int>? bytes) {
    if (bytes == null) return "";
    return utf8.decode(bytes);
  }

  Future<List<ReadPidResponseModel>?> ivnReadPid(
      List<IVNSelectedPID> ivnPidList) async {
    try {
      List<IVNSelectedPID> list = [];

      for (var item in ivnPidList) {
        List<PIDFrameId> pidId = [];

        for (var item1 in item.frameIds ?? []) {
          PIDFrameId newFrame = PIDFrameId(
            framID: item1.framID,
            pidDescription: item1.pidDescription,
            startByte: item1.startByte,
            byteValue: item1.byteValue,
            bitCoded: item1.bitCoded,
            startBit: item1.startBit,
            noOfBits: item1.noOfBits,
            resolution: item1.resolution,
            offset: item1.offset,
            unit: item1.unit,
            messageType: item1.messageType,
            frameOfPidMessage: [],
            endian: item1.endian,
            numType: item1.numType,
          );

          for (var item2 in item1.frameOfPidMessage ?? []) {
            newFrame.frameOfPidMessage?.add(
              FrameOfPidMessage(
                code: item2.code,
                message: item2.message,
              ),
            );
          }

          pidId.add(newFrame);
        }

        list.add(
          IVNSelectedPID(
            frameId: item.frameId,
            frameIds: pidId,
          ),
        );
      }
      final result = await mUdsDiagnostic.ivnReadParameters(
        ivnPidList.length,
        list.cast<PIDFrameId>(),
      );

      List<ReadPidResponseModel> responseList = (result as List)
          .map((e) => ReadPidResponseModel.fromJson(e))
          .toList();

      return responseList;
    } catch (e) {
      return null;
    }
  }

  Future<double> flashingData() async {
    try {
      double flashingPercent = await mUdsDiagnostic.getRuntimeFlashPercent();
      return flashingPercent;
    } catch (e) {
      return 0;
    }
  }

  Future<double> resetPercentage() async {
    try {
      await mUdsDiagnostic.resetPercentage();
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // Future<String?> enterExtendedSession(
  //     String writePidIndex, String seedKeyIndex) async {
  //   try {
  //     String status = "";

  //     WriteParameterIndex index =
  //         WriteParameterIndex.values.firstWhere((e) => e.name == writePidIndex);

  //     SeedKeyIndexType seedIndex =
  //         SeedKeyIndexType.values.firstWhere((e) => e.name == seedKeyIndex);

  //     final result =
  //         await mUdsDiagnostic.enterExtendedSession(index, seedIndex);

  //     Map<String, dynamic> json =
  //         Map<String, dynamic>.from(result as Map<dynamic, dynamic>);

  //     ClearDtcResponseModel response = ClearDtcResponseModel.fromJson(json);

  //     status = response.ecuResponseStatus ?? "";

  //     return status;
  //   } catch (e) {
  //     return null;
  //   }
  // }

  Future<FreezeFrameResponseModel> getFreezeFrame(
      String dtcCode, FreezeFrameResult frameServerResult) async {
    FreezeFrameResponseModel freezeFrameResponseModel =
        FreezeFrameResponseModel();

    try {
      FreezeFrameResponseModel freezeFrameResponse = FreezeFrameResponseModel();

      List<FreezeFrameCode> ffCodeList = [];

      FreezeFrameModel freezeFrameModel = FreezeFrameModel(
        ffSet: frameServerResult.ffSet,
        id: frameServerResult.id,
        isActive: frameServerResult.isActive,
        freezeFrameCode: [],
      );

      for (var item in frameServerResult.freezeFrameCode ?? []) {
        ffCodeList.add(
          FreezeFrameCode(
            noofBits:
                ((item.endBitPosition ?? 0) - (item.startBitPosition ?? 0)) + 1,
            startBit: item.startBitPosition ?? 0,
            bitcoded: item.bitcoded,
            bytePosition: item.bytePosition,
            code: item.code,
            desc: item.desc,
            endian: item.endian,
            priority: item.priority,
            endBitPosition: item.endBitPosition,
            freezframeMessages: item.freezframeMessages,
            id: item.id,
            messageType: item.messageType,
            length: item.length,
            numType: item.numType,
            offset: item.offset ?? 0,
            resolution: item.resolution ?? 1,
            startBitPosition: item.startBitPosition,
            unit: item.unit,
          ),
        );
      }

      if (ffCodeList.isNotEmpty) {
        ffCodeList.sort((a, b) => (a.priority ?? 0).compareTo(b.priority ?? 0));
        freezeFrameModel.freezeFrameCode = ffCodeList;
      }

      freezeFrameResponse =
          (await mUdsDiagnostic.getFreezeFrame(dtcCode, freezeFrameModel));

      if (freezeFrameResponse.status == "NOERROR") {
        freezeFrameResponseModel.dtcs = [];

        for (var item in freezeFrameResponse.dtcs ?? []) {
          freezeFrameResponseModel.dtcs!.add(
            FreezeFrame(
              code: item.code,
              priority: item.priority,
              value: item.value,
            ),
          );
        }
      }

      freezeFrameResponseModel.status = freezeFrameResponse.status;

      return freezeFrameResponseModel;
    } catch (e) {
      return FreezeFrameResponseModel(
        status: e.toString(),
      );
    }
  }

  // Future<List<ReadPidResponseModel>?> setRoutineValue(List<PidCode> pidList,
  //     String pidByAddrSeq, Uint8List actualResponse) async {
  //   try {
  //     dynamic result;

  //     List<ReadParameterPID> list = [];
  //     List<ReadParameterPID> listOfAddrPid = [];

  //     for (var item in pidList) {
  //       List<PidVariable> variables = [];

  //       for (var vari in item.piCodeVariable ?? []) {
  //         List<SelectedParameterMessage> messageValueList = [];

  //         if (vari.messages != null) {
  //           for (var messageItem in vari.messages!) {
  //             messageValueList.add(
  //               SelectedParameterMessage(
  //                 code: messageItem.code,
  //                 message: messageItem.message,
  //               ),
  //             );
  //           }
  //         }

  //         int startBit = vari.startBitPosition ?? 0;
  //         int endBit = vari.endBitPosition ?? 0;

  //         PidVariable pidVariable = PidVariable(
  //           datatype: vari.messageType,
  //           isBitcoded: vari.bitcoded,
  //           noofBits: (endBit - startBit) + 1,
  //           noOfBytes: vari.length,
  //           offset: vari.offset,
  //           resolution: vari.resolution,
  //           startBit: startBit,
  //           startByte: vari.bytePosition,
  //           pidNumber: vari.id,
  //           pidName: vari.shortName,
  //           messages: messageValueList,
  //         );

  //         variables.add(pidVariable);
  //       }

  //       ReadParameterPID pid = ReadParameterPID(
  //         pidId: item.id,
  //         variables: variables,
  //         totalLen: (item.code?.length ?? 0) ~/ 2,
  //         pid: item.code,
  //       );

  //       if (item.memoryAddress == false) {
  //         list.add(pid);
  //       } else {
  //         listOfAddrPid.add(pid);
  //       }
  //     }

  //     result = await mUdsDiagnostic.setRoutineValue(
  //       list.length,
  //       list,
  //       actualResponse,
  //     );

  //     List<ReadPidResponseModel> responseList = (result as List)
  //         .map((e) =>
  //             ReadPidResponseModel.fromJson(Map<String, dynamic>.from(e)))
  //         .toList();

  //     return responseList;
  //   } catch (e) {
  //     return null;
  //   }
  // }

  Future<List<ReadPidPresponseModel>?> setRoutineValue(
  List<PidCode> pidList,
  String? pidByAddrSeq,
  List<int> actualResponse,
) async {
  try {
    dynamic result;

    List<ReadParameterPID> list = [];
    List<ReadParameterPID> listOfAddrPid = [];

    for (var item in pidList) {
      List<PidVariable> variables = [];

      for (var vari in item.piCodeVariable ?? []) {
        List<SelectedParameterMessage> messageValueList = [];

        if (vari.messages != null) {
          for (var messageItem in vari.messages!) {
            messageValueList.add(
              SelectedParameterMessage(
                code: messageItem.code,
                message: messageItem.message,
              ),
            );
          }
        }

        int endBit = vari.endBitPosition ?? 0;
        int startBit = vari.startBitPosition ?? 0;

        PidVariable pidVariable = PidVariable(
          datatype: vari.messageType,
          isBitcoded: vari.bitcoded,
          noofBits: (endBit - startBit + 1),
          noOfBytes: vari.length,
          offset: vari.offset,
          resolution: vari.resolution,
          startBit: startBit,
          startByte: vari.bytePosition,
          pidNumber: vari.id,
          pidName: vari.shortName,
          messages: messageValueList,
        );

        variables.add(pidVariable);
      }

      ReadParameterPID pidObj = ReadParameterPID(
        pidId: item.id,
        variables: variables,
        totalLen: (item.code?.length ?? 0) ~/ 2,
        pid: item.code,
      );

      if (item.memoryAddress == false) {
        list.add(pidObj);
      } else {
        listOfAddrPid.add(pidObj);
      }
    }

    // API call (same as Task.Run)
    result = await mUdsDiagnostic.setRoutineValue(
      list.length,
      list,
      Uint8List.fromList(actualResponse),
    );

    // Convert response
    List<ReadPidPresponseModel> resList =
        (result as List)
            .map((e) => ReadPidPresponseModel.fromJson(e))
            .toList();

    return resList;
  } catch (e) {
    return null;
  }
}

  Future<bool> writeSSID(String routerSSID) async {
    try {
      Uint8List? setHotspot =
          await mDongleComm.wifiWriteSSID(toHex(routerSSID));

      if (setHotspot == null) {
        print("SSID response is NULL");
        return false;
      }

      String resp = byteArrayToString(setHotspot);
      print("SSID Response: $resp");

      return resp.contains("00E1F0");
    } catch (e) {
      print("SSID Error: $e");
      return false;
    }
  }

  Future<bool> writePassword(String routerPassword) async {
    try {
      Uint8List? setHotspot =
          await mDongleComm.wifiWritePassword(toHex(routerPassword));

      if (setHotspot == null) {
        print("Password response is NULL");
        return false;
      }

      String resp = byteArrayToString(setHotspot);
      print("Password Response: $resp");

      return resp.contains("00E1F0");
    } catch (e) {
      print("Password Error: $e");
      return false;
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
