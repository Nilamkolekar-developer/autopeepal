

class FirmwareUpdateModel {
  int? count;
  dynamic next;
  dynamic previous;
  String? message;
  List<FirmwareUpdateResultModel>? results;

  FirmwareUpdateModel({
    this.count,
    this.next,
    this.previous,
    this.message,
    this.results,
  });

  factory FirmwareUpdateModel.fromJson(Map<String, dynamic> json) => FirmwareUpdateModel(
        count: json['count'],
        next: json['next'],
        previous: json['previous'],
        message: json['message'],
        results: json['results'] != null
            ? List<FirmwareUpdateResultModel>.from(
                json['results'].map((x) => FirmwareUpdateResultModel.fromJson(x)))
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

class FirmwareUpdateResponseModel {
  String? error;
  bool? success;
  FirmwareData? data;

  FirmwareUpdateResponseModel({this.error, this.success, this.data});

  // From JSON
  factory FirmwareUpdateResponseModel.fromJson(Map<String, dynamic> json) {
    return FirmwareUpdateResponseModel(
      error: json['error'] as String?,
      success: json['success'] as bool?,
      data: json['data'] != null
          ? FirmwareData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'success': success,
      'data': data?.toJson(),
    };
  }
}

class FirmwareData {
  int? id;
  DateTime? created;
  DateTime? modified;
  String? deviceType;
  String? fotaxVersion;
  String? fotaxFirmware;
  String? features;
  String? bugFixes;
  bool? isActive;
  bool? isLatest;

  FirmwareData({
    this.id,
    this.created,
    this.modified,
    this.deviceType,
    this.fotaxVersion,
    this.fotaxFirmware,
    this.features,
    this.bugFixes,
    this.isActive,
    this.isLatest,
  });

  factory FirmwareData.fromJson(Map<String, dynamic> json) {
    return FirmwareData(
      id: json['id'] as int?,
      created: json['created'] != null
          ? DateTime.parse(json['created'] as String)
          : null,
      modified: json['modified'] != null
          ? DateTime.parse(json['modified'] as String)
          : null,
      deviceType: json['device_type'] as String?,
      fotaxVersion: json['fotax_version'] as String?,
      fotaxFirmware: json['fotax_firmware'] as String?,
      features: json['features'] as String?,
      bugFixes: json['bug_fixes'] as String?,
      isActive: json['is_active'] as bool?,
      isLatest: json['is_latest'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created': created?.toIso8601String(),
      'modified': modified?.toIso8601String(),
      'device_type': deviceType,
      'fotax_version': fotaxVersion,
      'fotax_firmware': fotaxFirmware,
      'features': features,
      'bug_fixes': bugFixes,
      'is_active': isActive,
      'is_latest': isLatest,
    };
  }
}

class FirmwareUpdateResultModel {
  String? id;
  PartNo? partNo;
  String? org;
  String? desc;
  String? comms;
  String? ssid;
  String? userSsid;
  String? userPw;
  String? printEnable;
  String? printName;
  dynamic loginUrl;
  String? latest;
  List<FirmwareManagerPartition>? firmwareManagerPartition;
  bool? isActive;

  FirmwareUpdateResultModel({
    this.id,
    this.partNo,
    this.org,
    this.desc,
    this.comms,
    this.ssid,
    this.userSsid,
    this.userPw,
    this.printEnable,
    this.printName,
    this.loginUrl,
    this.latest,
    this.firmwareManagerPartition,
    this.isActive,
  });

  factory FirmwareUpdateResultModel.fromJson(Map<String, dynamic> json) =>
      FirmwareUpdateResultModel(
        id: json['id'],
        partNo: json['part_no'] != null ? PartNo.fromJson(json['part_no']) : null,
        org: json['org'],
        desc: json['desc'],
        comms: json['comms'],
        ssid: json['ssid'],
        userSsid: json['user_ssid'],
        userPw: json['user_pw'],
        printEnable: json['print_enable'],
        printName: json['print_name'],
        loginUrl: json['login_url'],
        latest: json['latest'],
        firmwareManagerPartition: json['firmwaremanager_partition'] != null
            ? List<FirmwareManagerPartition>.from(
                json['firmwaremanager_partition']
                    .map((x) => FirmwareManagerPartition.fromJson(x)))
            : [],
        isActive: json['is_active'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'part_no': partNo?.toJson(),
        'org': org,
        'desc': desc,
        'comms': comms,
        'ssid': ssid,
        'user_ssid': userSsid,
        'user_pw': userPw,
        'print_enable': printEnable,
        'print_name': printName,
        'login_url': loginUrl,
        'latest': latest,
        'firmwaremanager_partition':
            firmwareManagerPartition?.map((x) => x.toJson()).toList(),
        'is_active': isActive,
      };
}

class PartNo {
  String? id;
  String? partNumber;

  PartNo({this.id, this.partNumber});

  factory PartNo.fromJson(Map<String, dynamic> json) =>
      PartNo(id: json['id'], partNumber: json['part_number']);

  Map<String, dynamic> toJson() => {
        'id': id,
        'part_number': partNumber,
      };
}

class FirmwareManagerPartition {
  String? id;
  String? partitionName;
  String? firmware;
  String? startAddr;
  dynamic endAddr;
  String? version;
  String? priority;
  bool? isActive;

  FirmwareManagerPartition({
    this.id,
    this.partitionName,
    this.firmware,
    this.startAddr,
    this.endAddr,
    this.version,
    this.priority,
    this.isActive,
  });

  factory FirmwareManagerPartition.fromJson(Map<String, dynamic> json) =>
      FirmwareManagerPartition(
        id: json['id'],
        partitionName: json['partition_name'],
        firmware: json['firmware'],
        startAddr: json['start_addr'],
        endAddr: json['end_addr'],
        version: json['version'],
        priority: json['priority'],
        isActive: json['is_active'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'partition_name': partitionName,
        'firmware': firmware,
        'start_addr': startAddr,
        'end_addr': endAddr,
        'version': version,
        'priority': priority,
        'is_active': isActive,
      };
}