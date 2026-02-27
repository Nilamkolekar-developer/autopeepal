class CityModel {
  String? city;

  CityModel({this.city});

  factory CityModel.fromJson(Map<String, dynamic> json) => CityModel(
        city: json['City'],
      );

  Map<String, dynamic> toJson() => {
        'City': city,
      };
}