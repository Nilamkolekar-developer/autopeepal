class JobCardModel {
  String? id;
  String? jobCardName;
  String? status;
  String? fertCode;
  String? vehicleSegment;
  VehicleModel? vehicleModel;
  String? chasisId;
  String? registrationNo;
  int? kmCovered;
  String? complaints;
  CreatedBy? createdBy;
  DateTime? created;
  DateTime? modified;
  int? jobCardAge;
  List<JobCardSession>? jobCardSession;

  JobCardModel({
    this.id,
    this.jobCardName,
    this.status,
    this.fertCode,
    this.vehicleSegment,
    this.vehicleModel,
    this.chasisId,
    this.registrationNo,
    this.kmCovered,
    this.complaints,
    this.createdBy,
    this.created,
    this.modified,
    this.jobCardAge,
    this.jobCardSession,
  });

  factory JobCardModel.fromJson(Map<String, dynamic> json) => JobCardModel(
        id: json['id'],
        jobCardName: json['job_card_name'],
        status: json['status'],
        fertCode: json['fert_code'],
        vehicleSegment: json['vehicle_segment'],
        vehicleModel: json['vehicle_model'] != null
            ? VehicleModel.fromJson(json['vehicle_model'])
            : null,
        chasisId: json['chasis_id'],
        registrationNo: json['registration_no'],
        kmCovered: json['km_covered'],
        complaints: json['complaints'],
        createdBy: json['created_by'] != null
            ? CreatedBy.fromJson(json['created_by'])
            : null,
        created:
            json['created'] != null ? DateTime.parse(json['created']) : null,
        modified:
            json['modified'] != null ? DateTime.parse(json['modified']) : null,
        jobCardAge: json['job_card_age'],
        jobCardSession: json['job_card_session'] != null
            ? List<JobCardSession>.from(
                json['job_card_session'].map((x) => JobCardSession.fromJson(x)))
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'job_card_name': jobCardName,
        'status': status,
        'fert_code': fertCode,
        'vehicle_segment': vehicleSegment,
        'vehicle_model': vehicleModel?.toJson(),
        'chasis_id': chasisId,
        'registration_no': registrationNo,
        'km_covered': kmCovered,
        'complaints': complaints,
        'created_by': createdBy?.toJson(),
        'created': created?.toIso8601String(),
        'modified': modified?.toIso8601String(),
        'job_card_age': jobCardAge,
        'job_card_session': jobCardSession?.map((x) => x.toJson()).toList(),
      };
}

class JobCardSession {
  String? id;
  String? sessionId;
  String? jobCard;
  DateTime? startDate;
  String? showStartDate;
  DateTime? endDate;
  dynamic deviceDongle;
  VehicleModel? vehicleModel;
  dynamic device;
  User? user;
  String? source;
  String? sessionType;
  String? status;
  JobCardRemoteSession? jobCardRemoteSession;
  dynamic automatedSession;

  JobCardSession({
    this.id,
    this.sessionId,
    this.jobCard,
    this.startDate,
    this.showStartDate,
    this.endDate,
    this.deviceDongle,
    this.vehicleModel,
    this.device,
    this.user,
    this.source,
    this.sessionType,
    this.status,
    this.jobCardRemoteSession,
    this.automatedSession,
  });

  factory JobCardSession.fromJson(Map<String, dynamic> json) => JobCardSession(
        id: json['id'],
        sessionId: json['session_id'],
        jobCard: json['job_card'],
        startDate: json['start_date'] != null
            ? DateTime.parse(json['start_date'])
            : null,
        showStartDate: json['show_start_date'],
        endDate:
            json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
        deviceDongle: json['device_dongle'],
        vehicleModel: json['vehicle_model'] != null
            ? VehicleModel.fromJson(json['vehicle_model'])
            : null,
        device: json['device'],
        user: json['user'] != null ? User.fromJson(json['user']) : null,
        source: json['source'],
        sessionType: json['session_type'],
        status: json['status'],
        jobCardRemoteSession: json['job_card_remote_session'] != null
            ? JobCardRemoteSession.fromJson(json['job_card_remote_session'])
            : null,
        automatedSession: json['automated_session'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'session_id': sessionId,
        'job_card': jobCard,
        'start_date': startDate?.toIso8601String(),
        'show_start_date': showStartDate,
        'end_date': endDate?.toIso8601String(),
        'device_dongle': deviceDongle,
        'vehicle_model': vehicleModel?.toJson(),
        'device': device,
        'user': user?.toJson(),
        'source': source,
        'session_type': sessionType,
        'status': status,
        'job_card_remote_session': jobCardRemoteSession?.toJson(),
        'automated_session': automatedSession,
      };
}

class User {
  String? email;
  dynamic workshop;
  dynamic role;

  User({this.email, this.workshop, this.role});

  factory User.fromJson(Map<String, dynamic> json) => User(
        email: json['email'],
        workshop: json['workshop'],
        role: json['role'],
      );

  Map<String, dynamic> toJson() => {
        'email': email,
        'workshop': workshop,
        'role': role,
      };
}

class JobCardRemoteSession {
  String? id;
  String? remoteSessionId;
  String? jobCardSession;
  dynamic caseId;
  String? status;
  int? expertUser;
  dynamic expertDevice;
  String? expertEmail;
  bool? requestStatus;

  JobCardRemoteSession({
    this.id,
    this.remoteSessionId,
    this.jobCardSession,
    this.caseId,
    this.status,
    this.expertUser,
    this.expertDevice,
    this.expertEmail,
    this.requestStatus,
  });

  factory JobCardRemoteSession.fromJson(Map<String, dynamic> json) =>
      JobCardRemoteSession(
        id: json['id'],
        remoteSessionId: json['remote_session_id'],
        jobCardSession: json['job_card_session'],
        caseId: json['case_id'],
        status: json['status'],
        expertUser: json['expert_user'],
        expertDevice: json['expert_device'],
        expertEmail: json['expert_email'],
        requestStatus: json['request_status'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'remote_session_id': remoteSessionId,
        'job_card_session': jobCardSession,
        'case_id': caseId,
        'status': status,
        'expert_user': expertUser,
        'expert_device': expertDevice,
        'expert_email': expertEmail,
        'request_status': requestStatus,
      };
}

class VehicleModel {
  int? id;
  String? name;
  Parent? parent;
  String? modelYear;
  List<SubModelClass>? subModels;

  VehicleModel(
      {this.id, this.name, this.parent, this.modelYear, this.subModels});

  factory VehicleModel.fromJson(Map<String, dynamic> json) => VehicleModel(
        id: json['id'],
        name: json['name'],
        parent: json['parent'] != null ? Parent.fromJson(json['parent']) : null,
        modelYear: json['model_year'],
        subModels: json['sub_models'] != null
            ? List<SubModelClass>.from(
                json['sub_models'].map((x) => SubModelClass.fromJson(x)))
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'parent': parent?.toJson(),
        'model_year': modelYear,
        'sub_models': subModels?.map((x) => x.toJson()).toList(),
      };
}

class Parent {
  String? name;
  dynamic parent;
  dynamic modelYear;

  Parent({this.name, this.parent, this.modelYear});

  factory Parent.fromJson(Map<String, dynamic> json) => Parent(
        name: json['name'],
        parent: json['parent'],
        modelYear: json['model_year'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'parent': parent,
        'model_year': modelYear,
      };
}

class SubModelClass {
  int? id;
  String? modelYear;
  String? name;

  SubModelClass({this.id, this.modelYear, this.name});

  factory SubModelClass.fromJson(Map<String, dynamic> json) => SubModelClass(
        id: json['id'],
        modelYear: json['model_year'],
        name: json['name'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'model_year': modelYear,
        'name': name,
      };
}

class CreatedBy {
  String? email;
  UsUser? usUser;

  CreatedBy({this.email, this.usUser});

  factory CreatedBy.fromJson(Map<String, dynamic> json) => CreatedBy(
        email: json['email'],
        usUser:
            json['us_user'] != null ? UsUser.fromJson(json['us_user']) : null,
      );

  Map<String, dynamic> toJson() => {
        'email': email,
        'us_user': usUser?.toJson(),
      };
}

class UsUser {
  int? oem;
  String? role;
  Workshop? workshop;
  bool? status;
  List<dynamic>? runTimeLicenses;

  UsUser(
      {this.oem, this.role, this.workshop, this.status, this.runTimeLicenses});

  factory UsUser.fromJson(Map<String, dynamic> json) => UsUser(
        oem: json['oem'],
        role: json['role'],
        workshop: json['workshop'] != null
            ? Workshop.fromJson(json['workshop'])
            : null,
        status: json['status'],
        runTimeLicenses: json['run_time_licenses'] != null
            ? List<dynamic>.from(json['run_time_licenses'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'oem': oem,
        'role': role,
        'workshop': workshop?.toJson(),
        'status': status,
        'run_time_licenses': runTimeLicenses,
      };
}

class Workshop {
  String? name;
  int? oem;
  String? address;
  String? pincode;
  bool? isActive;
  int? id;
  String? country;
  String? city;
  String? state;

  Workshop({
    this.name,
    this.oem,
    this.address,
    this.pincode,
    this.isActive,
    this.id,
    this.country,
    this.city,
    this.state,
  });

  factory Workshop.fromJson(Map<String, dynamic> json) => Workshop(
        name: json['name'],
        oem: json['oem'],
        address: json['address'],
        pincode: json['pincode'],
        isActive: json['is_active'],
        id: json['id'],
        country: json['country'],
        city: json['city'],
        state: json['state'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'oem': oem,
        'address': address,
        'pincode': pincode,
        'is_active': isActive,
        'id': id,
        'country': country,
        'city': city,
        'state': state,
      };
}

class AutoNewJobCard {
  bool? success;
  String? name;
  String? message;

  AutoNewJobCard({this.success, this.name, this.message});

  factory AutoNewJobCard.fromJson(Map<String, dynamic> json) => AutoNewJobCard(
        success: json['success'],
        name: json['name'],
        message: json['message'],
      );

  Map<String, dynamic> toJson() => {
        'success': success,
        'name': name,
        'message': message,
      };
}

class SameJobcard {
  List<String>? jobCardName;

  SameJobcard({this.jobCardName});

  factory SameJobcard.fromJson(Map<String, dynamic> json) {
    return SameJobcard(
      jobCardName: json['job_card_name'] != null
          ? List<String>.from(json['job_card_name'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'job_card_name': jobCardName,
    };
  }
}

class MainResultClass {
  SameJobcard? sameJobcard;
  JobCardModel? createJobcard;

  MainResultClass({this.sameJobcard, this.createJobcard});

  factory MainResultClass.fromJson(Map<String, dynamic> json) {
    return MainResultClass(
      sameJobcard: json['SameJobcard'] != null
          ? SameJobcard.fromJson(json['SameJobcard'])
          : null,
      createJobcard: json['CreateJobcard'] != null
          ? JobCardModel.fromJson(json['CreateJobcard'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'SameJobcard': sameJobcard?.toJson(),
      'CreateJobcard': createJobcard?.toJson(),
    };
  }
}

class SendJobcardData {
  String? status;
  String? vehicleSegment;
  String? source;
  String? chasisId;
  String? sessionType;
  String? registrationNo;
  String? vehicleModelId;
  String? submodel;
  String? date;
  String? fertCode;
  String? deviceMacId;
  String? complaints;
  String? kmCovered;
  String? vehModDes;
  String? jobCardName;
  String? model;
  String? jobCardStatus;
  String? engineNo;

  SendJobcardData({
    this.status,
    this.vehicleSegment,
    this.source,
    this.chasisId,
    this.sessionType,
    this.registrationNo,
    this.vehicleModelId,
    this.submodel,
    this.date,
    this.fertCode,
    this.deviceMacId,
    this.complaints,
    this.kmCovered,
    this.vehModDes,
    this.jobCardName,
    this.model,
    this.jobCardStatus,
    this.engineNo,
  });

  factory SendJobcardData.fromJson(Map<String, dynamic> json) {
    return SendJobcardData(
      status: json['status'],
      vehicleSegment: json['vehicle_segment'],
      source: json['source'],
      chasisId: json['chasis_id'],
      sessionType: json['session_type'],
      registrationNo: json['registration_no'],
      vehicleModelId: json['vehicle_model_id'],
      submodel: json['submodel'],
      date: json['date'],
      fertCode: json['fert_code'],
      deviceMacId: json['device_mac_id'],
      complaints: json['complaints'],
      kmCovered: json['km_covered'],
      vehModDes: json['VehModDes'],
      jobCardName: json['job_card_name'],
      model: json['model'],
      jobCardStatus: json['job_card_status'],
      engineNo: json['engine_no'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'vehicle_segment': vehicleSegment,
      'source': source,
      'chasis_id': chasisId,
      'session_type': sessionType,
      'registration_no': registrationNo,
      'vehicle_model_id': vehicleModelId,
      'submodel': submodel,
      'date': date,
      'fert_code': fertCode,
      'device_mac_id': deviceMacId,
      'complaints': complaints,
      'km_covered': kmCovered,
      'VehModDes': vehModDes,
      'job_card_name': jobCardName,
      'model': model,
      'job_card_status': jobCardStatus,
      'engine_no': engineNo,
    };
  }
}

class ExistJobCardResult {
  String? id;
  String? jobCardName;
  String? status;
  String? fertCode;
  String? vehicleSegment;
  VehicleModel? vehicleModel;
  int? vehicleModelId;
  String? chasisId;
  String? registrationNo;
  int? kmCovered;
  String? complaints;
  CreatedBy? createdBy;
  DateTime? created;
  DateTime? modified;

  ExistJobCardResult({
    this.id,
    this.jobCardName,
    this.status,
    this.fertCode,
    this.vehicleSegment,
    this.vehicleModel,
    this.vehicleModelId,
    this.chasisId,
    this.registrationNo,
    this.kmCovered,
    this.complaints,
    this.createdBy,
    this.created,
    this.modified,
  });

  factory ExistJobCardResult.fromJson(Map<String, dynamic> json) {
    return ExistJobCardResult(
      id: json['id'] as String?,
      jobCardName: json['job_card_name'] as String?,
      status: json['status'] as String?,
      fertCode: json['fert_code'] as String?,
      vehicleSegment: json['vehicle_segment'] as String?,
      vehicleModel: json['vehicle_model'] != null
          ? VehicleModel.fromJson(json['vehicle_model'])
          : null,
      vehicleModelId: json['vehicle_model_id'] as int?,
      chasisId: json['chasis_id'] as String?,
      registrationNo: json['registration_no'] as String?,
      kmCovered: json['km_covered'] as int?,
      complaints: json['complaints'] as String?,
      createdBy: json['created_by'] != null
          ? CreatedBy.fromJson(json['created_by'])
          : null,
      created: json['created'] != null ? DateTime.parse(json['created']) : null,
      modified:
          json['modified'] != null ? DateTime.parse(json['modified']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job_card_name': jobCardName,
      'status': status,
      'fert_code': fertCode,
      'vehicle_segment': vehicleSegment,
      'vehicle_model': vehicleModel?.toJson(),
      'vehicle_model_id': vehicleModelId,
      'chasis_id': chasisId,
      'registration_no': registrationNo,
      'km_covered': kmCovered,
      'complaints': complaints,
      'created_by': createdBy?.toJson(),
      'created': created?.toIso8601String(),
      'modified': modified?.toIso8601String(),
    };
  }
}

class ExistJobCard {
  int? count;
  dynamic next;
  dynamic previous;
  List<ExistJobCardResult>? results;

  ExistJobCard({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory ExistJobCard.fromJson(Map<String, dynamic> json) {
    return ExistJobCard(
      count: json['count'] as int?,
      next: json['next'],
      previous: json['previous'],
      results: json['results'] != null
          ? (json['results'] as List)
              .map((item) => ExistJobCardResult.fromJson(item))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'next': next,
      'previous': previous,
      'results': results?.map((item) => item.toJson()).toList(),
    };
  }
}

class Result {
  String? id;
  String? sessionId;
  String? jobCard;
  String? source;
  VehicleModel? vehicleModel;
  DateTime? startDate;
  DateTime? endDate;
  dynamic deviceDongle;
  int? device;
  int dtcRecordCount;
  int clearRecordCount;
  int pidSnapshotRecordCount;
  int pidLiveRecordCount;
  int pidWriteRecordCount;
  int flashRecordCount;
  User? user;
  String? sessionType;
  String? status;
  JobCardRemoteSession? jobCardRemoteSession;
  dynamic automatedSession;

  Result({
    this.id,
    this.sessionId,
    this.jobCard,
    this.source,
    this.vehicleModel,
    this.startDate,
    this.endDate,
    this.deviceDongle,
    this.device,
    this.dtcRecordCount = 0,
    this.clearRecordCount = 0,
    this.pidSnapshotRecordCount = 0,
    this.pidLiveRecordCount = 0,
    this.pidWriteRecordCount = 0,
    this.flashRecordCount = 0,
    this.user,
    this.sessionType,
    this.status,
    this.jobCardRemoteSession,
    this.automatedSession,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json['id'],
        sessionId: json['session_id'],
        jobCard: json['job_card'],
        source: json['source'],
        vehicleModel: json['vehicle_model'] != null
            ? VehicleModel.fromJson(json['vehicle_model'])
            : null,
        startDate: json['start_date'] != null
            ? DateTime.parse(json['start_date'])
            : null,
        endDate:
            json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
        deviceDongle: json['device_dongle'],
        device: json['device'],
        dtcRecordCount: json['dtc_record_count'] ?? 0,
        clearRecordCount: json['clear_record_count'] ?? 0,
        pidSnapshotRecordCount: json['pid_snapshot_record_count'] ?? 0,
        pidLiveRecordCount: json['pid_live_record_count'] ?? 0,
        pidWriteRecordCount: json['pid_write_record_count'] ?? 0,
        flashRecordCount: json['flash_record_count'] ?? 0,
        user: json['user'] != null ? User.fromJson(json['user']) : null,
        sessionType: json['session_type'],
        status: json['status'],
        jobCardRemoteSession: json['job_card_remote_session'] != null
            ? JobCardRemoteSession.fromJson(json['job_card_remote_session'])
            : null,
        automatedSession: json['automated_session'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'session_id': sessionId,
        'job_card': jobCard,
        'source': source,
        'vehicle_model': vehicleModel?.toJson(),
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'device_dongle': deviceDongle,
        'device': device,
        'dtc_record_count': dtcRecordCount,
        'clear_record_count': clearRecordCount,
        'pid_snapshot_record_count': pidSnapshotRecordCount,
        'pid_live_record_count': pidLiveRecordCount,
        'pid_write_record_count': pidWriteRecordCount,
        'flash_record_count': flashRecordCount,
        'user': user?.toJson(),
        'session_type': sessionType,
        'status': status,
        'job_card_remote_session': jobCardRemoteSession?.toJson(),
        'automated_session': automatedSession,
      };
}

class PostJobCardSession {
  String? status;
  String? jobCard;
  String? source;
  String? vehicleModelId;
  String? sessionType;
  String? deviceMacId;
  String? jobCardName;

  PostJobCardSession({
    this.status,
    this.jobCard,
    this.source,
    this.vehicleModelId,
    this.sessionType,
    this.deviceMacId,
    this.jobCardName,
  });

  factory PostJobCardSession.fromJson(Map<String, dynamic> json) {
    return PostJobCardSession(
      status: json['status'],
      jobCard: json['job_card'],
      source: json['source'],
      vehicleModelId: json['vehicle_model_id'],
      sessionType: json['session_type'],
      deviceMacId: json['device_mac_id'],
      jobCardName: json['job_card_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'job_card': jobCard,
      'source': source,
      'vehicle_model_id': vehicleModelId,
      'session_type': sessionType,
      'device_mac_id': deviceMacId,
      'job_card_name': jobCardName,
    };
  }
}

class PostDtcRecord {
  String? status;
  String? value;

  PostDtcRecord({this.status, this.value});

  // From JSON
  factory PostDtcRecord.fromJson(Map<String, dynamic> json) {
    return PostDtcRecord(
      status: json['status'] as String?,
      value: json['value'] as String?,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'value': value,
    };
  }
}

class DtcR {
  List<PostDtcRecord>? dtc;

  DtcR({this.dtc});

  // From JSON
  factory DtcR.fromJson(Map<String, dynamic> json) {
    return DtcR(
      dtc: json['dtc'] != null
          ? List<PostDtcRecord>.from(
              (json['dtc'] as List).map((x) => PostDtcRecord.fromJson(x)))
          : null,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'dtc': dtc?.map((x) => x.toJson()).toList(),
    };
  }
}

class ClearDtcRecord {
  String? session;
  String? status;

  ClearDtcRecord({this.session, this.status});

  factory ClearDtcRecord.fromJson(Map<String, dynamic> json) {
    return ClearDtcRecord(
      session: json['session'] as String?,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session': session,
      'status': status,
    };
  }
}

// ---------------- pid_write_record ----------------
class PidWriteRecordItem {
  String? pidCode;
  String? valueBefore;
  String? valueAfter;
  String? status;

  PidWriteRecordItem(
      {this.pidCode, this.valueBefore, this.valueAfter, this.status});

  factory PidWriteRecordItem.fromJson(Map<String, dynamic> json) =>
      PidWriteRecordItem(
        pidCode: json['pid_code'],
        valueBefore: json['value_before'],
        valueAfter: json['value_after'],
        status: json['status'],
      );

  Map<String, dynamic> toJson() => {
        'pid_code': pidCode,
        'value_before': valueBefore,
        'value_after': valueAfter,
        'status': status,
      };
}

// ---------------- PidWriteRecord ----------------
class PidWriteRecord {
  List<PidWriteRecordItem> pidWriteRecords;

  PidWriteRecord({List<PidWriteRecordItem>? pidWriteRecords})
      : pidWriteRecords = pidWriteRecords ?? [];

  factory PidWriteRecord.fromJson(Map<String, dynamic> json) => PidWriteRecord(
        pidWriteRecords: (json['pid_write_records'] as List<dynamic>?)
                ?.map((e) => PidWriteRecordItem.fromJson(e))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'pid_write_records': pidWriteRecords.map((e) => e.toJson()).toList(),
      };
}

// ---------------- flash_record ----------------
class FlashRecord {
  String? flashDuration;
  String? status;
  String? cvnBeforeFlash;
  String? cvnAfterFlash;

  FlashRecord(
      {this.flashDuration,
      this.status,
      this.cvnBeforeFlash,
      this.cvnAfterFlash});

  factory FlashRecord.fromJson(Map<String, dynamic> json) => FlashRecord(
        flashDuration: json['flash_duration'],
        status: json['status'],
        cvnBeforeFlash: json['cvn_before_flash'],
        cvnAfterFlash: json['cvn_after_flash'],
      );

  Map<String, dynamic> toJson() => {
        'flash_duration': flashDuration,
        'status': status,
        'cvn_before_flash': cvnBeforeFlash,
        'cvn_after_flash': cvnAfterFlash,
      };
}

// ---------------- pid_live_record ----------------
class PidLiveRecord {
  String? pidLive;

  PidLiveRecord({this.pidLive});

  factory PidLiveRecord.fromJson(Map<String, dynamic> json) => PidLiveRecord(
        pidLive: json['pid_live'],
      );

  Map<String, dynamic> toJson() => {
        'pid_live': pidLive,
      };
}

// ---------------- pid_snapshot_record ----------------
class PidSnapshotRecord {
  List<SnapshotRecord> pidSnapshot;

  PidSnapshotRecord({List<SnapshotRecord>? pidSnapshot})
      : pidSnapshot = pidSnapshot ?? [];

  factory PidSnapshotRecord.fromJson(Map<String, dynamic> json) =>
      PidSnapshotRecord(
        pidSnapshot: (json['pid_snapshot'] as List<dynamic>?)
                ?.map((e) => SnapshotRecord.fromJson(e))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'pid_snapshot': pidSnapshot.map((e) => e.toJson()).toList(),
      };
}

// ---------------- snapshot_record ----------------
class SnapshotRecord {
  String? code;
  String? value;

  SnapshotRecord({this.code, this.value});

  factory SnapshotRecord.fromJson(Map<String, dynamic> json) => SnapshotRecord(
        code: json['code'],
        value: json['value'],
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'value': value,
      };
}

// ---------------- JobcardNumber ----------------
class JobcardNumber {
  String? name;
  bool? success;
  String? error;

  JobcardNumber({this.name, this.success, this.error});

  factory JobcardNumber.fromJson(Map<String, dynamic> json) => JobcardNumber(
        name: json['name'],
        success: json['success'],
        error: json['error'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'success': success,
        'error': error,
      };
}
