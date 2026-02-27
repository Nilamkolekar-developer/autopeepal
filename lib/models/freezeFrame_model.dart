import 'package:flutter/foundation.dart';

class FreezeFrameModel {
  int? count;
  dynamic next;
  dynamic previous;
  String? message;
  List<FreezeFrameResult>? results;

  FreezeFrameModel({this.count, this.next, this.previous, this.message, this.results});

  factory FreezeFrameModel.fromJson(Map<String, dynamic> json) => FreezeFrameModel(
        count: json['count'],
        next: json['next'],
        previous: json['previous'],
        message: json['message'],
        results: json['results'] != null
            ? List<FreezeFrameResult>.from(json['results'].map((x) => FreezeFrameResult.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        'count': count,
        'next': next,
        'previous': previous,
        'message': message,
        'results': results?.map((x) => x.toJson()).toList(),
      };
}

class FreezeFrameResult {
  int? id;
  String? ffSet;
  bool? isActive;
  List<FreezeFrameCode>? freezeFrameCode;

  FreezeFrameResult({this.id, this.ffSet, this.isActive, this.freezeFrameCode});

  factory FreezeFrameResult.fromJson(Map<String, dynamic> json) => FreezeFrameResult(
        id: json['id'],
        ffSet: json['ff_set'],
        isActive: json['is_active'],
        freezeFrameCode: json['freeze_frame_code'] != null
            ? List<FreezeFrameCode>.from(json['freeze_frame_code'].map((x) => FreezeFrameCode.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'ff_set': ffSet,
        'is_active': isActive,
        'freeze_frame_code': freezeFrameCode?.map((x) => x.toJson()).toList(),
      };
}

class FreezeFrameCode extends ChangeNotifier {
  int? id;
  String? code;
  String? desc;
  int? bytePosition;
  int? priority;
  int? length;
  bool? bitcoded;
  dynamic startBitPosition;
  dynamic endBitPosition;
  double? resolution;
  double? offset;
  String? messageType;
  String? unit;
  String? endian;
  String? numType;
  List<dynamic>? freezframeMessages;

  FreezeFrameCode({
    this.id,
    this.code,
    this.desc,
    this.bytePosition,
    this.priority,
    this.length,
    this.bitcoded,
    this.startBitPosition,
    this.endBitPosition,
    this.resolution,
    this.offset,
    this.messageType,
    this.unit,
    this.endian,
    this.numType,
    this.freezframeMessages,
  });

  factory FreezeFrameCode.fromJson(Map<String, dynamic> json) => FreezeFrameCode(
        id: json['id'],
        code: json['code'],
        desc: json['desc'],
        bytePosition: json['byte_position'],
        priority: json['priority'],
        length: json['length'],
        bitcoded: json['bitcoded'],
        startBitPosition: json['start_bit_position'],
        endBitPosition: json['end_bit_position'],
        resolution: (json['resolution'] != null) ? json['resolution'].toDouble() : null,
        offset: (json['offset'] != null) ? json['offset'].toDouble() : null,
        messageType: json['message_type'],
        unit: json['unit'],
        endian: json['endian'],
        numType: json['num_type'],
        freezframeMessages: json['freezframe_messages'] ?? [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'desc': desc,
        'byte_position': bytePosition,
        'priority': priority,
        'length': length,
        'bitcoded': bitcoded,
        'start_bit_position': startBitPosition,
        'end_bit_position': endBitPosition,
        'resolution': resolution,
        'offset': offset,
        'message_type': messageType,
        'unit': unit,
        'endian': endian,
        'num_type': numType,
        'freezframe_messages': freezframeMessages,
      };
}

class FreezeFrameUIModel extends ChangeNotifier {
  int? id;
  String? code;
  String? desc;
  String? unit;
  int? priority;

  String? _value;
  String? get value => _value;
  set value(String? val) {
    _value = val;
    notifyListeners();
  }

  FreezeFrameUIModel({this.id, this.code, this.desc, this.unit, this.priority, String? value}) {
    _value = value;
  }

  factory FreezeFrameUIModel.fromJson(Map<String, dynamic> json) => FreezeFrameUIModel(
        id: json['id'],
        code: json['code'],
        desc: json['desc'],
        unit: json['unit'],
        priority: json['priority'],
        value: json['value'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'desc': desc,
        'unit': unit,
        'priority': priority,
        'value': _value,
      };
}

class FreezeFrameResponseModel {
  String? status;
  List<FreezeFrame>? dtcs;
  int? noOfDtc;

  FreezeFrameResponseModel({this.status, this.dtcs, this.noOfDtc});

  factory FreezeFrameResponseModel.fromJson(Map<String, dynamic> json) => FreezeFrameResponseModel(
        status: json['status'],
        dtcs: json['dtcs'] != null
            ? List<FreezeFrame>.from(json['dtcs'].map((x) => FreezeFrame.fromJson(x)))
            : [],
        noOfDtc: json['noofdtc'],
      );

  Map<String, dynamic> toJson() => {
        'status': status,
        'dtcs': dtcs?.map((x) => x.toJson()).toList(),
        'noofdtc': noOfDtc,
      };
}

class FreezeFrame {
  String? code;
  int? priority;
  String? value;

  FreezeFrame({this.code, this.priority, this.value});

  factory FreezeFrame.fromJson(Map<String, dynamic> json) => FreezeFrame(
        code: json['code'],
        priority: json['priority'],
        value: json['value'],
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'priority': priority,
        'value': value,
      };
}

class FreezeFrameAnalyzeResult {
  String? code;
  String? pidName;
  String? value;

  FreezeFrameAnalyzeResult({this.code, this.pidName, this.value});

  factory FreezeFrameAnalyzeResult.fromJson(Map<String, dynamic> json) => FreezeFrameAnalyzeResult(
        code: json['code'],
        pidName: json['pid_name'],
        value: json['value'],
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'pid_name': pidName,
        'value': value,
      };
}

class FreezeFrameAnalyze {
  List<FreezeFrameAnalyzeResult>? freezeFrame;

  FreezeFrameAnalyze({this.freezeFrame});

  factory FreezeFrameAnalyze.fromJson(Map<String, dynamic> json) => FreezeFrameAnalyze(
        freezeFrame: json['freeze_frame'] != null
            ? List<FreezeFrameAnalyzeResult>.from(json['freeze_frame'].map((x) => FreezeFrameAnalyzeResult.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        'freeze_frame': freezeFrame?.map((x) => x.toJson()).toList(),
      };
}

class FreezeFrameAnalyzeResponse {
  int? id;
  int? session;
  String? pidName;
  String? value;
  DateTime? created;
  DateTime? modified;
  String? message;

  FreezeFrameAnalyzeResponse({this.id, this.session, this.pidName, this.value, this.created, this.modified, this.message});

  factory FreezeFrameAnalyzeResponse.fromJson(Map<String, dynamic> json) => FreezeFrameAnalyzeResponse(
        id: json['id'],
        session: json['session'],
        pidName: json['pid_name'],
        value: json['value'],
        created: json['created'] != null ? DateTime.parse(json['created']) : null,
        modified: json['modified'] != null ? DateTime.parse(json['modified']) : null,
        message: json['message'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'session': session,
        'pid_name': pidName,
        'value': value,
        'created': created?.toIso8601String(),
        'modified': modified?.toIso8601String(),
        'message': message,
      };
}