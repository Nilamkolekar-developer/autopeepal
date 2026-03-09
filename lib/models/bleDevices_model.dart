class BLEDeviceModel {
  String? nameColor;
  String? name;
  String? address;
  String? alias;
  String? bondState;
  String? type;
  int? rssi;
  String? state;
  String? stateColor;
  String? pressure;
  String? preUnitTxt;
  String? temperature;
  String? temUnitTxt;
  String? battery;
  List<Manufacturer>? manufacturer;

  BLEDeviceModel({
    this.nameColor,
    this.name,
    this.address,
    this.alias,
    this.bondState,
    this.type,
    this.rssi,
    this.state,
    this.stateColor,
    this.pressure,
    this.preUnitTxt,
    this.temperature,
    this.temUnitTxt,
    this.battery,
    this.manufacturer,
  });

  factory BLEDeviceModel.fromJson(Map<String, dynamic> json) => BLEDeviceModel(
        nameColor: json['NameColor'],
        name: json['Name'],
        address: json['Address'],
        alias: json['Alias'],
        bondState: json['BondState'],
        type: json['Type'],
        rssi: json['Rssi'],
        state: json['State'],
        stateColor: json['StateColor'],
        pressure: json['Pressure'],
        preUnitTxt: json['PreUnitTxt'],
        temperature: json['Temperature'],
        temUnitTxt: json['TemUnitTxt'],
        battery: json['Battery'],
        manufacturer: json['_Manufacturer'] != null
            ? List<Manufacturer>.from(
                json['_Manufacturer'].map((x) => Manufacturer.fromJson(x)))
            : null,
      );

  Map<String, dynamic> toJson() => {
        'NameColor': nameColor,
        'Name': name,
        'Address': address,
        'Alias': alias,
        'BondState': bondState,
        'Type': type,
        'Rssi': rssi,
        'State': state,
        'StateColor': stateColor,
        'Pressure': pressure,
        'PreUnitTxt': preUnitTxt,
        'Temperature': temperature,
        'TemUnitTxt': temUnitTxt,
        'Battery': battery,
        '_Manufacturer':
            manufacturer != null ? manufacturer!.map((x) => x.toJson()).toList() : null,
      };
}

class Manufacturer {
  String? data;
  String? type;

  Manufacturer({this.data, this.type});

  factory Manufacturer.fromJson(Map<String, dynamic> json) => Manufacturer(
        data: json['Data'],
        type: json['Type'],
      );

  Map<String, dynamic> toJson() => {
        'Data': data,
        'Type': type,
      };
}