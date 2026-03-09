class VehicleSubModelModel {
  String? name;

  VehicleSubModelModel({this.name});

  factory VehicleSubModelModel.fromJson(Map<String, dynamic> json) =>
      VehicleSubModelModel(
        name: json['name'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
      };
}