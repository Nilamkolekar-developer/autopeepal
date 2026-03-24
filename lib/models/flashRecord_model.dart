class FlashRecordModel {
  int? count;
  dynamic next;
  dynamic previous;
  List<Ecu2>? results;
  String? message;

  FlashRecordModel({this.count, this.next, this.previous, this.results, this.message});

  factory FlashRecordModel.fromJson(Map<String, dynamic> json) => FlashRecordModel(
        count: json['count'],
        next: json['next'],
        previous: json['previous'],
        message: json['message'],
        results: json['results'] != null
            ? List<Ecu2>.from(json['results'].map((x) => Ecu2.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        'count': count,
        'next': next,
        'previous': previous,
        'message': message,
        'results': results?.map((x) => x.toJson()).toList(),
      };
}

class Ecu2 {
  int? id;
  int? ecu;
  String? sequenceFile;
  List<File>? file;
  List<EcuMapFile>? ecuMapFile;

  Ecu2({this.id, this.ecu, this.sequenceFile, this.file, this.ecuMapFile});

  factory Ecu2.fromJson(Map<String, dynamic> json) => Ecu2(
        id: json['id'],
        ecu: json['ecu'],
        sequenceFile: json['sequence_file'],
        file: json['file'] != null
            ? List<File>.from(json['file'].map((x) => File.fromJson(x)))
            : [],
        ecuMapFile: json['ecu_map_file'] != null
            ? List<EcuMapFile>.from(json['ecu_map_file'].map((x) => EcuMapFile.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'ecu': ecu,
        'sequence_file': sequenceFile,
        'file': file?.map((x) => x.toJson()).toList(),
        'ecu_map_file': ecuMapFile?.map((x) => x.toJson()).toList(),
      };
}

class File {
  int? id;
  String? dataFileName;
  String? dataFile;
  String? dwnldDataFile;

  File({
    this.id,
    this.dataFileName,
    this.dataFile,
    this.dwnldDataFile,
  });

  // Optional: factory constructor for JSON (if needed)
  factory File.fromJson(Map<String, dynamic> json) => File(
        id: json['id'],
        dataFileName: json['data_file_name'],
        dataFile: json['data_file'],
        dwnldDataFile: json['dwnld_data_file'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'data_file_name': dataFileName,
        'data_file': dataFile,
        'dwnld_data_file': dwnldDataFile,
      };
}

class EcuMapFile {
  int? id;
  String? endAddress;
  int? endAddr;
  String? sectorName;
  String? startAddress;
  int? startAddr;
  int? priority;

  EcuMapFile({
    this.id,
    this.endAddress,
    this.endAddr,
    this.sectorName,
    this.startAddress,
    this.startAddr,
    this.priority,
  });

  factory EcuMapFile.fromJson(Map<String, dynamic> json) => EcuMapFile(
        id: json['id'],
        endAddress: json['end_address'],
        endAddr: json['end_addr'],
        sectorName: json['sector_name'],
        startAddress: json['start_address'],
        startAddr: json['start_addr'],
        priority: json['priority'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'end_address': endAddress,
        'end_addr': endAddr,
        'sector_name': sectorName,
        'start_address': startAddress,
        'start_addr': startAddr,
        'priority': priority,
      };
}

class FlashSeqModel {
  int? ecu2id;
  String? sequenceLocalFile;
  String? sequenceUrl;
  List<File>? file;

  FlashSeqModel({this.ecu2id, this.sequenceLocalFile, this.sequenceUrl, this.file});

  factory FlashSeqModel.fromJson(Map<String, dynamic> json) => FlashSeqModel(
        ecu2id: json['ecu2id'],
        sequenceLocalFile: json['sequence_local_file'],
        sequenceUrl: json['sequence_url'],
        file: json['file'] != null
            ? List<File>.from(json['file'].map((x) => File.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        'ecu2id': ecu2id,
        'sequence_local_file': sequenceLocalFile,
        'sequence_url': sequenceUrl,
        'file': file?.map((x) => x.toJson()).toList(),
      };
}

class FlashData {
  Ecu2? ecu2;
  File? file;
  String? seqFileUrl;
  String? dwnldSeqFileUrl;
  String? seedkeyalgoFnIndexValues;
  List<EcuMapFile>? ecuMapFile;

  FlashData({
    this.ecu2,
    this.file,
    this.seqFileUrl,
    this.dwnldSeqFileUrl,
    this.seedkeyalgoFnIndexValues,
    this.ecuMapFile,
  });

  factory FlashData.fromJson(Map<String, dynamic> json) => FlashData(
        ecu2: json['ecu2'] != null ? Ecu2.fromJson(json['ecu2']) : null,
        file: json['file'] != null ? File.fromJson(json['file']) : null,
        seqFileUrl: json['seqFileUrl'],
        dwnldSeqFileUrl: json['dwnld_seqFileUrl'],
        seedkeyalgoFnIndexValues: json['SeedkeyalgoFnIndex_Values'],
        ecuMapFile: json['ecu_map_file'] != null
            ? List<EcuMapFile>.from(json['ecu_map_file'].map((x) => EcuMapFile.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        'ecu2': ecu2?.toJson(),
        'file': file?.toJson(),
        'seqFileUrl': seqFileUrl,
        'dwnld_seqFileUrl': dwnldSeqFileUrl,
        'SeedkeyalgoFnIndex_Values': seedkeyalgoFnIndexValues,
        'ecu_map_file': ecuMapFile?.map((x) => x.toJson()).toList(),
      };
}