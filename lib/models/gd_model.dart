import 'package:autopeepal/models/dtc_model.dart';

class GdImageGD {
  int? id;
  String? imageName;
  String? gdImage;

  GdImageGD({this.id, this.imageName, this.gdImage});

  factory GdImageGD.fromJson(Map<String, dynamic> json) => GdImageGD(
        id: json['id'],
        imageName: json['image_name'],
        gdImage: json['gd_image'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'image_name': imageName,
        'gd_image': gdImage,
      };
}

class ImageGD {
  bool? isActive;
  String? image;

  ImageGD({this.isActive, this.image});

  factory ImageGD.fromJson(Map<String, dynamic> json) => ImageGD(
        isActive: json['is_active'],
        image: json['image'],
      );

  Map<String, dynamic> toJson() => {
        'is_active': isActive,
        'image': image,
      };
}

class GroupGD {
  String? upperLimit;
  String? lowerLimit;
  String? unit;
  String? entryDescription;
  String? groupName;

  GroupGD(
      {this.upperLimit,
      this.lowerLimit,
      this.unit,
      this.entryDescription,
      this.groupName});

  factory GroupGD.fromJson(Map<String, dynamic> json) => GroupGD(
        upperLimit: json['upper_limit'],
        lowerLimit: json['lower_limit'],
        unit: json['unit'],
        entryDescription: json['entry_description'],
        groupName: json['group_name'],
      );

  Map<String, dynamic> toJson() => {
        'upper_limit': upperLimit,
        'lower_limit': lowerLimit,
        'unit': unit,
        'entry_description': entryDescription,
        'group_name': groupName,
      };
}

class TypeFormGD {
  String? description;
  String? topic;
  List<String>? entryGroupNames;
  List<GroupGD>? groups;
  List<String>? entryGroups;

  TypeFormGD(
      {this.description,
      this.topic,
      this.entryGroupNames,
      this.groups,
      this.entryGroups});

  factory TypeFormGD.fromJson(Map<String, dynamic> json) => TypeFormGD(
        description: json['description'],
        topic: json['topic'],
        entryGroupNames: json['entry_group_names'] != null
            ? List<String>.from(json['entry_group_names'])
            : [],
        groups: json['groups'] != null
            ? List<GroupGD>.from(json['groups'].map((x) => GroupGD.fromJson(x)))
            : [],
        entryGroups: json['entry_groups'] != null
            ? List<String>.from(json['entry_groups'])
            : [],
      );

  Map<String, dynamic> toJson() => {
        'description': description,
        'topic': topic,
        'entry_group_names': entryGroupNames,
        'groups': groups?.map((x) => x.toJson()).toList(),
        'entry_groups': entryGroups,
      };
}

class DatumGD {
  String? textVal;
  int? node;
  String? type;

  DatumGD({this.textVal, this.node, this.type});

  factory DatumGD.fromJson(Map<String, dynamic> json) => DatumGD(
        textVal: json['text_val'],
        node: json['node'],
        type: json['type'],
      );

  Map<String, dynamic> toJson() => {
        'text_val': textVal,
        'node': node,
        'type': type,
      };
}

class DecisionsGD {
  String? type;
  List<DatumGD>? data;

  DecisionsGD({this.type, this.data});

  factory DecisionsGD.fromJson(Map<String, dynamic> json) => DecisionsGD(
        type: json['type'],
        data: json['data'] != null
            ? List<DatumGD>.from(json['data'].map((x) => DatumGD.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'data': data?.map((x) => x.toJson()).toList(),
      };
}

class DataGD {
  String? exitScript;
  List<ImageGD>? images;
  String? topic;
  bool? isActive;
  String? entryScript;
  TypeFormGD? typeForm;
  String? type;
  String? description;
  DecisionsGD? decisions;
  String? id;
  List<dynamic>? globals;

  DataGD({
    this.exitScript,
    this.images,
    this.topic,
    this.isActive,
    this.entryScript,
    this.typeForm,
    this.type,
    this.description,
    this.decisions,
    this.id,
    this.globals,
  });

  factory DataGD.fromJson(Map<String, dynamic> json) => DataGD(
        exitScript: json['exit_script'],
        images: json['images'] != null
            ? List<ImageGD>.from(json['images'].map((x) => ImageGD.fromJson(x)))
            : [],
        topic: json['topic'],
        isActive: json['is_active'],
        entryScript: json['entry_script'],
        typeForm: json['type_form'] != null
            ? TypeFormGD.fromJson(json['type_form'])
            : null,
        type: json['type'],
        description: json['description'],
        decisions: json['decisions'] != null
            ? DecisionsGD.fromJson(json['decisions'])
            : null,
        id: json['id'],
        globals:
            json['globals'] != null ? List<dynamic>.from(json['globals']) : [],
      );

  Map<String, dynamic> toJson() => {
        'exit_script': exitScript,
        'images': images?.map((x) => x.toJson()).toList(),
        'topic': topic,
        'is_active': isActive,
        'entry_script': entryScript,
        'type_form': typeForm?.toJson(),
        'type': type,
        'description': description,
        'decisions': decisions?.toJson(),
        'id': id,
        'globals': globals,
      };
}

class TreeDataGD {
  int? parent;
  DataGD? data;
  String? name;
  int? id;
  String? description;

  TreeDataGD({this.parent, this.data, this.name, this.id, this.description});

  factory TreeDataGD.fromJson(Map<String, dynamic> json) => TreeDataGD(
        parent: json['parent'],
        data: json['data'] != null ? DataGD.fromJson(json['data']) : null,
        name: json['name'],
        id: json['id'],
        description: json['description'],
      );

  Map<String, dynamic> toJson() => {
        'parent': parent,
        'data': data?.toJson(),
        'name': name,
        'id': id,
        'description': description,
      };
}

class TreeSetGD {
  int? id;
  String? treeId;
  String? vehicleModel;
  String? model;
  String? treeDescription;
  List<TreeDataGD>? treeData;
  String? isActive;

  TreeSetGD({
    this.id,
    this.treeId,
    this.vehicleModel,
    this.model,
    this.treeDescription,
    this.treeData,
    this.isActive,
  });

  factory TreeSetGD.fromJson(Map<String, dynamic> json) => TreeSetGD(
        id: json['id'],
        treeId: json['tree_id'],
        vehicleModel: json['vehicle_model'],
        model: json['model'],
        treeDescription: json['tree_description'],
        treeData: json['tree_data'] != null
            ? List<TreeDataGD>.from(
                json['tree_data'].map((x) => TreeDataGD.fromJson(x)))
            : [],
        isActive: json['is_active'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'tree_id': treeId,
        'vehicle_model': vehicleModel,
        'model': model,
        'tree_description': treeDescription,
        'tree_data': treeData?.map((x) => x.toJson()).toList(),
        'is_active': isActive,
      };
}

class DtcGD {
  int? id;
  DtcCode? code;

  DtcGD({this.id, this.code});

  factory DtcGD.fromJson(Map<String, dynamic> json) => DtcGD(
        id: json['id'],
        code: json['code'] != null ? DtcCode.fromJson(json['code']) : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code?.toJson(),
      };
}

class ResultGD {
  int? id;
  String? gdId;
  int? name;
  String? model;
  int? modelYear;
  String? gdDescription;
  String? occurringConditions;
  String? effectsOnVehicle;
  String? causes;
  String? ecuName;
  String? remedialActions;
  String? isActive;
  List<GdImageGD>? gdImages;
  List<TreeSetGD>? treeSet;
  List<DtcGD>? dtc;

  ResultGD({
    this.id,
    this.gdId,
    this.name,
    this.model,
    this.modelYear,
    this.gdDescription,
    this.occurringConditions,
    this.effectsOnVehicle,
    this.causes,
    this.ecuName,
    this.remedialActions,
    this.isActive,
    this.gdImages,
    this.treeSet,
    this.dtc,
  });

  factory ResultGD.fromJson(Map<String, dynamic> json) => ResultGD(
        id: json['id'],
        gdId: json['gd_id'],
        name: json['name'],
        model: json['model'],
        modelYear: json['model_year'],
        gdDescription: json['gd_description'],
        occurringConditions: json['occurring_conditions'],
        effectsOnVehicle: json['effects_on_vehicle'],
        causes: json['causes'],
        ecuName: json['ecu_name'],
        remedialActions: json['remedial_actions'],
        isActive: json['is_active'],
        gdImages: json['gd_images'] != null
            ? List<GdImageGD>.from(
                json['gd_images'].map((x) => GdImageGD.fromJson(x)))
            : [],
        treeSet: json['tree_set'] != null
            ? List<TreeSetGD>.from(
                json['tree_set'].map((x) => TreeSetGD.fromJson(x)))
            : [],
        dtc: json['dtc'] != null
            ? List<DtcGD>.from(json['dtc'].map((x) => DtcGD.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'gd_id': gdId,
        'name': name,
        'model': model,
        'model_year': modelYear,
        'gd_description': gdDescription,
        'occurring_conditions': occurringConditions,
        'effects_on_vehicle': effectsOnVehicle,
        'causes': causes,
        'ecu_name': ecuName,
        'remedial_actions': remedialActions,
        'is_active': isActive,
        'gd_images': gdImages?.map((x) => x.toJson()).toList(),
        'tree_set': treeSet?.map((x) => x.toJson()).toList(),
        'dtc': dtc?.map((x) => x.toJson()).toList(),
      };
}

class GdModelGD {
  int? count;
  dynamic next;
  dynamic previous;
  List<ResultGD>? results;
  String? message;

  GdModelGD({this.count, this.next, this.previous, this.results, this.message});

  factory GdModelGD.fromJson(Map<String, dynamic> json) => GdModelGD(
        count: json['count'],
        next: json['next'],
        previous: json['previous'],
        results: json['results'] != null
            ? List<ResultGD>.from(
                json['results'].map((x) => ResultGD.fromJson(x)))
            : [],
        message: json['message'],
      );

  Map<String, dynamic> toJson() => {
        'count': count,
        'next': next,
        'previous': previous,
        'results': results?.map((x) => x.toJson()).toList(),
        'message': message,
      };
}
