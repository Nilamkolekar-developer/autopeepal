

class AllModelsModel {
  int? count;
  dynamic next;
  dynamic previous;
  List<ModelResult>? results;
  String? message;

  AllModelsModel({this.count, this.next, this.previous, this.results, this.message});

  factory AllModelsModel.fromJson(Map<String, dynamic> json) => AllModelsModel(
        count: json['count'],
        next: json['next'],
        previous: json['previous'],
        results: json['results'] != null
            ? List<ModelResult>.from(json['results'].map((x) => ModelResult.fromJson(x)))
            : [],
        message: json['message'],
      );

  Map<String, dynamic> toJson() => {
        'count': count,
        'next': next,
        'previous': previous,
        'results': results != null ? results!.map((x) => x.toJson()).toList() : [],
        'message': message,
      };
}

class Dataset {
  int? id;
  String? code;

  Dataset({this.id, this.code});

  factory Dataset.fromJson(Map<String, dynamic> json) => Dataset(
        id: json['id'],
        code: json['code'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
      };
}

class PidDataset {
  int? id;
  String? code;

  PidDataset({this.id, this.code});

  factory PidDataset.fromJson(Map<String, dynamic> json) => PidDataset(
        id: json['id'],
        code: json['code'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
      };
}

class Protocol {
  String? name;
  String? elm;
  String? autopeepal;

  Protocol({this.name, this.elm, this.autopeepal});

  factory Protocol.fromJson(Map<String, dynamic> json) => Protocol(
        name: json['name'],
        elm: json['elm'],
        autopeepal: json['autopeepal'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'elm': elm,
        'autopeepal': autopeepal,
      };
}

class ReadDtcFnIndex {
  String? value;

  ReadDtcFnIndex({this.value});

  factory ReadDtcFnIndex.fromJson(Map<String, dynamic> json) => ReadDtcFnIndex(
        value: json['value'],
      );

  Map<String, dynamic> toJson() => {'value': value};
}

class ClearDtcFnIndex {
  String? value;

  ClearDtcFnIndex({this.value});

  factory ClearDtcFnIndex.fromJson(Map<String, dynamic> json) => ClearDtcFnIndex(
        value: json['value'],
      );

  Map<String, dynamic> toJson() => {'value': value};
}

class Ecu {
  int? id;
  String? name;
  String? txHeader;
  String? rxHeader;
  Protocol? protocol;
  List<Dataset>? datasets;
  List<PidDataset>? pidDatasets;
  ReadDtcFnIndex? readDtcFnIndex;
  ClearDtcFnIndex? clearDtcFnIndex;

  Ecu({
    this.id,
    this.name,
    this.txHeader,
    this.rxHeader,
    this.protocol,
    this.datasets,
    this.pidDatasets,
    this.readDtcFnIndex,
    this.clearDtcFnIndex,
  });

  factory Ecu.fromJson(Map<String, dynamic> json) => Ecu(
        id: json['id'],
        name: json['name'],
        txHeader: json['tx_header'],
        rxHeader: json['rx_header'],
        protocol: json['protocol'] != null ? Protocol.fromJson(json['protocol']) : null,
        datasets: json['datasets'] != null
            ? List<Dataset>.from(json['datasets'].map((x) => Dataset.fromJson(x)))
            : [],
        pidDatasets: json['pid_datasets'] != null
            ? List<PidDataset>.from(json['pid_datasets'].map((x) => PidDataset.fromJson(x)))
            : [],
        readDtcFnIndex: json['read_dtc_fn_index'] != null ? ReadDtcFnIndex.fromJson(json['read_dtc_fn_index']) : null,
        clearDtcFnIndex: json['clear_dtc_fn_index'] != null ? ClearDtcFnIndex.fromJson(json['clear_dtc_fn_index']) : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'tx_header': txHeader,
        'rx_header': rxHeader,
        'protocol': protocol?.toJson(),
        'datasets': datasets != null ? datasets!.map((x) => x.toJson()).toList() : [],
        'pid_datasets': pidDatasets != null ? pidDatasets!.map((x) => x.toJson()).toList() : [],
        'read_dtc_fn_index': readDtcFnIndex?.toJson(),
        'clear_dtc_fn_index': clearDtcFnIndex?.toJson(),
      };
}

class SubModel {
  int? id;
  String? name;
  String? modelYear;
  List<Ecu>? ecus;

  SubModel({this.id, this.name, this.modelYear, this.ecus});

  factory SubModel.fromJson(Map<String, dynamic> json) => SubModel(
        id: json['id'],
        name: json['name'],
        modelYear: json['model_year'],
        ecus: json['ecus'] != null ? List<Ecu>.from(json['ecus'].map((x) => Ecu.fromJson(x))) : [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'model_year': modelYear,
        'ecus': ecus != null ? ecus!.map((x) => x.toJson()).toList() : [],
      };
}

class ModelResult {
  int? id;
  String? name;
  List<SubModel>? subModels;

  ModelResult({this.id, this.name, this.subModels});

  factory ModelResult.fromJson(Map<String, dynamic> json) => ModelResult(
        id: json['id'],
        name: json['name'],
        subModels: json['sub_models'] != null ? List<SubModel>.from(json['sub_models'].map((x) => SubModel.fromJson(x))) : [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sub_models': subModels != null ? subModels!.map((x) => x.toJson()).toList() : [],
      };
}