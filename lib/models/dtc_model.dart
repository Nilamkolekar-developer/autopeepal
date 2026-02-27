import 'dart:typed_data';

import 'package:flutter/material.dart';

class IvnDtc {
  int? count;
  dynamic next;
  dynamic previous;
  List<IVNResult>? results;

  IvnDtc({this.count, this.next, this.previous, this.results});

  factory IvnDtc.fromJson(Map<String, dynamic> json) {
    return IvnDtc(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: json['results'] != null
          ? List<IVNResult>.from(
              json['results'].map((x) => IVNResult.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'count': count,
        'next': next,
        'previous': previous,
        'results': results?.map((x) => x.toJson()).toList(),
      };
}

class IVNResult {
  int? id;
  String? code;
  String? description;
  List<FrameDataset>? frameDatasets;

  IVNResult({this.id, this.code, this.description, this.frameDatasets});

  factory IVNResult.fromJson(Map<String, dynamic> json) {
    return IVNResult(
      id: json['id'],
      code: json['code'],
      description: json['description'],
      frameDatasets: json['frame_datasets'] != null
          ? List<FrameDataset>.from(
              json['frame_datasets'].map((x) => FrameDataset.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'description': description,
        'frame_datasets': frameDatasets?.map((x) => x.toJson()).toList(),
      };
}

class FrameDataset {
  int? id;
  String? frameName;
  String? frameId;
  dynamic frameDescription;
  List<FrameId>? frameIds;
  List<FrameEnum>? frameEnum;
  List<FrameStatus>? frameStatus;

  FrameDataset({
    this.id,
    this.frameName,
    this.frameId,
    this.frameDescription,
    this.frameIds,
    this.frameEnum,
    this.frameStatus,
  });

  factory FrameDataset.fromJson(Map<String, dynamic> json) {
    return FrameDataset(
      id: json['id'],
      frameName: json['frame_name'],
      frameId: json['frame_id'],
      frameDescription: json['frame_description'],
      frameIds: json['frame_ids'] != null
          ? List<FrameId>.from(
              json['frame_ids'].map((x) => FrameId.fromJson(x)))
          : null,
      frameEnum: json['frame_enum'] != null
          ? List<FrameEnum>.from(
              json['frame_enum'].map((x) => FrameEnum.fromJson(x)))
          : null,
      frameStatus: json['frame_status'] != null
          ? List<FrameStatus>.from(
              json['frame_status'].map((x) => FrameStatus.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'frame_name': frameName,
        'frame_id': frameId,
        'frame_description': frameDescription,
        'frame_ids': frameIds?.map((x) => x.toJson()).toList(),
        'frame_enum': frameEnum?.map((x) => x.toJson()).toList(),
        'frame_status': frameStatus?.map((x) => x.toJson()).toList(),
      };
}

class FrameId {
  int? id;
  int? frameName;
  String? dtcCode;
  String? dtcDescription;
  String? byteValue;
  String? bit;
  String? noOfBits;
  String? statusByte;
  String? statusBit;
  String? statusNoOfBits;

  FrameId({
    this.id,
    this.frameName,
    this.dtcCode,
    this.dtcDescription,
    this.byteValue,
    this.bit,
    this.noOfBits,
    this.statusByte,
    this.statusBit,
    this.statusNoOfBits,
  });

  factory FrameId.fromJson(Map<String, dynamic> json) => FrameId(
        id: json['id'],
        frameName: json['frame_name'],
        dtcCode: json['dtc_code'],
        dtcDescription: json['dtc_description'],
        byteValue: json['byte'],
        bit: json['bit'],
        noOfBits: json['no_of_bits'],
        statusByte: json['status_byte'],
        statusBit: json['status_bit'],
        statusNoOfBits: json['status_no_of_bits'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'frame_name': frameName,
        'dtc_code': dtcCode,
        'dtc_description': dtcDescription,
        'byte': byteValue,
        'bit': bit,
        'no_of_bits': noOfBits,
        'status_byte': statusByte,
        'status_bit': statusBit,
        'status_no_of_bits': statusNoOfBits,
      };
}

class FrameEnum {
  int? id;
  String? digit;
  String? enumValue;

  FrameEnum({this.id, this.digit, this.enumValue});

  factory FrameEnum.fromJson(Map<String, dynamic> json) => FrameEnum(
        id: json['id'],
        digit: json['digit'],
        enumValue: json['enum'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'digit': digit,
        'enum': enumValue,
      };
}

class FrameStatus {
  int? id;
  String? digit;
  String? enumValue;

  FrameStatus({this.id, this.digit, this.enumValue});

  factory FrameStatus.fromJson(Map<String, dynamic> json) => FrameStatus(
        id: json['id'],
        digit: json['digit'],
        enumValue: json['enum'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'digit': digit,
        'enum': enumValue,
      };
}

class DtcMainModel {
  int? count;
  dynamic next;
  dynamic previous;
  List<DtcResults>? results;
  String? message;

  DtcMainModel(
      {this.count, this.next, this.previous, this.results, this.message});

  factory DtcMainModel.fromJson(Map<String, dynamic> json) => DtcMainModel(
        count: json['count'],
        next: json['next'],
        previous: json['previous'],
        results: json['results'] != null
            ? List<DtcResults>.from(
                json['results'].map((x) => DtcResults.fromJson(x)))
            : null,
        message: json['message'],
      );

  Map<String, dynamic> toJson() => {
        'count': count,
        'next': next,
        'previous': previous,
        'results': results?.map((x) => x.toJson()).toList(),
        'message': message,
      };
}

class DtcResults {
  int? id;
  String? code;
  dynamic description;
  String? isActive;
  List<DtcCode>? dtcCode;
  List<DtcListModel>? dtcCode1;

  DtcResults(
      {this.id,
      this.code,
      this.description,
      this.isActive,
      this.dtcCode,
      this.dtcCode1});

  factory DtcResults.fromJson(Map<String, dynamic> json) => DtcResults(
        id: json['id'],
        code: json['code'],
        description: json['description'],
        isActive: json['is_active'],
        dtcCode: json['dtc_code'] != null
            ? List<DtcCode>.from(
                json['dtc_code'].map((x) => DtcCode.fromJson(x)))
            : null,
        dtcCode1: json['dtc_code1'] != null
            ? List<DtcListModel>.from(
                json['dtc_code1'].map((x) => DtcListModel.fromJson(x)))
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'description': description,
        'is_active': isActive,
        'dtc_code': dtcCode?.map((x) => x.toJson()).toList(),
        'dtc_code1': dtcCode1?.map((x) => x.toJson()).toList(),
      };
}

class DtcCode {
  int? id;
  String? code;
  String? description;
  String? isActive;
  String? statusActivation;
  String? lampActivation;

  DtcCode(
      {this.id,
      this.code,
      this.description,
      this.isActive,
      this.statusActivation,
      this.lampActivation});

  factory DtcCode.fromJson(Map<String, dynamic> json) => DtcCode(
        id: json['id'],
        code: json['code'],
        description: json['description'],
        isActive: json['is_active'],
        statusActivation: json['status_activation'],
        lampActivation: json['lamp_activation'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'description': description,
        'is_active': isActive,
        'status_activation': statusActivation,
        'lamp_activation': lampActivation,
      };
}

class DtcListModel {
  int? id;
  String? code;
  String? description;
  String? status;
  String? statusColor;

  DtcListModel(
      {this.id, this.code, this.description, this.status, this.statusColor});

  factory DtcListModel.fromJson(Map<String, dynamic> json) => DtcListModel(
        id: json['id'],
        code: json['code'],
        description: json['description'],
        status: json['status'],
        statusColor: json['status_color'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'description': description,
        'status': status,
        'status_color': statusColor,
      };
}

// ------------------ DTC ECU ------------------
class DtcEcusModel extends ChangeNotifier {
  String? ecuName;
  int? ecuId;

  double _opacity = 1.0;
  double get opacity => _opacity;
  set opacity(double value) {
    _opacity = value;
    notifyListeners();
  }

  List<DtcCode>? dtcList;
  String? txHeader;
  String? rxHeader;
  int? pidCodeFf;
  Protocol? protocol;
  String? clearDtcIndex;
  int? ffSet;

  DtcEcusModel({
    this.ecuName,
    this.ecuId,
    double? opacity,
    this.dtcList,
    this.txHeader,
    this.rxHeader,
    this.pidCodeFf,
    this.protocol,
    this.clearDtcIndex,
    this.ffSet,
  }) {
    if (opacity != null) _opacity = opacity;
  }

  factory DtcEcusModel.fromJson(Map<String, dynamic> json) => DtcEcusModel(
        ecuName: json['ecu_name'],
        ecuId: json['ecu_id'],
        opacity: json['opacity']?.toDouble(),
        dtcList: json['dtc_list'] != null
            ? List<DtcCode>.from(
                json['dtc_list'].map((x) => DtcCode.fromJson(x)))
            : [],
        txHeader: json['tx_header'],
        rxHeader: json['rx_header'],
        pidCodeFf: json['pid_code_ff'],
        protocol: json['protocol'] != null
            ? Protocol.fromJson(json['protocol'])
            : null,
        clearDtcIndex: json['clear_dtc_index'],
        ffSet: json['ff_set'],
      );

  Map<String, dynamic> toJson() => {
        'ecu_name': ecuName,
        'ecu_id': ecuId,
        'opacity': _opacity,
        'dtc_list': dtcList?.map((x) => x.toJson()).toList(),
        'tx_header': txHeader,
        'rx_header': rxHeader,
        'pid_code_ff': pidCodeFf,
        'protocol': protocol?.toJson(),
        'clear_dtc_index': clearDtcIndex,
        'ff_set': ffSet,
      };
}

// ------------------ Read DTC ------------------
class ReadDtcResponseModel {
  String? status;
  List<List<String>>? dtcs; // 2D array
  int? noOfDtc;

  ReadDtcResponseModel({this.status, this.dtcs, this.noOfDtc});

  factory ReadDtcResponseModel.fromJson(Map<String, dynamic> json) =>
      ReadDtcResponseModel(
        status: json['status'],
        dtcs: json['dtcs'] != null
            ? List<List<String>>.from(
                json['dtcs'].map((x) => List<String>.from(x)))
            : [],
        noOfDtc: json['noofdtc'],
      );

  Map<String, dynamic> toJson() => {
        'status': status,
        'dtcs': dtcs,
        'noofdtc': noOfDtc,
      };
}

class ClearDtcResponseModel {
  String? ecuResponseStatus;
  String? ecuResponse;
  String? actualDataBytes;

  ClearDtcResponseModel(
      {this.ecuResponseStatus, this.ecuResponse, this.actualDataBytes});

  factory ClearDtcResponseModel.fromJson(Map<String, dynamic> json) =>
      ClearDtcResponseModel(
        ecuResponseStatus: json['ECUResponseStatus'],
        ecuResponse: json['ECUResponse'],
        actualDataBytes: json['ActualDataBytes'],
      );

  Map<String, dynamic> toJson() => {
        'ECUResponseStatus': ecuResponseStatus,
        'ECUResponse': ecuResponse,
        'ActualDataBytes': actualDataBytes,
      };
}

class IvnReadDtcResponseModel {
  int? ecuId;
  String? frame;
  String? ecuResponseStatus;
  String? ecuResponse;
  Uint8List? actualDataBytes;

  IvnReadDtcResponseModel({
    this.ecuId,
    this.frame,
    this.ecuResponseStatus,
    this.ecuResponse,
    this.actualDataBytes,
  });

  factory IvnReadDtcResponseModel.fromJson(Map<String, dynamic> json) =>
      IvnReadDtcResponseModel(
        ecuId: json['ecu_id'],
        frame: json['Frame'],
        ecuResponseStatus: json['ECUResponseStatus'],
        ecuResponse: json['ECUResponse'],
        actualDataBytes: json['ActualDataBytes'] != null
            ? Uint8List.fromList(List<int>.from(json['ActualDataBytes']))
            : null,
      );

  Map<String, dynamic> toJson() => {
        'ecu_id': ecuId,
        'Frame': frame,
        'ECUResponseStatus': ecuResponseStatus,
        'ECUResponse': ecuResponse,
        'ActualDataBytes': actualDataBytes,
      };
}

// ------------------ IVN Results ------------------
class IVN_Result {
  int? id;
  String? code;
  String? description;
  List<FrameDataset>? frameDatasets;

  IVN_Result({this.id, this.code, this.description, this.frameDatasets});

  factory IVN_Result.fromJson(Map<String, dynamic> json) => IVN_Result(
        id: json['id'],
        code: json['code'],
        description: json['description'],
        frameDatasets: json['frame_datasets'] != null
            ? List<FrameDataset>.from(
                json['frame_datasets'].map((x) => FrameDataset.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'description': description,
        'frame_datasets': frameDatasets?.map((x) => x.toJson()).toList(),
      };
}

class FrameStatu {
  int? id;
  String? digit;
  String? enumValue;

  FrameStatu({this.id, this.digit, this.enumValue});

  factory FrameStatu.fromJson(Map<String, dynamic> json) => FrameStatu(
        id: json['id'],
        digit: json['digit'],
        enumValue: json['enum'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'digit': digit,
        'enum': enumValue,
      };
}

// ------------------ FrameId ------------------

// ------------------ Placeholder classes ------------------

class Protocol {
  Protocol();
  factory Protocol.fromJson(Map<String, dynamic> json) => Protocol();
  Map<String, dynamic> toJson() => {};
}
