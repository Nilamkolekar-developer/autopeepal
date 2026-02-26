class RemoteJobCardModel {
  String? jobCardSession;
  String? remoteSessionStatus;
  String? status;
  bool? requestStatus;
  int? expertUser;

  RemoteJobCardModel({
    this.jobCardSession,
    this.remoteSessionStatus,
    this.status,
    this.requestStatus,
    this.expertUser,
  });

  factory RemoteJobCardModel.fromJson(Map<String, dynamic> json) {
    return RemoteJobCardModel(
      jobCardSession: json['job_card_session'],
      remoteSessionStatus: json['remote_session_status'],
      status: json['status'],
      requestStatus: json['request_status'],
      expertUser: json['expert_user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'job_card_session': jobCardSession,
      'remote_session_status': remoteSessionStatus,
      'status': status,
      'request_status': requestStatus,
      'expert_user': expertUser,
    };
  }
}

class RemoteRequestDiagnostic {
  String? forExpertSessionID;
  String? idForRemote;
  String? status;
  int? expertUser;
  bool? requestStatus;

  RemoteRequestDiagnostic({
    this.forExpertSessionID,
    this.idForRemote,
    this.status,
    this.expertUser,
    this.requestStatus,
  });

  factory RemoteRequestDiagnostic.fromJson(Map<String, dynamic> json) {
    return RemoteRequestDiagnostic(
      forExpertSessionID: json['ForExpertSessionID'],
      idForRemote: json['IDForRemote'],
      status: json['status'],
      expertUser: json['expert_user'],
      requestStatus: json['request_status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ForExpertSessionID': forExpertSessionID,
      'IDForRemote': idForRemote,
      'status': status,
      'expert_user': expertUser,
      'request_status': requestStatus,
    };
  }
}

class RemoteRequestAcceptOrDecline {
  String? status;
  int? expertUser;
  bool? requestStatus;

  RemoteRequestAcceptOrDecline({this.status, this.expertUser, this.requestStatus});

  factory RemoteRequestAcceptOrDecline.fromJson(Map<String, dynamic> json) {
    return RemoteRequestAcceptOrDecline(
      status: json['status'],
      expertUser: json['expert_user'],
      requestStatus: json['request_status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'expert_user': expertUser,
      'request_status': requestStatus,
    };
  }
}

class NonFieldError {
  String? remoteSessionId;
  String? error;

  NonFieldError({this.remoteSessionId, this.error});

  factory NonFieldError.fromJson(Map<String, dynamic> json) {
    return NonFieldError(
      remoteSessionId: json['remote_session_id'],
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'remote_session_id': remoteSessionId,
      'error': error,
    };
  }
}

class BadRequestResponseModel {
  List<NonFieldError> nonFieldErrors;

  BadRequestResponseModel({List<NonFieldError>? nonFieldErrors})
      : nonFieldErrors = nonFieldErrors ?? [];

  factory BadRequestResponseModel.fromJson(Map<String, dynamic> json) {
    return BadRequestResponseModel(
      nonFieldErrors: json['non_field_errors'] != null
          ? List<NonFieldError>.from(json['non_field_errors'].map((x) => NonFieldError.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'non_field_errors': nonFieldErrors.map((x) => x.toJson()).toList(),
    };
  }
}

class ResponseJobCardModel {
  String? id;
  String? remoteSessionId;
  String? jobCardSession;
  dynamic caseId;
  String? status;
  int? expertUser;
  dynamic expertDevice;
  String? expertEmail;
  bool? requestStatus;

  ResponseJobCardModel({
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

  factory ResponseJobCardModel.fromJson(Map<String, dynamic> json) {
    return ResponseJobCardModel(
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
  }

  Map<String, dynamic> toJson() {
    return {
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
}

class MainResponseModel {
  BadRequestResponseModel badRequestResponseModel;
  ResponseJobCardModel? newRequestResponseModel;
  String? status;

  MainResponseModel({
    BadRequestResponseModel? badRequestResponseModel,
    this.newRequestResponseModel,
    this.status,
  }) : badRequestResponseModel = badRequestResponseModel ?? BadRequestResponseModel();

  factory MainResponseModel.fromJson(Map<String, dynamic> json) {
    return MainResponseModel(
      badRequestResponseModel: json['badRequestResponseModel'] != null
          ? BadRequestResponseModel.fromJson(json['badRequestResponseModel'])
          : BadRequestResponseModel(),
      newRequestResponseModel: json['NewRequestResponseModel'] != null
          ? ResponseJobCardModel.fromJson(json['NewRequestResponseModel'])
          : null,
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'badRequestResponseModel': badRequestResponseModel.toJson(),
      'NewRequestResponseModel': newRequestResponseModel?.toJson(),
      'status': status,
    };
  }
}

class ResponseRoot {
  int? count;
  dynamic next;
  dynamic previous;
  List<ResponseJobCardModel>? results;

  ResponseRoot({this.count, this.next, this.previous, this.results});

  factory ResponseRoot.fromJson(Map<String, dynamic> json) {
    return ResponseRoot(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: json['results'] != null
          ? List<ResponseJobCardModel>.from(json['results'].map((x) => ResponseJobCardModel.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'next': next,
      'previous': previous,
      'results': results?.map((x) => x.toJson()).toList(),
    };
  }
}