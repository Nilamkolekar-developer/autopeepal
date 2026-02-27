class VehicleModelModel {
  String? name;

  VehicleModelModel({this.name});

  factory VehicleModelModel.fromJson(Map<String, dynamic> json) =>
      VehicleModelModel(
        name: json['name'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
      };
}