import 'package:autopeepal/models/all_models.dart';
import 'package:flutter/material.dart';

class LiveParameterSelectModel {
  String? ecuName;
  List<PidCode>? roots;

  LiveParameterSelectModel({this.ecuName, this.roots});

  factory LiveParameterSelectModel.fromJson(Map<String, dynamic> json) =>
      LiveParameterSelectModel(
        ecuName: json['ecu_name'],
        roots: json['roots'] != null
            ? List<PidCode>.from(json['roots'].map((x) => PidCode.fromJson(x)))
            : null,
      );

  Map<String, dynamic> toJson() => {
        'ecu_name': ecuName,
        'roots': roots?.map((x) => x.toJson()).toList(),
      };
}

class PidCode {
  int? id;
  String? code;
  String? shortName;
  int? priority;
  bool? read;
  bool? write;
  String? writePid;
  bool? reset;
  int? totalLen;
  String? resetValue;
  bool? ioCtrl;
  String? ioCtrlPid;
  bool? isActive;
  bool? memoryAddress;
  bool? freezFrame;
  bool? routineTest;
  bool? ecuParameter;
  bool? isStatic;
  String? header;
  List<PiCodeVariable>? piCodeVariable;

  PidCode({
    this.id,
    this.code,
    this.shortName,
    this.priority,
    this.read,
    this.write,
    this.writePid,
    this.reset,
    this.totalLen,
    this.resetValue,
    this.ioCtrl,
    this.ioCtrlPid,
    this.isActive,
    this.memoryAddress,
    this.freezFrame,
    this.routineTest,
    this.ecuParameter,
    this.isStatic,
    this.header,
    this.piCodeVariable,
  });

  factory PidCode.fromJson(Map<String, dynamic> json) => PidCode(
        id: json['id'],
        code: json['code'],
        shortName: json['short_name'],
        priority: json['priority'],
        read: json['read'],
        write: json['write'],
        writePid: json['write_pid'],
        reset: json['reset'],
        totalLen: json['total_len'],
        resetValue: json['reset_value'],
        ioCtrl: json['io_ctrl'],
        ioCtrlPid: json['io_ctrl_pid'],
        isActive: json['is_active'],
        memoryAddress: json['memory_address'],
        freezFrame: json['freez_frame'],
        routineTest: json['routine_test'],
        ecuParameter: json['ecu_parameter'],
        isStatic: json['is_static'],
        header: json['Header'],
        piCodeVariable: json['pi_code_variable'] != null
            ? List<PiCodeVariable>.from(
                json['pi_code_variable'].map((x) => PiCodeVariable.fromJson(x)))
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'short_name': shortName,
        'priority': priority,
        'read': read,
        'write': write,
        'write_pid': writePid,
        'reset': reset,
        'total_len': totalLen,
        'reset_value': resetValue,
        'io_ctrl': ioCtrl,
        'io_ctrl_pid': ioCtrlPid,
        'is_active': isActive,
        'memory_address': memoryAddress,
        'freez_frame': freezFrame,
        'routine_test': routineTest,
        'ecu_parameter': ecuParameter,
        'is_static': isStatic,
        'Header': header,
        'pi_code_variable': piCodeVariable?.map((x) => x.toJson()).toList(),
      };
}

class PiCodeVariable {
  int? id;
  String? shortName;
  bool? selected;
  String? longName;
  int? bytePosition;
  int? length;
  bool? bitcoded;
  int? startBitPosition;
  int? endBitPosition;
  double? resolution;
  double? offset;
  double? min;
  double? max;
  String? messageType;
  String? unit;

  PiCodeVariable({
    this.id,
    this.shortName,
    this.selected,
    this.longName,
    this.bytePosition,
    this.length,
    this.bitcoded,
    this.startBitPosition,
    this.endBitPosition,
    this.resolution,
    this.offset,
    this.min,
    this.max,
    this.messageType,
    this.unit,
  });

  factory PiCodeVariable.fromJson(Map<String, dynamic> json) => PiCodeVariable(
        id: json['id'],
        shortName: json['short_name'],
        selected: json['selected'] ?? false,
        longName: json['long_name'],
        bytePosition: json['byte_position'],
        length: json['length'],
        bitcoded: json['bitcoded'],
        startBitPosition: json['start_bit_position'],
        endBitPosition: json['end_bit_position'],
        resolution: (json['resolution'] as num?)?.toDouble(),
        offset: (json['offset'] as num?)?.toDouble(),
        min: (json['min'] as num?)?.toDouble(),
        max: (json['max'] as num?)?.toDouble(),
        messageType: json['message_type'],
        unit: json['unit'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'short_name': shortName,
        'selected': selected,
        'long_name': longName,
        'byte_position': bytePosition,
        'length': length,
        'bitcoded': bitcoded,
        'start_bit_position': startBitPosition,
        'end_bit_position': endBitPosition,
        'resolution': resolution,
        'offset': offset,
        'min': min,
        'max': max,
        'message_type': messageType,
        'unit': unit,
      };
}
class PIDModel {
  int? count;
  dynamic next;
  dynamic previous;
  List<PIDResult>? results;
  String? message;

  PIDModel({this.count, this.next, this.previous, this.results, this.message});

  // From JSON
  factory PIDModel.fromJson(Map<String, dynamic> json) => PIDModel(
        count: json['count'],
        next: json['next'],
        previous: json['previous'],
        results: json['results'] != null
            ? List<PIDResult>.from(
                json['results'].map((x) => PIDResult.fromJson(x)))
            : null,
        message: json['message'],
      );

  // To JSON
  Map<String, dynamic> toJson() => {
        'count': count,
        'next': next,
        'previous': previous,
        'results': results?.map((x) => x.toJson()).toList(),
        'message': message,
      };
}

class PIDResult {
  int? id;
  String? code;
  String? description;
  List<PIDFrameDataset>? frameDatasets;

  PIDResult({this.id, this.code, this.description, this.frameDatasets});

  factory PIDResult.fromJson(Map<String, dynamic> json) => PIDResult(
        id: json['id'],
        code: json['code'],
        description: json['description'],
        frameDatasets: json['frame_datasets'] != null
            ? List<PIDFrameDataset>.from(
                json['frame_datasets'].map((x) => PIDFrameDataset.fromJson(x)))
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'description': description,
        'frame_datasets': frameDatasets?.map((x) => x.toJson()).toList(),
      };
}

class PIDFrameDataset {
  int? id;
  String? frameName;
  String? frameId;
  List<PIDFrameId>? frameIds;

  PIDFrameDataset({this.id, this.frameName, this.frameId, this.frameIds});

  factory PIDFrameDataset.fromJson(Map<String, dynamic> json) => PIDFrameDataset(
        id: json['id'],
        frameName: json['frame_name'],
        frameId: json['frame_id'],
        frameIds: json['frame_ids'] != null
            ? List<PIDFrameId>.from(
                json['frame_ids'].map((x) => PIDFrameId.fromJson(x)))
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'frame_name': frameName,
        'frame_id': frameId,
        'frame_ids': frameIds?.map((x) => x.toJson()).toList(),
      };
}

class PIDFrameId {
  String? pidDescription;
  String? startByte;
  int? startByteVal;
  String? byteValue;
  int? byteLen;
  String? bitCoded;
  String? startBit;
  int? startBitVal;
  String? noOfBits;
  int? noOfBitsVal;
  String? resolution;
  double? resolutionVal;
  String? offset;
  double? offsetVal;
  String? unit;
  String? messageType;
  bool? selected;

  PIDFrameId({
    this.pidDescription,
    this.startByte,
    this.startByteVal,
    this.byteValue,
    this.byteLen,
    this.bitCoded,
    this.startBit,
    this.startBitVal,
    this.noOfBits,
    this.noOfBitsVal,
    this.resolution,
    this.resolutionVal,
    this.offset,
    this.offsetVal,
    this.unit,
    this.messageType,
    this.selected = false,
  });

  factory PIDFrameId.fromJson(Map<String, dynamic> json) => PIDFrameId(
        pidDescription: json['pid_description'],
        startByte: json['start_byte'],
        startByteVal: json['startByteVal'],
        byteValue: json['byte'],
        byteLen: json['byteLen'],
        bitCoded: json['bit_coded'],
        startBit: json['start_bit'],
        startBitVal: json['startBitVal'],
        noOfBits: json['no_of_bits'],
        noOfBitsVal: json['noOfBitsVal'],
        resolution: json['resolution'],
        resolutionVal: (json['resolutionVal'] as num?)?.toDouble(),
        offset: json['offset'],
        offsetVal: (json['offsetVal'] as num?)?.toDouble(),
        unit: json['unit'],
        messageType: json['message_type'],
        selected: json['Selected'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'pid_description': pidDescription,
        'start_byte': startByte,
        'startByteVal': startByteVal,
        'byte': byteValue,
        'byteLen': byteLen,
        'bit_coded': bitCoded,
        'start_bit': startBit,
        'startBitVal': startBitVal,
        'no_of_bits': noOfBits,
        'noOfBitsVal': noOfBitsVal,
        'resolution': resolution,
        'resolutionVal': resolutionVal,
        'offset': offset,
        'offsetVal': offsetVal,
        'unit': unit,
        'message_type': messageType,
        'Selected': selected,
      };
}


class FrameOfPidMessage {
  String? code;
  String? message;

  FrameOfPidMessage({this.code, this.message});

  factory FrameOfPidMessage.fromJson(Map<String, dynamic> json) => FrameOfPidMessage(
        code: json['code'],
        message: json['message'],
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'message': message,
      };
}

class EcusModel {
  String? ecuName;
  ValueNotifier<double> opacity;
  List<PidCode> pidList;
  String? txHeader;
  String? rxHeader;
  Protocol? protocol;
  String? firingSequence;
  int? noOfInjectors;

  EcusModel({
    this.ecuName,
    double? opacity,
    List<PidCode>? pidList,
    this.txHeader,
    this.rxHeader,
    this.protocol,
    this.firingSequence,
    this.noOfInjectors,
  })  : opacity = ValueNotifier<double>(opacity ?? 1.0),
        pidList = pidList ?? [];

  factory EcusModel.fromJson(Map<String, dynamic> json) => EcusModel(
        ecuName: json['ecu_name'],
        opacity: (json['opacity'] != null) ? (json['opacity'] as num).toDouble() : 1.0,
        pidList: (json['pid_list'] as List<dynamic>?)
                ?.map((e) => PidCode.fromJson(e))
                .toList() ??
            [],
        txHeader: json['tx_header'],
        rxHeader: json['rx_header'],
        protocol: json['protocol'] != null ? Protocol.fromJson(json['protocol']) : null,
        firingSequence: json['firing_sequence'],
        noOfInjectors: json['no_of_injectors'],
      );

  Map<String, dynamic> toJson() => {
        'ecu_name': ecuName,
        'opacity': opacity.value,
        'pid_list': pidList.map((e) => e.toJson()).toList(),
        'tx_header': txHeader,
        'rx_header': rxHeader,
        'protocol': protocol?.toJson(),
        'firing_sequence': firingSequence,
        'no_of_injectors': noOfInjectors,
      };
}

class IvnEcusModel {
  String? ecuName;
  ValueNotifier<double> opacity;
  List<PIDFrameId> pidList;

  IvnEcusModel({
    this.ecuName,
    double? opacity,
    List<PIDFrameId>? pidList,
  })  : opacity = ValueNotifier<double>(opacity ?? 1.0),
        pidList = pidList ?? [];

  factory IvnEcusModel.fromJson(Map<String, dynamic> json) => IvnEcusModel(
        ecuName: json['ecu_name'],
        opacity: (json['opacity'] != null) ? (json['opacity'] as num).toDouble() : 1.0,
        pidList: (json['pid_list'] as List<dynamic>?)
                ?.map((e) => PIDFrameId.fromJson(e))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'ecu_name': ecuName,
        'opacity': opacity.value,
        'pid_list': pidList.map((e) => e.toJson()).toList(),
      };
}

class Root {
  int? count;
  dynamic next;
  dynamic previous;
  List<Results>? results;
  String? message;

  Root({
    this.count,
    this.next,
    this.previous,
    this.results,
    this.message,
  });

  /// 🔽 JSON → Object
  factory Root.fromJson(Map<String, dynamic> json) {
    return Root(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: json['results'] != null
          ? (json['results'] as List)
              .map((e) => Results.fromJson(e))
              .toList()
          : [],
    );
  }

  /// 🔼 Object → JSON
  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'next': next,
      'previous': previous,
      'results': results?.map((e) => e.toJson()).toList(),
    };
  }
}
class Results {
  int? id;
  String? code;
  String? description;
  List<PidCode>? codes;

  Results({
    this.id,
    this.code,
    this.description,
    this.codes,
  });

  /// 🔽 JSON → Object
  factory Results.fromJson(Map<String, dynamic> json) {
    return Results(
      id: json['id'],
      code: json['code'],
      description: json['description'],
      codes: json['codes'] != null
          ? (json['codes'] as List)
              .map((e) => PidCode.fromJson(e))
              .toList()
          : [],
    );
  }

  /// 🔼 Object → JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'description': description,
      'codes': codes?.map((e) => e.toJson()).toList(),
    };
  }
}
class PidGroupModel extends ChangeNotifier {
  int id;

  String _groupName = '';

  String get groupName => _groupName;

  set groupName(String value) {
    _groupName = value;
    notifyListeners(); // == OnPropertyChanged("GroupName")
  }

  PidGroupModel({
    required this.id,
    String groupName = '',
  }) {
    _groupName = groupName;
  }
}

class Variables {
  // Define the fields of your Variables class here
  // Example:
  String? name;
  String? value;

  Variables({this.name, this.value});

  factory Variables.fromJson(Map<String, dynamic> json) {
    return Variables(
      name: json['name'] as String?,
      value: json['value'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'value': value,
      };
}

class ReadPidPresponseModel {
  String? status;
  String? dataArray;
  int? pidId;
  String? pidName;
  String? responseValue;
  String? unit;
  List<Variables>? variables;

  ReadPidPresponseModel({
    this.status,
    this.dataArray,
    this.pidId,
    this.pidName,
    this.responseValue,
    this.unit,
    this.variables,
  });

  factory ReadPidPresponseModel.fromJson(Map<String, dynamic> json) {
    return ReadPidPresponseModel(
      status: json['Status'] as String?,
      dataArray: json['DataArray'] as String?,
      pidId: json['pid_id'] as int?,
      pidName: json['pid_name'] as String?,
      responseValue: json['responseValue'] as String?,
      unit: json['unit'] as String?,
      variables: json['Variables'] != null
          ? List<Variables>.from(
              (json['Variables'] as List).map((x) => Variables.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'Status': status,
        'DataArray': dataArray,
        'pid_id': pidId,
        'pid_name': pidName,
        'responseValue': responseValue,
        'unit': unit,
        'Variables': variables?.map((x) => x.toJson()).toList(),
      };
}