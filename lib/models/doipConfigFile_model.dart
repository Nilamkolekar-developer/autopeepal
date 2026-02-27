class DoipConfigRootModel {
  int? count;
  dynamic next;
  dynamic previous;
  List<DoipConfigModel>? results;
  String? message;

  DoipConfigRootModel({
    this.count,
    this.next,
    this.previous,
    this.results,
    this.message,
  });

  factory DoipConfigRootModel.fromJson(Map<String, dynamic> json) => DoipConfigRootModel(
        count: json['count'],
        next: json['next'],
        previous: json['previous'],
        message: json['message'],
        results: json['results'] != null
            ? List<DoipConfigModel>.from(
                json['results'].map((x) => DoipConfigModel.fromJson(x)))
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

class DoipConfigModel {
  int? id;
  int? oem;
  int? vehicleModel;
  int? subModel;
  int? modelYear;
  int? ecu;
  String? staticIp;
  String? subnetMask;
  String? getwayIp;
  String? ecuIp;
  bool? isActive;

  DoipConfigModel({
    this.id,
    this.oem,
    this.vehicleModel,
    this.subModel,
    this.modelYear,
    this.ecu,
    this.staticIp,
    this.subnetMask,
    this.getwayIp,
    this.ecuIp,
    this.isActive,
  });

  factory DoipConfigModel.fromJson(Map<String, dynamic> json) => DoipConfigModel(
        id: json['id'],
        oem: json['oem'],
        vehicleModel: json['vehicle_model'],
        subModel: json['sub_model'],
        modelYear: json['model_year'],
        ecu: json['ecu'],
        staticIp: json['static_ip'],
        subnetMask: json['subnet_mask'],
        getwayIp: json['getway_ip'],
        ecuIp: json['ecu_ip'],
        isActive: json['is_active'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'oem': oem,
        'vehicle_model': vehicleModel,
        'sub_model': subModel,
        'model_year': modelYear,
        'ecu': ecu,
        'static_ip': staticIp,
        'subnet_mask': subnetMask,
        'getway_ip': getwayIp,
        'ecu_ip': ecuIp,
        'is_active': isActive,
      };
}