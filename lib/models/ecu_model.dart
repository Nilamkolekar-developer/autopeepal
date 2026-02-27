class EcuModel {
  String? ecu;

  EcuModel({this.ecu});

  factory EcuModel.fromJson(Map<String, dynamic> json) => EcuModel(
        ecu: json['ecu'],
      );

  Map<String, dynamic> toJson() => {
        'ecu': ecu,
      };
}