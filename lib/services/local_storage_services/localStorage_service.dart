import 'dart:io';

import 'package:path_provider/path_provider.dart';

class LocalStorage {
  Future<String> get _localPath async => (await getApplicationDocumentsDirectory()).path;

  Future<File> _localFile(String fileName) async => File('${await _localPath}/$fileName.json');

  Future<void> saveData(String fileName, String data) async {
    final file = await _localFile(fileName);
    await file.writeAsString(data);
  }

  Future<String?> getData(String fileName) async {
    final file = await _localFile(fileName);
    if (await file.exists()) return await file.readAsString();
    return null;
  }
}