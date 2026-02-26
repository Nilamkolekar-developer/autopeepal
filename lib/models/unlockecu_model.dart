

class UnlockEcuModel {
  int? count;
  dynamic next;
  dynamic previous;
  List<ResultUnlock>? results;

  UnlockEcuModel({this.count, this.next, this.previous, this.results});

  factory UnlockEcuModel.fromJson(Map<String, dynamic> json) => UnlockEcuModel(
        count: json['count'],
        next: json['next'],
        previous: json['previous'],
        results: json['results'] != null
            ? List<ResultUnlock>.from(
                json['results'].map((x) => ResultUnlock.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        'count': count,
        'next': next,
        'previous': previous,
        'results': results?.map((x) => x.toJson()).toList(),
      };
}

class EcuUnlock {
  int? id;
  String? name;

  EcuUnlock({this.id, this.name});

  factory EcuUnlock.fromJson(Map<String, dynamic> json) => EcuUnlock(
        id: json['id'],
        name: json['name'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

class ResultUnlock {
  int? id;
  int? oem;
  int? model;
  int? submodel;
  int? year;
  EcuUnlock? ecu;
  Protocol? protocol;
  String? txId;
  String? txFrame;
  String? txFrequency;
  String? txTotalTime;
  String? rxId;
  String? rxFrame;
  String? isActive;

  ResultUnlock({
    this.id,
    this.oem,
    this.model,
    this.submodel,
    this.year,
    this.ecu,
    this.protocol,
    this.txId,
    this.txFrame,
    this.txFrequency,
    this.txTotalTime,
    this.rxId,
    this.rxFrame,
    this.isActive,
  });

  factory ResultUnlock.fromJson(Map<String, dynamic> json) => ResultUnlock(
        id: json['id'],
        oem: json['oem'],
        model: json['model'],
        submodel: json['submodel'],
        year: json['year'],
        ecu: json['ecu'] != null ? EcuUnlock.fromJson(json['ecu']) : null,
        protocol: json['protocol'] != null ? Protocol.fromJson(json['protocol']) : null,
        txId: json['tx_id'],
        txFrame: json['tx_frame'],
        txFrequency: json['tx_frequency'],
        txTotalTime: json['tx_total_time'],
        rxId: json['rx_id'],
        rxFrame: json['rx_frame'],
        isActive: json['is_active'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'oem': oem,
        'model': model,
        'submodel': submodel,
        'year': year,
        'ecu': ecu?.toJson(),
        'protocol': protocol?.toJson(),
        'tx_id': txId,
        'tx_frame': txFrame,
        'tx_frequency': txFrequency,
        'tx_total_time': txTotalTime,
        'rx_id': rxId,
        'rx_frame': rxFrame,
        'is_active': isActive,
      };
}

/// Replace this with your actual Protocol model in Dart
class Protocol {
  Protocol();

  factory Protocol.fromJson(Map<String, dynamic> json) => Protocol();
  Map<String, dynamic> toJson() => {};
}