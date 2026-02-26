class Login {
  Token? token;
  String? user;
  String? role;
  String? firstName;
  String? lastName;
  DateTime? expires;
  Map<String, bool>? licences;
  int? userId;
  Profile? profile;
  List<DeviceDatum>? deviceData;
  List<dynamic>? vehicleModels;

  Login({
    this.token,
    this.user,
    this.role,
    this.firstName,
    this.lastName,
    this.expires,
    this.licences,
    this.userId,
    this.profile,
    this.deviceData,
    this.vehicleModels,
  });

  factory Login.fromJson(Map<String, dynamic> json) {
    return Login(
      token: json['token'] != null ? Token.fromJson(json['token']) : null,
      user: json['user'],
      role: json['role'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      expires: json['expires'] != null
          ? DateTime.parse(json['expires'])
          : null,
      licences: json['licences'] != null
          ? Map<String, bool>.from(json['licences'])
          : {},
      userId: json['user_id'],
      profile: json['profile'] != null
          ? Profile.fromJson(json['profile'])
          : null,
      deviceData: json['device_data'] != null
          ? List<DeviceDatum>.from(
              json['device_data'].map((x) => DeviceDatum.fromJson(x)))
          : [],
      vehicleModels: json['vehicle_models'] ?? [],
    );
  }
}

class DeviceDatum {
  String? macId;
  dynamic parent;
  String? serialNumber;
  bool? isActive;

  DeviceDatum({
    this.macId,
    this.parent,
    this.serialNumber,
    this.isActive,
  });

  factory DeviceDatum.fromJson(Map<String, dynamic> json) {
    return DeviceDatum(
      macId: json['mac_id'],
      parent: json['parent'],
      serialNumber: json['serial_number'],
      isActive: json['is_active'],
    );
  }
}

class Profile {
  int? id;
  Oem? oem;
  String? email;
  String? mobile;
  dynamic otp;
  String? role;
  bool? status;
  dynamic parent;
  int? user;
  int? workshop;
  dynamic reportTo;
  List<dynamic>? runTimeLicenses;

  Profile({
    this.id,
    this.oem,
    this.email,
    this.mobile,
    this.otp,
    this.role,
    this.status,
    this.parent,
    this.user,
    this.workshop,
    this.reportTo,
    this.runTimeLicenses,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      oem: json['oem'] != null ? Oem.fromJson(json['oem']) : null,
      email: json['email'],
      mobile: json['mobile'],
      otp: json['otp'],
      role: json['role'],
      status: json['status'],
      parent: json['parent'],
      user: json['user'],
      workshop: json['workshop'],
      reportTo: json['report_to'],
      runTimeLicenses: json['run_time_licenses'] ?? [],
    );
  }
}

class Oem {
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

  Oem({
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

  factory Oem.fromJson(Map<String, dynamic> json) {
    return Oem(
      id: json['id'],
      created: DateTime.parse(json['created']),
      modified: DateTime.parse(json['modified']),
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
}

class Token {
  String? refresh;
  String? access;

  Token({
    this.refresh,
    this.access,
  });

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      refresh: json['refresh'],
      access: json['access'],
    );
  }
}