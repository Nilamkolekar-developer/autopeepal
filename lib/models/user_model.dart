// ================= REQUEST MODELS =================

import 'package:autopeepal/models/jobCard_model.dart';

class UserModel {
  String username;
  String password;
  String macId;
  String deviceType;

  UserModel({
    required this.username,
    required this.password,
    required this.macId,
    required this.deviceType,
  });

  // ✅ For API / file save
  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "password": password,
      "mac_id": macId,
      "device_type": deviceType,
    };
  }

  // ✅ REQUIRED for offline login / restore
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'],
      password: json['password'],
      macId: json['mac_id'],
      deviceType: json['device_type'],
    );
  }
}

class ChangePassword {
  String newPassword1;
  String newPassword2;

  ChangePassword({
    required this.newPassword1,
    required this.newPassword2,
  });

  Map<String, dynamic> toJson() {
    return {
      "new_password1": newPassword1,
      "new_password2": newPassword2,
    };
  }

  factory ChangePassword.fromJson(Map<String, dynamic> json) {
    return ChangePassword(
      newPassword1: json['new_password1'],
      newPassword2: json['new_password2'],
    );
  }
}

class LoginRespons {
  LoginRes? loginRes;
  UserResModel? userRes;

  LoginRespons({
    this.loginRes,
    this.userRes,
  });

  factory LoginRespons.fromJson(Map<String, dynamic> json) {
    return LoginRespons(
      loginRes:
          json['login'] != null ? LoginRes.fromJson(json['login']) : null,
      userRes:
          json['userRes'] != null ? UserResModel.fromJson(json['userRes']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "login": loginRes?.toJson(),
      "userRes": userRes?.toJson(),
    };
  }
}

class LoginRes {
  String? error;
  bool? isActive;

  LoginRes({this.error, this.isActive});

  factory LoginRes.fromJson(Map<String, dynamic> json) {
    return LoginRes(
      error: json['error'],
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "error": error,
      "is_active": isActive,
    };
  }
}

class Licences {
  bool allDTC;
  bool selfTest;
  bool ecuFlashing;
  bool write;
  bool liveParameter;
  bool dtc;
  bool ecuInformation;
  bool regeneration;
  bool sessionLog;

  Licences({
    required this.allDTC,
    required this.selfTest,
    required this.ecuFlashing,
    required this.write,
    required this.liveParameter,
    required this.dtc,
    required this.ecuInformation,
    required this.regeneration,
    required this.sessionLog,
  });

  factory Licences.fromJson(Map<String, dynamic> json) {
    return Licences(
      allDTC: json['All DTC'] ?? false,
      selfTest: json['Self Test'] ?? false,
      ecuFlashing: json['ECU Flashing'] ?? false,
      write: json['Write'] ?? false,
      liveParameter: json['Live Parameter'] ?? false,
      dtc: json['DTC'] ?? false,
      ecuInformation: json['ECU Information'] ?? false,
      regeneration: json['Regeneration'] ?? false,
      sessionLog: json['Session Log'] ?? false,
    );
  }

  /// ✅ ADD THIS
  Map<String, dynamic> toJson() {
    return {
      'All DTC': allDTC,
      'Self Test': selfTest,
      'ECU Flashing': ecuFlashing,
      'Write': write,
      'Live Parameter': liveParameter,
      'DTC': dtc,
      'ECU Information': ecuInformation,
      'Regeneration': regeneration,
      'Session Log': sessionLog,
    };
  }
}

class UserResModel {
  int? userId;
  Licences? licences;
  String? lastName;
  String? role;
  DateTime? expires;
  Token? token;
  String? user;
  String? firstName;
  Profile? profile;
  String? message;

  UserResModel({
    this.userId,
    this.licences,
    this.lastName,
    this.role,
    this.expires,
    this.token,
    this.user,
    this.firstName,
    this.profile,
    this.message,
  });

  factory UserResModel.fromJson(Map<String, dynamic> json) {
    return UserResModel(
      userId: json['user_id'],
      licences:
          json['licences'] != null ? Licences.fromJson(json['licences']) : null,
      lastName: json['last_name'],
      role: json['role'],
      expires:
          json['expires'] != null ? DateTime.parse(json['expires']) : null,
      token: json['token'] != null ? Token.fromJson(json['token']) : null,
      user: json['user'],
      firstName: json['first_name'],
      profile:
          json['profile'] != null ? Profile.fromJson(json['profile']) : null,
      message: json['message'],
    );
  }

  /// ✅ ADD THIS
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'licences': licences?.toJson(),
      'last_name': lastName,
      'role': role,
      'expires': expires?.toIso8601String(),
      'token': token?.toJson(),
      'user': user,
      'first_name': firstName,
      'profile': profile?.toJson(),
      'message': message,
    };
  }
}
class Profile {
  int? id;
  Oem1? oem;
  String? email;
  String? mobile;
  String? role;
  bool? status;
  dynamic parent;
  int? user;
  int? workshop;
  dynamic reportTo;
  List<dynamic>? runTimeLicenses;

  /// ✅ IMPORTANT: make this strongly typed
  List<VehicleModel>? workshopGroupModels;

  Profile({
    this.id,
    this.oem,
    this.email,
    this.mobile,
    this.role,
    this.status,
    this.parent,
    this.user,
    this.workshop,
    this.reportTo,
    this.runTimeLicenses,
    this.workshopGroupModels,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      oem: json['oem'] != null ? Oem1.fromJson(json['oem']) : null,
      email: json['email'],
      mobile: json['mobile'],
      role: json['role'],
      status: json['status'],
      parent: json['parent'],
      user: json['user'],
      workshop: json['workshop'],
      reportTo: json['report_to'],
      runTimeLicenses: json['run_time_licenses'] ?? [],
      workshopGroupModels: json['workshop_group_models'] != null
          ? List<VehicleModel>.from(
              json['workshop_group_models']
                  .map((e) => VehicleModel.fromJson(e)),
            )
          : [],
    );
  }

  /// ✅ ADD THIS
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'oem': oem?.toJson(),
      'email': email,
      'mobile': mobile,
      'role': role,
      'status': status,
      'parent': parent,
      'user': user,
      'workshop': workshop,
      'report_to': reportTo,
      'run_time_licenses': runTimeLicenses,
      'workshop_group_models':
          workshopGroupModels?.map((e) => e.toJson()).toList(),
    };
  }
}
class Oem1 {
  int? id;
  DateTime? created;
  DateTime? modified;
  String? name;
  String? slug;
  dynamic createdBy;
  bool? isActive;
  String? oemFile;
  String? color;
  String? appName;
  int? admin;
  dynamic manager;

  Oem1({
    this.id,
    this.created,
    this.modified,
    this.name,
    this.slug,
    this.createdBy,
    this.isActive,
    this.oemFile,
    this.color,
    this.appName,
    this.admin,
    this.manager,
  });

  factory Oem1.fromJson(Map<String, dynamic> json) {
    return Oem1(
      id: json['id'],
      created: json['created'] != null
          ? DateTime.parse(json['created'])
          : null,
      modified: json['modified'] != null
          ? DateTime.parse(json['modified'])
          : null,
      name: json['name'],
      slug: json['slug'],
      createdBy: json['created_by'],
      isActive: json['is_active'],
      oemFile: json['oem_file'],
      color: json['color'],
      appName: json['app_name'],
      admin: json['admin'],
      manager: json['manager'],
    );
  }

  /// ✅ ADD THIS
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created': created?.toIso8601String(),
      'modified': modified?.toIso8601String(),
      'name': name,
      'slug': slug,
      'created_by': createdBy,
      'is_active': isActive,
      'oem_file': oemFile,
      'color': color,
      'app_name': appName,
      'admin': admin,
      'manager': manager,
    };
  }
}
class Token {
  String? refresh;
  String? access;

  Token({this.refresh, this.access});

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      refresh: json['refresh'],
      access: json['access'],
    );
  }

  /// ✅ ADD THIS
  Map<String, dynamic> toJson() {
    return {
      'refresh': refresh,
      'access': access,
    };
  }
}