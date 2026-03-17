class OemModel {
  int? count;
  dynamic next;
  dynamic previous;
  List<AllOemModel> results; // non-nullable
  String? message;

  OemModel({
    this.count,
    this.next,
    this.previous,
    required this.results,
    this.message,
  });

  factory OemModel.fromJson(Map<String, dynamic> json) => OemModel(
        count: json['count'],
        next: json['next'],
        previous: json['previous'],
        results: json['results'] != null
            ? List<AllOemModel>.from(
                json['results'].map((x) => AllOemModel.fromJson(x)))
            : [],
        message: json['message'] ?? "",
      );

  Map<String, dynamic> toJson() => {
        'count': count,
        'next': next,
        'previous': previous,
        'results': results.map((x) => x.toJson()).toList(),
        'message': message,
      };
}

class AllOemModel {
  int? id;
  String? name;
  int? admin;
  String? oemFile;
  dynamic color;
  dynamic appName;
  bool? isActive;

  AllOemModel({
    this.id,
    this.name,
    this.admin,
    this.oemFile,
    this.color,
    this.appName,
    this.isActive,
  }) {}

  factory AllOemModel.fromJson(Map<String, dynamic> json) => AllOemModel(
        id: json['id'],
        name: json['name'],
        admin: json['admin'],
        oemFile: json['oem_file'],
        color: json['color'],
        appName: json['app_name'],
        isActive: json['is_active'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'admin': admin,
        'oem_file': oemFile,
        'color': color,
        'app_name': appName,
        'is_active': isActive,
      };
}
