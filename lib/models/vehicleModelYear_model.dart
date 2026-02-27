class VehicleModelYearModel {
  String? vehicleModelYear;

  VehicleModelYearModel({this.vehicleModelYear});

  factory VehicleModelYearModel.fromJson(Map<String, dynamic> json) =>
      VehicleModelYearModel(
        vehicleModelYear: json['vehicle_model_year'],
      );

  Map<String, dynamic> toJson() => {
        'vehicle_model_year': vehicleModelYear,
      };
}