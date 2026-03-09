import 'package:flutter/foundation.dart';

class FeatureModel extends ChangeNotifier {
  String? name;

  String? _image;
  String? get image => _image;
  set image(String? value) {
    _image = value;
    notifyListeners();
  }

  FeatureModel({this.name, String? image}) {
    _image = image;
  }

  factory FeatureModel.fromJson(Map<String, dynamic> json) => FeatureModel(
        name: json['name'],
        image: json['image'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'image': _image,
      };
}