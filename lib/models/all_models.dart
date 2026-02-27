import 'dart:io';

import 'package:flutter/material.dart';

class AllModelsModel {
  int? count;
  dynamic next;
  dynamic previous;
  List<ModelResult>? results;
  String? message;

  AllModelsModel(
      {this.count, this.next, this.previous, this.results, this.message});

  factory AllModelsModel.fromJson(Map<String, dynamic> json) => AllModelsModel(
        count: json['count'],
        next: json['next'],
        previous: json['previous'],
        results: json['results'] != null
            ? List<ModelResult>.from(
                json['results'].map((x) => ModelResult.fromJson(x)))
            : [],
        message: json['message'],
      );

  Map<String, dynamic> toJson() => {
        'count': count,
        'next': next,
        'previous': previous,
        'results':
            results != null ? results!.map((x) => x.toJson()).toList() : [],
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

  factory ClearDtcFnIndex.fromJson(Map<String, dynamic> json) =>
      ClearDtcFnIndex(
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
        protocol: json['protocol'] != null
            ? Protocol.fromJson(json['protocol'])
            : null,
        datasets: json['datasets'] != null
            ? List<Dataset>.from(
                json['datasets'].map((x) => Dataset.fromJson(x)))
            : [],
        pidDatasets: json['pid_datasets'] != null
            ? List<PidDataset>.from(
                json['pid_datasets'].map((x) => PidDataset.fromJson(x)))
            : [],
        readDtcFnIndex: json['read_dtc_fn_index'] != null
            ? ReadDtcFnIndex.fromJson(json['read_dtc_fn_index'])
            : null,
        clearDtcFnIndex: json['clear_dtc_fn_index'] != null
            ? ClearDtcFnIndex.fromJson(json['clear_dtc_fn_index'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'tx_header': txHeader,
        'rx_header': rxHeader,
        'protocol': protocol?.toJson(),
        'datasets':
            datasets != null ? datasets!.map((x) => x.toJson()).toList() : [],
        'pid_datasets': pidDatasets != null
            ? pidDatasets!.map((x) => x.toJson()).toList()
            : [],
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
        ecus: json['ecus'] != null
            ? List<Ecu>.from(json['ecus'].map((x) => Ecu.fromJson(x)))
            : [],
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
        subModels: json['sub_models'] != null
            ? List<SubModel>.from(
                json['sub_models'].map((x) => SubModel.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sub_models':
            subModels != null ? subModels!.map((x) => x.toJson()).toList() : [],
      };
}

class FlashEcusModel extends ChangeNotifier {
  int? id;
  String? ecuName;

  double _opacity = 1.0;
  double get opacity => _opacity;
  set opacity(double value) {
    _opacity = value;
    notifyListeners();
  }

  List<File>? _flashFileList;
  List<File>? get flashFileList => _flashFileList;
  set flashFileList(List<File>? value) {
    _flashFileList = value;
    notifyListeners();
  }

  List<EcuMapFile>? ecuMapFile;
  String? seedkeyalgoFnIndexValues;

  Ecu2? ecu2;
  String? txHeader;
  String? rxHeader;
  Protocol? protocol;

  FlashEcusModel({
    this.id,
    this.ecuName,
    double? opacity,
    List<File>? flashFileList,
    this.ecuMapFile,
    this.seedkeyalgoFnIndexValues,
    this.ecu2,
    this.txHeader,
    this.rxHeader,
    this.protocol,
  }) {
    if (opacity != null) _opacity = opacity;
    _flashFileList = flashFileList;
  }

  factory FlashEcusModel.fromJson(Map<String, dynamic> json) => FlashEcusModel(
        id: json['id'],
        ecuName: json['ecu_name'],
        opacity: json['opacity']?.toDouble(),
        // For flashFileList, you may handle File separately depending on your use case
        ecuMapFile: json['ecu_map_file'] != null
            ? List<EcuMapFile>.from(
                json['ecu_map_file'].map((x) => EcuMapFile.fromJson(x)))
            : null,
        seedkeyalgoFnIndexValues: json['SeedkeyalgoFnIndex_Values'],
        ecu2: json['ecu2'] != null ? Ecu2.fromJson(json['ecu2']) : null,
        txHeader: json['txHeader'],
        rxHeader: json['rxHeader'],
        protocol: json['protocol'] != null
            ? Protocol.fromJson(json['protocol'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'ecu_name': ecuName,
        'opacity': _opacity,
        'ecu_map_file': ecuMapFile != null
            ? ecuMapFile!.map((x) => x.toJson()).toList()
            : null,
        'SeedkeyalgoFnIndex_Values': seedkeyalgoFnIndexValues,
        'ecu2': ecu2?.toJson(),
        'txHeader': txHeader,
        'rxHeader': rxHeader,
        'protocol': protocol?.toJson(),
      };
}

class UnlockModel extends ChangeNotifier {
  String? ecuName;

  double _opacity = 1.0;
  double get opacity => _opacity;
  set opacity(double value) {
    _opacity = value;
    notifyListeners();
  }

  String? txHeader;
  String? rxHeader;

  Protocol? protocol;
  Ecu2? ecu2;

  UnlockModel({
    this.ecuName,
    double? opacity,
    this.txHeader,
    this.rxHeader,
    this.protocol,
    this.ecu2,
  }) {
    if (opacity != null) _opacity = opacity;
  }

  factory UnlockModel.fromJson(Map<String, dynamic> json) => UnlockModel(
        ecuName: json['ecu_name'],
        opacity: json['opacity']?.toDouble(),
        txHeader: json['tx_header'],
        rxHeader: json['rx_header'],
        protocol: json['protocol'] != null
            ? Protocol.fromJson(json['protocol'])
            : null,
        ecu2: json['ecu2'] != null ? Ecu2.fromJson(json['ecu2']) : null,
      );

  Map<String, dynamic> toJson() => {
        'ecu_name': ecuName,
        'opacity': _opacity,
        'tx_header': txHeader,
        'rx_header': rxHeader,
        'protocol': protocol?.toJson(),
        'ecu2': ecu2?.toJson(),
      };
}

// Placeholder classes for Ecu2, Protocol, EcuMapFile
class Ecu2 {
  Ecu2();
  factory Ecu2.fromJson(Map<String, dynamic> json) => Ecu2();
  Map<String, dynamic> toJson() => {};
}

class EcuMapFile {
  EcuMapFile();
  factory EcuMapFile.fromJson(Map<String, dynamic> json) => EcuMapFile();
  Map<String, dynamic> toJson() => {};
}
