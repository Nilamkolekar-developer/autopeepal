import 'package:flutter/foundation.dart';

class LanguageModel {
  int? id;
  String? language;

  // Reactive property for UI updates
  ValueNotifier<bool> isChecked;

  LanguageModel({this.id, this.language, bool? isChecked})
      : isChecked = ValueNotifier<bool>(isChecked ?? false);

  factory LanguageModel.fromJson(Map<String, dynamic> json) => LanguageModel(
        id: json['id'],
        language: json['Language'],
        isChecked: json['is_checked'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'Language': language,
        'is_checked': isChecked.value,
      };
}