class RegisterDongleModel {
  dynamic macId; // C# had `object`, so using dynamic
  String deviceType;

  RegisterDongleModel({required this.macId, required this.deviceType});

  Map<String, dynamic> toJson() => {
        'mac_id': macId,
        'device_type': deviceType,
      };
}

class RegisterDongleResponse {
  RegDongleResponse? errorRes;

  RegisterDongleResponse({this.errorRes});

  factory RegisterDongleResponse.fromJson(Map<String, dynamic> json) {
    return RegisterDongleResponse(
      errorRes: json['errorRes'] != null
          ? RegDongleResponse.fromJson(json['errorRes'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'errorRes': errorRes?.toJson(),
      };
}

class ErrorRes {
  String? error;
  bool? isActive;

  ErrorRes({this.error, this.isActive});

  factory ErrorRes.fromJson(Map<String, dynamic> json) {
    return ErrorRes(
      error: json['error'],
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() => {
        'error': error,
        'is_active': isActive,
      };
}

class RegDongleResponse {
  String? oem;
  String? deviceType;
  String? message;
  String? macId;
  String? user;
  bool? isActive;

  RegDongleResponse({
    this.oem,
    this.deviceType,
    this.message,
    this.macId,
    this.user,
    this.isActive,
  });

  factory RegDongleResponse.fromJson(Map<String, dynamic> json) {
    return RegDongleResponse(
      oem: json['oem'],
      deviceType: json['device_type'],
      message: json['message'],
      macId: json['mac_id'],
      user: json['user'],
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() => {
        'oem': oem,
        'device_type': deviceType,
        'message': message,
        'mac_id': macId,
        'user': user,
        'is_active': isActive,
      };
}