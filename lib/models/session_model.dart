// import 'package:flutter/material.dart';

// class SessionLogsModel {
//   String? header;
//   String? message;
//   String? status;
//   Color? color;

//   SessionLogsModel({
//     this.header,
//     this.message,
//     this.status,
//     this.color,
//   });

//   /// Convert HEX string (e.g. #FF4CAF50) to Color
//   static Color? _colorFromHex(String? hex) {
//     if (hex == null || hex.isEmpty) return null;
//     final buffer = StringBuffer();
//     if (hex.length == 7) buffer.write('FF'); // add alpha if missing
//     buffer.write(hex.replaceFirst('#', ''));
//     return Color(int.parse(buffer.toString(), radix: 16));
//   }

//   /// Convert Color to HEX string
//   static String? _colorToHex(Color? color) {
//     if (color == null) return null;
//     return '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
//   }

//   factory SessionLogsModel.fromJson(Map<String, dynamic> json) =>
//       SessionLogsModel(
//         header: json['header'],
//         message: json['message'],
//         status: json['status'],
//         color: _colorFromHex(json['color']),
//       );

//   Map<String, dynamic> toJson() => {
//         'header': header,
//         'message': message,
//         'status': status,
//         'color': _colorToHex(color),
//       };
// }