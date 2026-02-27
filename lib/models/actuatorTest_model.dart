class ActuatorTestModel {
  int? count;
  dynamic next;
  dynamic previous;
  List<ActuatorTestResult>? results;
  String? message;

  ActuatorTestModel({this.count, this.next, this.previous, this.results, this.message});

  factory ActuatorTestModel.fromJson(Map<String, dynamic> json) => ActuatorTestModel(
        count: json['count'],
        next: json['next'],
        previous: json['previous'],
        message: json['message'],
        results: json['results'] != null
            ? List<ActuatorTestResult>.from(
                json['results'].map((x) => ActuatorTestResult.fromJson(x)))
            : null,
      );

  Map<String, dynamic> toJson() => {
        'count': count,
        'next': next,
        'previous': previous,
        'message': message,
        'results': results != null
            ? results!.map((x) => x.toJson()).toList()
            : null,
      };
}

class ActuatorTestResult {
  int? id;
  String? actuatorName;
  int? oem;
  int? vehicleModel;
  int? subModel;
  int? modelYear;
  int? ecu;
  String? startTest;
  String? stopTest;
  String? returnControl;
  String? type;
  String? startTestTime;
  String? stopTestTime;
  String? iterations;
  String? isActive;
  List<ActuatorPid>? actuatorPid;

  ActuatorTestResult({
    this.id,
    this.actuatorName,
    this.oem,
    this.vehicleModel,
    this.subModel,
    this.modelYear,
    this.ecu,
    this.startTest,
    this.stopTest,
    this.returnControl,
    this.type,
    this.startTestTime,
    this.stopTestTime,
    this.iterations,
    this.isActive,
    this.actuatorPid,
  });

  factory ActuatorTestResult.fromJson(Map<String, dynamic> json) => ActuatorTestResult(
        id: json['id'],
        actuatorName: json['actuator_name'],
        oem: json['oem'],
        vehicleModel: json['vehicle_model'],
        subModel: json['sub_model'],
        modelYear: json['model_year'],
        ecu: json['ecu'],
        startTest: json['start_test'],
        stopTest: json['stop_test'],
        returnControl: json['return_control'],
        type: json['type'],
        startTestTime: json['start_test_time'],
        stopTestTime: json['stop_test_time'],
        iterations: json['iterations'],
        isActive: json['is_active'],
        actuatorPid: json['actuator_pid'] != null
            ? List<ActuatorPid>.from(
                json['actuator_pid'].map((x) => ActuatorPid.fromJson(x)))
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'actuator_name': actuatorName,
        'oem': oem,
        'vehicle_model': vehicleModel,
        'sub_model': subModel,
        'model_year': modelYear,
        'ecu': ecu,
        'start_test': startTest,
        'stop_test': stopTest,
        'return_control': returnControl,
        'type': type,
        'start_test_time': startTestTime,
        'stop_test_time': stopTestTime,
        'iterations': iterations,
        'is_active': isActive,
        'actuator_pid':
            actuatorPid != null ? actuatorPid!.map((x) => x.toJson()).toList() : null,
      };
}

class ActuatorPid {
  int? id;
  String? type;
  String? cat;
  int? pid;
  String? description;
  String? lowerLimit;
  String? upperLimit;
  String? isActive;
  String? currentValue;
  bool? isCheck;
  String? unit;

  ActuatorPid({
    this.id,
    this.type,
    this.cat,
    this.pid,
    this.description,
    this.lowerLimit,
    this.upperLimit,
    this.isActive,
    this.currentValue,
    this.isCheck,
    this.unit,
  });

  factory ActuatorPid.fromJson(Map<String, dynamic> json) => ActuatorPid(
        id: json['id'],
        type: json['type'],
        cat: json['cat'],
        pid: json['pid'],
        description: json['description'],
        lowerLimit: json['lower_limit'],
        upperLimit: json['upper_limit'],
        isActive: json['is_active'],
        currentValue: json['current_value'],
        isCheck: json['is_check'],
        unit: json['unit'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'cat': cat,
        'pid': pid,
        'description': description,
        'lower_limit': lowerLimit,
        'upper_limit': upperLimit,
        'is_active': isActive,
        'current_value': currentValue,
        'is_check': isCheck,
        'unit': unit,
      };
}