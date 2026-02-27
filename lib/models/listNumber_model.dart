class ListNumberRootModel {
  int? count;
  dynamic next;
  dynamic previous;
  List<ListNumberModel> results;
  String? message;

  ListNumberRootModel({
    this.count,
    this.next,
    this.previous,
    List<ListNumberModel>? results,
    this.message,
  }) : results = results ?? [];

  factory ListNumberRootModel.fromJson(Map<String, dynamic> json) => ListNumberRootModel(
        count: json['count'],
        next: json['next'],
        previous: json['previous'],
        results: (json['results'] as List<dynamic>?)
                ?.map((e) => ListNumberModel.fromJson(e))
                .toList() ??
            [],
        message: json['message'],
      );

  Map<String, dynamic> toJson() => {
        'count': count,
        'next': next,
        'previous': previous,
        'results': results.map((e) => e.toJson()).toList(),
        'message': message,
      };
}

class ListNumberModel {
  int? id;
  String? variantCode;
  String? description;
  int? oem;
  String? vinNo;
  String? isActive;
  int? vehicleModel;
  int? subModel;
  int? modelYear;
  List<VariantEcu> variantEcu;

  ListNumberModel({
    this.id,
    this.variantCode,
    this.description,
    this.oem,
    this.vinNo,
    this.isActive,
    this.vehicleModel,
    this.subModel,
    this.modelYear,
    List<VariantEcu>? variantEcu,
  }) : variantEcu = variantEcu ?? [];

  factory ListNumberModel.fromJson(Map<String, dynamic> json) => ListNumberModel(
        id: json['id'],
        variantCode: json['variant_code'],
        description: json['description'],
        oem: json['oem'],
        vinNo: json['vin_no'],
        isActive: json['is_active'],
        vehicleModel: json['vehicle_model'],
        subModel: json['sub_model'],
        modelYear: json['model_year'],
        variantEcu: (json['variant_ecu'] as List<dynamic>?)
                ?.map((e) => VariantEcu.fromJson(e))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'variant_code': variantCode,
        'description': description,
        'oem': oem,
        'vin_no': vinNo,
        'is_active': isActive,
        'vehicle_model': vehicleModel,
        'sub_model': subModel,
        'model_year': modelYear,
        'variant_ecu': variantEcu.map((e) => e.toJson()).toList(),
      };
}

class VariantEcu {
  int? id;
  int? ecu;
  DataFile? dataFile;
  bool? isLatest;
  bool? isActive;

  VariantEcu({this.id, this.ecu, this.dataFile, this.isLatest, this.isActive});

  factory VariantEcu.fromJson(Map<String, dynamic> json) => VariantEcu(
        id: json['id'],
        ecu: json['ecu'],
        dataFile: json['data_file'] != null ? DataFile.fromJson(json['data_file']) : null,
        isLatest: json['is_latest'],
        isActive: json['is_active'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'ecu': ecu,
        'data_file': dataFile?.toJson(),
        'is_latest': isLatest,
        'is_active': isActive,
      };
}

class DataFile {
  int? id;
  int? sequenceFileName;

  DataFile({this.id, this.sequenceFileName});

  factory DataFile.fromJson(Map<String, dynamic> json) => DataFile(
        id: json['id'],
        sequenceFileName: json['sequence_file_name'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'sequence_file_name': sequenceFileName,
      };
}