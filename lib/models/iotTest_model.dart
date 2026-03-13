import 'package:autopeepal/models/ecu_model.dart';
import 'package:flutter/material.dart';

class IorTestModel {
  int? count;
  dynamic next;
  dynamic previous;
  String? error;
  String? message;
  List<IorResult>? results;

  IorTestModel({
     this.count,
    this.next,
    this.previous,
    this.error,
    this.message,
     this.results,
  });

  factory IorTestModel.fromJson(Map<String, dynamic> json) => IorTestModel(
        count: json['count'],
        next: json['next'],
        previous: json['previous'],
        error: json['error'],
        message: json['message'],
        results: (json['results'] as List<dynamic>)
            .map((e) => IorResult.fromJson(e))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'count': count,
        'next': next,
        'previous': previous,
        'error': error,
        'message': message,
        'results': results!.map((e) => e.toJson()).toList(),
      };
}

class IorResult {
  String? id;
  String? routineName;
  String? notice;
  String? vehicleModel;
  int? subModel;
  String? modelYear;
  EcuModel? ecu;
  String? status;
  List<PreCondition> preConditions;
  List<IorTestRoutine> iorTestRoutine;
  IorTestRoutineType? iorTestRoutineType;
  List<TestMonitor> testMonitors;
  List<TestIo> testIo;

  IorResult({
    this.id,
    this.routineName,
    this.notice,
    this.vehicleModel,
    this.subModel,
    this.modelYear,
    this.ecu,
    this.status,
    required this.preConditions,
    required this.iorTestRoutine,
    this.iorTestRoutineType,
    required this.testMonitors,
    required this.testIo,
  });

  factory IorResult.fromJson(Map<String, dynamic> json) => IorResult(
        id: json['id'],
        routineName: json['routine_name'],
        notice: json['notice'],
        vehicleModel: json['vehicle_model'],
        subModel: json['sub_model'],
        modelYear: json['model_year'],
        ecu: json['ecu'] != null ? EcuModel.fromJson(json['ecu']) : null,
        status: json['status'],
        preConditions: (json['pre_conditions'] as List<dynamic>?)
                ?.map((e) => PreCondition.fromJson(e))
                .toList() ??
            [],
        iorTestRoutine: (json['ior_test_routine'] as List<dynamic>?)
                ?.map((e) => IorTestRoutine.fromJson(e))
                .toList() ??
            [],
        iorTestRoutineType: json['ior_test_routine_type'] != null
            ? IorTestRoutineType.fromJson(json['ior_test_routine_type'])
            : null,
        testMonitors: (json['test_monitors'] as List<dynamic>?)
                ?.map((e) => TestMonitor.fromJson(e))
                .toList() ??
            [],
        testIo: (json['test_io'] as List<dynamic>?)
                ?.map((e) => TestIo.fromJson(e))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'routine_name': routineName,
        'notice': notice,
        'vehicle_model': vehicleModel,
        'sub_model': subModel,
        'model_year': modelYear,
        'ecu': ecu?.toJson(),
        'status': status,
        'pre_conditions': preConditions.map((e) => e.toJson()).toList(),
        'ior_test_routine': iorTestRoutine.map((e) => e.toJson()).toList(),
        'ior_test_routine_type': iorTestRoutineType?.toJson(),
        'test_monitors': testMonitors.map((e) => e.toJson()).toList(),
        'test_io': testIo.map((e) => e.toJson()).toList(),
      };
}

// ----------------------------- Sub Models -----------------------------

class TestIo {
  int id;
  String? type;
  int? pid;
  String? checkOutputSignals;
  String? calculation;
  String? event;
  String? variableName;
  int startByte;
  int length;
  bool bitcoded;
  dynamic noOfBit;
  dynamic startBitPosition;
  double resolution;
  double offset;
  double? min;
  double? max;
  String? messageType;
  String? enumValue;
  String? enumDesc;
  bool isActive;
  String? unit;

  // Reactive properties
  ValueNotifier<String> showResolution = ValueNotifier('');
  ValueNotifier<String> inputValue = ValueNotifier('');

  TestIo({
    required this.id,
    this.type,
    this.pid,
    this.checkOutputSignals,
    this.calculation,
    this.event,
    this.variableName,
    required this.startByte,
    required this.length,
    required this.bitcoded,
    this.noOfBit,
    this.startBitPosition,
    required this.resolution,
    required this.offset,
    this.min,
    this.max,
    this.messageType,
    this.enumValue,
    this.enumDesc,
    required this.isActive,
    this.unit,
  });

  factory TestIo.fromJson(Map<String, dynamic> json) => TestIo(
        id: json['id'],
        type: json['type'],
        pid: json['pid'],
        checkOutputSignals: json['checkoutput_singnals'],
        calculation: json['calculation'],
        event: json['event'],
        variableName: json['variable_name'],
        startByte: json['start_byte'] ?? 0,
        length: json['length'] ?? 0,
        bitcoded: json['bitcoded'] ?? false,
        noOfBit: json['no_of_bit'],
        startBitPosition: json['start_bit_position'],
        resolution: (json['resolution'] ?? 0).toDouble(),
        offset: (json['offset'] ?? 0).toDouble(),
        min: (json['min'] != null) ? (json['min'] as num).toDouble() : null,
        max: (json['max'] != null) ? (json['max'] as num).toDouble() : null,
        messageType: json['message_type'],
        enumValue: json['enum_value'],
        enumDesc: json['enum_desc'],
        isActive: json['is_active'] ?? false,
        unit: json['unit'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'pid': pid,
        'checkoutput_singnals': checkOutputSignals,
        'calculation': calculation,
        'event': event,
        'variable_name': variableName,
        'start_byte': startByte,
        'length': length,
        'bitcoded': bitcoded,
        'no_of_bit': noOfBit,
        'start_bit_position': startBitPosition,
        'resolution': resolution,
        'offset': offset,
        'min': min,
        'max': max,
        'message_type': messageType,
        'enum_value': enumValue,
        'enum_desc': enumDesc,
        'is_active': isActive,
        'unit': unit,
      };
}





// ---------------- TestMonitor ----------------
class TestMonitor {
  String? routineId;
  String? id;
  String? testMonitorType;
  int? pid;
  String? description;
  String? lowerLimit;
  String? upperLimit;

  // Reactive properties
  ValueNotifier<String> currentValue = ValueNotifier('');
  ValueNotifier<String> unit = ValueNotifier('');

  TestMonitor({
    this.routineId,
    this.id,
    this.testMonitorType,
    this.pid,
    this.description,
    this.lowerLimit,
    this.upperLimit,
  });

  factory TestMonitor.fromJson(Map<String, dynamic> json) => TestMonitor(
        routineId: json['routine_id'],
        id: json['id'],
        testMonitorType: json['test_monitor_type'],
        pid: json['pid'],
        description: json['description'],
        lowerLimit: json['lower_limit'],
        upperLimit: json['upper_limit'],
      )..currentValue.value = json['current_value'] ?? ''
       ..unit.value = json['unit'] ?? '';

  Map<String, dynamic> toJson() => {
        'routine_id': routineId,
        'id': id,
        'test_monitor_type': testMonitorType,
        'pid': pid,
        'description': description,
        'lower_limit': lowerLimit,
        'upper_limit': upperLimit,
        'current_value': currentValue.value,
        'unit': unit.value,
      };
}

// ---------------- PreCondition ----------------
class PreCondition {
  String? routineId;
  String? id;
  String? preConditionType;
  int? pid;
  String? description;
  String? lowerLimit;
  String? upperLimit;

  ValueNotifier<String> currentValue = ValueNotifier('');
  ValueNotifier<bool> isCheck = ValueNotifier(false);

  PreCondition({
    this.routineId,
    this.id,
    this.preConditionType,
    this.pid,
    this.description,
    this.lowerLimit,
    this.upperLimit,
  });

  factory PreCondition.fromJson(Map<String, dynamic> json) => PreCondition(
        routineId: json['routine_id'],
        id: json['id'],
        preConditionType: json['pre_condition_type'],
        pid: json['pid'],
        description: json['description'],
        lowerLimit: json['lower_limit'],
        upperLimit: json['upper_limit'],
      )..currentValue.value = json['current_value'] ?? ''
       ..isCheck.value = json['is_check'] ?? false;

  Map<String, dynamic> toJson() => {
        'routine_id': routineId,
        'id': id,
        'pre_condition_type': preConditionType,
        'pid': pid,
        'description': description,
        'lower_limit': lowerLimit,
        'upper_limit': upperLimit,
        'current_value': currentValue.value,
        'is_check': isCheck.value,
      };
}

// ---------------- StatusByteDefinition ----------------
class StatusByteDefinition {
  String? routineId;
  String? id;
  String? byte;
  String? byteDefinitions;

  StatusByteDefinition({
    this.routineId,
    this.id,
    this.byte,
    this.byteDefinitions,
  });

  factory StatusByteDefinition.fromJson(Map<String, dynamic> json) =>
      StatusByteDefinition(
        routineId: json['routine_id'],
        id: json['id'],
        byte: json['byte'],
        byteDefinitions: json['byte_definations'],
      );

  Map<String, dynamic> toJson() => {
        'routine_id': routineId,
        'id': id,
        'byte': byte,
        'byte_definations': byteDefinitions,
      };
}

// ---------------- IorTestRoutineType ----------------
class IorTestRoutineType {
  String? id;
  String? testRoutineType;
  bool? sendTesterPresent;
  String? activationTime;
  String? statusByteLoc;
  List<StatusByteDefinition> statusByteDefinition;

  IorTestRoutineType({
    this.id,
    this.testRoutineType,
    this.sendTesterPresent,
    this.activationTime,
    this.statusByteLoc,
    List<StatusByteDefinition>? statusByteDefinition,
  }) : statusByteDefinition = statusByteDefinition ?? [];

  factory IorTestRoutineType.fromJson(Map<String, dynamic> json) =>
      IorTestRoutineType(
        id: json['id'],
        testRoutineType: json['test_routine_type'],
        sendTesterPresent: json['send_tester_present'] ?? false,
        activationTime: json['activation_time'],
        statusByteLoc: json['status_byte_loc'],
        statusByteDefinition: (json['status_byte_definition'] as List<dynamic>?)
                ?.map((e) => StatusByteDefinition.fromJson(e))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'test_routine_type': testRoutineType,
        'send_tester_present': sendTesterPresent,
        'activation_time': activationTime,
        'status_byte_loc': statusByteLoc,
        'status_byte_definition':
            statusByteDefinition.map((e) => e.toJson()).toList(),
      };
}

// ---------------- IorTestRoutine ----------------
class IorTestRoutine {
  String? routineId;
  String? id;
  String? startRoutineId;
  String? reqRoutineId;
  String? stopFollowupRoutineId;
  String? description;
  String? testInstruction;
  bool isPlay;
  int priority;

  // Reactive properties
  ValueNotifier<String> testStatus = ValueNotifier('Stop');
  ValueNotifier<ImageProvider> imageSource =
      ValueNotifier(const AssetImage('assets/ic_play.png'));
  ValueNotifier<bool> btnActivationStatus = ValueNotifier(true);
  ValueNotifier<bool> btnVisible = ValueNotifier(true);
  ValueNotifier<bool> testVisible = ValueNotifier(true);
  ValueNotifier<Color> btnBackgroundColor =
      ValueNotifier(Colors.blue); // set your theme color
  ValueNotifier<bool> descriptionVisible = ValueNotifier(false);

  IorTestRoutine({
    this.routineId,
    this.id,
    this.startRoutineId,
    this.reqRoutineId,
    this.stopFollowupRoutineId,
    this.description,
    this.testInstruction,
    this.isPlay = false,
    this.priority = 0,
  });

  factory IorTestRoutine.fromJson(Map<String, dynamic> json) =>
      IorTestRoutine(
        routineId: json['routine_id'],
        id: json['id'],
        startRoutineId: json['start_routine_id'],
        reqRoutineId: json['req_routine_id'],
        stopFollowupRoutineId: json['stop_followup_routine_id'],
        description: json['description'],
        testInstruction: json['test_instruction'],
        isPlay: json['is_play'] ?? false,
        priority: json['priority'] ?? 0,
      )..testStatus.value = json['test_status'] ?? 'Stop';

  Map<String, dynamic> toJson() => {
        'routine_id': routineId,
        'id': id,
        'start_routine_id': startRoutineId,
        'req_routine_id': reqRoutineId,
        'stop_followup_routine_id': stopFollowupRoutineId,
        'description': description,
        'test_instruction': testInstruction,
        'is_play': isPlay,
        'priority': priority,
        'test_status': testStatus.value,
      };
}
// TestMonitor, PreCondition, IorTestRoutineType, StatusByteDefinition, IorTestRoutine
// can be converted similarly with reactive fields using ValueNotifier for properties that used OnPropertyChanged in C#.