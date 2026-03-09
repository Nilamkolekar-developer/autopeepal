class DongleModel {
  int? count;
  dynamic next;
  dynamic previous;
  List<DongleResult>? results;

  DongleModel({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory DongleModel.fromJson(Map<String, dynamic> json) => DongleModel(
        count: json['count']?.toInt(),
        next: json['next'],
        previous: json['previous'],
        results: json['results'] != null
            ? List<DongleResult>.from(
                json['results'].map((x) => DongleResult.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        'count': count,
        'next': next,
        'previous': previous,
        'results':
            results != null ? results!.map((x) => x.toJson()).toList() : [],
      };
}

class DongleResult {
  String? macId;
  dynamic parent;
  Oem? oem;
  List<DongleUser>? user;
  String? serialNumber;
  bool? isActive;

  DongleResult({
    this.macId,
    this.parent,
    this.oem,
    this.user,
    this.serialNumber,
    this.isActive,
  });

  factory DongleResult.fromJson(Map<String, dynamic> json) => DongleResult(
        macId: json['mac_id'],
        parent: json['parent'],
        oem: json['oem'] != null ? Oem.fromJson(json['oem']) : null,
        user: json['user'] != null
            ? List<DongleUser>.from(
                json['user'].map((x) => DongleUser.fromJson(x)))
            : [],
        serialNumber: json['serial_number'],
        isActive: json['is_active'],
      );

  Map<String, dynamic> toJson() => {
        'mac_id': macId,
        'parent': parent,
        'oem': oem?.toJson(),
        'user': user != null ? user!.map((x) => x.toJson()).toList() : [],
        'serial_number': serialNumber,
        'is_active': isActive,
      };
}

class Oem {
  String? name;
  String? slug;
  String? admin;
  bool? isActive;

  Oem({
    this.name,
    this.slug,
    this.admin,
    this.isActive,
  });

  factory Oem.fromJson(Map<String, dynamic> json) => Oem(
        name: json['name'],
        slug: json['slug'],
        admin: json['admin'],
        isActive: json['is_active'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'slug': slug,
        'admin': admin,
        'is_active': isActive,
      };
}

class DongleUser {
  String? email;
  String? fullName;
  String? mobile;
  String? workshop;
  String? role;

  DongleUser({
    this.email,
    this.fullName,
    this.mobile,
    this.workshop,
    this.role,
  });

  factory DongleUser.fromJson(Map<String, dynamic> json) => DongleUser(
        email: json['email'],
        fullName: json['full_name'],
        mobile: json['mobile'],
        workshop: json['workshop'],
        role: json['role'],
      );

  Map<String, dynamic> toJson() => {
        'email': email,
        'full_name': fullName,
        'mobile': mobile,
        'workshop': workshop,
        'role': role,
      };
}
