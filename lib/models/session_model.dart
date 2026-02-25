import 'package:flutter/material.dart';

class SessionLogsModel {
  String header;
  String message;
  String status;
  Color color;

  SessionLogsModel({
    required this.header,
    required this.message,
    required this.status,
    required this.color,
  });
}