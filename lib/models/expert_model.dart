class ExpertModel {
  int? id;
  String? email;
  String? mobile;
  String? firstName;
  String? lastName;
  String? status;
  String? workshop;
  String? workshopCity;
  String? remoteSessionId;
  String? remoteSessionInternalId;
  dynamic autoSessionInternalId;
  dynamic autoSessionId;
  String? statusColor;
  bool? btnIsActive;

  ExpertModel({
    this.id,
    this.email,
    this.mobile,
    this.firstName,
    this.lastName,
    this.status,
    this.workshop,
    this.workshopCity,
    this.remoteSessionId,
    this.remoteSessionInternalId,
    this.autoSessionInternalId,
    this.autoSessionId,
    this.statusColor,
    this.btnIsActive,
  });

  factory ExpertModel.fromJson(Map<String, dynamic> json) => ExpertModel(
        id: json['id'],
        email: json['email'],
        mobile: json['mobile'],
        firstName: json['first_name'],
        lastName: json['last_name'],
        status: json['status'],
        workshop: json['workshop'],
        workshopCity: json['workshop_city'],
        remoteSessionId: json['remote_session_id'],
        remoteSessionInternalId: json['remote_session_internal_id'],
        autoSessionInternalId: json['auto_session_internal_id'],
        autoSessionId: json['auto_session_id'],
        statusColor: json['status_color'],
        btnIsActive: json['btnIsActive'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'mobile': mobile,
        'first_name': firstName,
        'last_name': lastName,
        'status': status,
        'workshop': workshop,
        'workshop_city': workshopCity,
        'remote_session_id': remoteSessionId,
        'remote_session_internal_id': remoteSessionInternalId,
        'auto_session_internal_id': autoSessionInternalId,
        'auto_session_id': autoSessionId,
        'status_color': statusColor,
        'btnIsActive': btnIsActive,
      };
}

class OnlineExpertModel {
  int? count;
  dynamic next;
  dynamic previous;
  List<ExpertModel>? results;

  OnlineExpertModel({this.count, this.next, this.previous, this.results});

  factory OnlineExpertModel.fromJson(Map<String, dynamic> json) =>
      OnlineExpertModel(
        count: json['count'],
        next: json['next'],
        previous: json['previous'],
        results: json['results'] != null
            ? List<ExpertModel>.from(
                json['results'].map((x) => ExpertModel.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        'count': count,
        'next': next,
        'previous': previous,
        'results': results?.map((x) => x.toJson()).toList(),
      };
}

class DTCMaskRoot {
  int? count;
  dynamic next;
  dynamic previous;
  List<DTCMaskResult>? results;

  DTCMaskRoot({this.count, this.next, this.previous, this.results});

  factory DTCMaskRoot.fromJson(Map<String, dynamic> json) => DTCMaskRoot(
        count: json['count'],
        next: json['next'],
        previous: json['previous'],
        results: json['results'] != null
            ? List<DTCMaskResult>.from(
                json['results'].map((x) => DTCMaskResult.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        'count': count,
        'next': next,
        'previous': previous,
        'results': results?.map((x) => x.toJson()).toList(),
      };
}

class DTCMaskResult {
  int? id;
  String? maskName;
  String? maskDescription;
  String? isActive;
  List<DTCMaskMaskId>? maskIds;

  DTCMaskResult(
      {this.id, this.maskName, this.maskDescription, this.isActive, this.maskIds});

  factory DTCMaskResult.fromJson(Map<String, dynamic> json) => DTCMaskResult(
        id: json['id'],
        maskName: json['mask_name'],
        maskDescription: json['mask_description'],
        isActive: json['is_active'],
        maskIds: json['mask_ids'] != null
            ? List<DTCMaskMaskId>.from(
                json['mask_ids'].map((x) => DTCMaskMaskId.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'mask_name': maskName,
        'mask_description': maskDescription,
        'is_active': isActive,
        'mask_ids': maskIds?.map((x) => x.toJson()).toList(),
      };
}

class DTCMaskMaskId {
  int? vehicleModel;
  int? subModel;
  int? modelYear;
  List<String>? dtcCode;

  DTCMaskMaskId({this.vehicleModel, this.subModel, this.modelYear, this.dtcCode});

  factory DTCMaskMaskId.fromJson(Map<String, dynamic> json) => DTCMaskMaskId(
        vehicleModel: json['vehicle_model'],
        subModel: json['sub_model'],
        modelYear: json['model_year'],
        dtcCode: json['dtc_code'] != null
            ? List<String>.from(json['dtc_code'])
            : [],
      );

  Map<String, dynamic> toJson() => {
        'vehicle_model': vehicleModel,
        'sub_model': subModel,
        'model_year': modelYear,
        'dtc_code': dtcCode,
      };
}