class ProtocolModel {
  String? protocol;
  int? protocolIndex;

  ProtocolModel({
    this.protocol,
    this.protocolIndex,
  });

  factory ProtocolModel.fromJson(Map<String, dynamic> json) => ProtocolModel(
        protocol: json['Protocol'],
        protocolIndex: json['ProtocolIndex'],
      );

  Map<String, dynamic> toJson() => {
        'Protocol': protocol,
        'ProtocolIndex': protocolIndex,
      };
}