class WifiDevicesModel {
  String? name;
  String? ip;
  String? macAddress;

  WifiDevicesModel({
    this.name,
    this.ip,
    this.macAddress,
  });

  factory WifiDevicesModel.fromJson(Map<String, dynamic> json) =>
      WifiDevicesModel(
        name: json['Name'],
        ip: json['Ip'],
        macAddress: json['Mac_Address'],
      );

  Map<String, dynamic> toJson() => {
        'Name': name,
        'Ip': ip,
        'Mac_Address': macAddress,
      };
}