import 'dart:io';
import 'package:path_provider/path_provider.dart';

class SaveLocalData {
  /// Save data to a local text file
  static Future<void> saveData(String fileName, String data) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName.txt');

      await file.writeAsString(data);
    } catch (e) {
      print('SaveData Error: $e');
    }
  }

  /// Read data from a local text file
  static Future<String> getData(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName.txt');

      if (!await file.exists()) {
        return '';
      }

      return await file.readAsString();
    } catch (e) {
      print('GetData Error: $e');
      return '';
    }
  }

  /// Optional: delete file
  static Future<void> deleteData(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName.txt');

      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('DeleteData Error: $e');
    }
  }
}