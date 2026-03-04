import 'package:autopeepal/models/flashRecord_model.dart';

class AllModelsModel {
  int? count;
  dynamic next;
  dynamic previous;
  List<ModelResult>? results;
  String? message;

  AllModelsModel({
    this.count,
    this.next,
    this.previous,
    this.results,
    this.message,
  });

  factory AllModelsModel.fromJson(Map<String, dynamic> json) {
    return AllModelsModel(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: json['results'] != null
          ? (json['results'] as List)
              .map((e) => ModelResult.fromJson(e))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'count': count,
        'next': next,
        'previous': previous,
        'results': results?.map((e) => e.toJson()).toList(),
      };
}
class Dataset {
  int? id;
  String? code;

  Dataset({this.id, this.code});

  factory Dataset.fromJson(Map<String, dynamic> json) =>
      Dataset(id: json['id'], code: json['code']);

  Map<String, dynamic> toJson() => {'id': id, 'code': code};
}

class PidDataset extends Dataset {
  PidDataset({super.id, super.code});

  factory PidDataset.fromJson(Map<String, dynamic> json) =>
      PidDataset(id: json['id'], code: json['code']);
}

class IvnDtcDataset extends Dataset {
  IvnDtcDataset({super.id, super.code});

  factory IvnDtcDataset.fromJson(Map<String, dynamic> json) =>
      IvnDtcDataset(id: json['id'], code: json['code']);
}

class IvnPidDataset extends Dataset {
  IvnPidDataset({super.id, super.code});

  factory IvnPidDataset.fromJson(Map<String, dynamic> json) =>
      IvnPidDataset(id: json['id'], code: json['code']);
}
class Protocol {
  final String? name;
  final String? elm;
  final String? autopeepal;

  Protocol({
    this.name,
    this.elm,
    this.autopeepal,
  });

  // Optional: fromJson (recommended)
  factory Protocol.fromJson(Map<String, dynamic> json) {
    return Protocol(
      name: json['name'] as String?,
      elm: json['elm'] as String?,
      autopeepal: json['autopeepal'] as String?,
    );
  }

  // Optional: toJson
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'elm': elm,
      'autopeepal': autopeepal,
    };
  }
}
class FnIndex {
  String? value;

  FnIndex({this.value});

  factory FnIndex.fromJson(Map<String, dynamic> json) =>
      FnIndex(value: json['value']);

  Map<String, dynamic> toJson() => {'value': value};
}
class Ecu {
  int? id;
  String? name;
  String? txHeader;
  String? rxHeader;
  Protocol protocol;
  List<Dataset>? datasets;
  List<PidDataset>? pidDatasets;
  FnIndex? readDtcFnIndex;
  FnIndex? clearDtcFnIndex;
  FnIndex? readDataFnIndex;
  FnIndex? writeDataFnIndex;
  FnIndex? seedkeyalgoFnIndex;
  FnIndex? iorTestFnIndex;
  List<Ecu2>? ecu;

  double? opacity;
  String? channel;
  int? ffSet;
  int? noOfInjectors;
  String? firingSequence;

  Ecu({
    this.id,
    this.name,
    this.txHeader,
    this.rxHeader,
     required this.protocol,
    this.datasets,
    this.pidDatasets,
    this.readDtcFnIndex,
    this.clearDtcFnIndex,
    this.readDataFnIndex,
    this.writeDataFnIndex,
    this.seedkeyalgoFnIndex,
    this.iorTestFnIndex,
    this.ecu,
    this.opacity,
    this.channel,
    this.ffSet,
    this.noOfInjectors,
    this.firingSequence,
  });

  factory Ecu.fromJson(Map<String, dynamic> json) => Ecu(
      id: json['id'],
      name: json['name'],
      txHeader: json['tx_header'],
      rxHeader: json['rx_header'],
      protocol: json['protocol'] != null
          ? Protocol.fromJson(json['protocol'])
          : Protocol(name: "Default"), // <-- default value
      datasets: (json['datasets'] as List?)
          ?.map((e) => Dataset.fromJson(e))
          .toList(),
      pidDatasets: (json['pid_datasets'] as List?)
          ?.map((e) => PidDataset.fromJson(e))
          .toList(),
      readDtcFnIndex: json['read_dtc_fn_index'] != null
          ? FnIndex.fromJson(json['read_dtc_fn_index'])
          : null,
      clearDtcFnIndex: json['clear_dtc_fn_index'] != null
          ? FnIndex.fromJson(json['clear_dtc_fn_index'])
          : null,
      readDataFnIndex: json['read_data_fn_index'] != null
          ? FnIndex.fromJson(json['read_data_fn_index'])
          : null,
      writeDataFnIndex: json['write_data_fn_index'] != null
          ? FnIndex.fromJson(json['write_data_fn_index'])
          : null,
      seedkeyalgoFnIndex: json['seedkeyalgo_fn_index'] != null
          ? FnIndex.fromJson(json['seedkeyalgo_fn_index'])
          : null,
      iorTestFnIndex: json['ior_test_fn_index'] != null
          ? FnIndex.fromJson(json['ior_test_fn_index'])
          : null,
      ecu: (json['ecu'] as List?)?.map((e) => Ecu2.fromJson(e)).toList(),
      opacity: json['opacity']?.toDouble(),
      channel: json['channel'],
      ffSet: json['ff_set'],
      noOfInjectors: json['no_of_injectors'],
      firingSequence: json['firing_sequence'],
    );

  /// 🔼 Object → JSON (MAP)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tx_header': txHeader,
      'rx_header': rxHeader,
      'protocol': protocol?.toJson(),
      'datasets': datasets?.map((e) => e.toJson()).toList(),
      'pid_datasets': pidDatasets?.map((e) => e.toJson()).toList(),
      'read_dtc_fn_index': readDtcFnIndex?.toJson(),
      'clear_dtc_fn_index': clearDtcFnIndex?.toJson(),
      'read_data_fn_index': readDataFnIndex?.toJson(),
      'write_data_fn_index': writeDataFnIndex?.toJson(),
      'seedkeyalgo_fn_index': seedkeyalgoFnIndex?.toJson(),
      'ior_test_fn_index': iorTestFnIndex?.toJson(),
      'ecu': ecu?.map((e) => e.toJson()).toList(),
      'opacity': opacity,
      'channel': channel,
      'ff_set': ffSet,
      'no_of_injectors': noOfInjectors,
      'firing_sequence': firingSequence,
    };
  }
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
        ecus: (json['ecus'] as List?)
            ?.map((e) => Ecu.fromJson(e))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'model_year': modelYear,
        'ecus': ecus?.map((e) => e.toJson()).toList(),
      };
}
class ModelResult {
  int? id;
  String? name;
  List<SubModel>? subModels;

  ModelResult({
    this.id,
    this.name,
    this.subModels,
  });

  /// 🔽 JSON → Object
  factory ModelResult.fromJson(Map<String, dynamic> json) {
    return ModelResult(
      id: json['id'],
      name: json['name'],
      subModels: json['sub_models'] != null
          ? (json['sub_models'] as List)
              .map((e) => SubModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  /// 🔼 Object → JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sub_models': subModels?.map((e) => e.toJson()).toList(),
    };
  }
}

