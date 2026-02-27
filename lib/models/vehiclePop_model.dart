class VehiclePopModel {
  String? modelName;

  VehiclePopModel({this.modelName});

  factory VehiclePopModel.fromJson(Map<String, dynamic> json) =>
      VehiclePopModel(
        modelName: json['ModelName'],
      );

  Map<String, dynamic> toJson() => {
        'ModelName': modelName,
      };
}