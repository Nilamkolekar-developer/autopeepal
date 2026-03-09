import 'dart:io';
import 'package:path_provider/path_provider.dart';

class SaveLocalData {
  // /// Save data to a local text file
  // static Future<void> saveData(String fileName, String data) async {
  //   try {
  //     final directory = await getApplicationDocumentsDirectory();
  //     final file = File('${directory.path}/$fileName.txt');

  //     await file.writeAsString(data);
  //   } catch (e) {
  //     print('SaveData Error: $e');
  //   }
  // }
  Future<void> saveData(String fileName, String data) async {
  try {
    // Get the documents directory
    final directory = await getApplicationDocumentsDirectory();

    // Ensure directory exists
    await Directory(directory.path).create(recursive: true);

    // Create file path
    final filePath = '${directory.path}/$fileName.txt';
    final file = File(filePath);

    // Write data asynchronously
    await file.writeAsString(data, flush: true);

    print('Data saved to $filePath');
  } catch (e) {
    print('Error saving data: $e');
  }
}

  // /// Read data from a local text file
  // static Future<String> getData(String fileName) async {
  //   try {
  //     final directory = await getApplicationDocumentsDirectory();
  //     final file = File('${directory.path}/$fileName.txt');

  //     if (!await file.exists()) {
  //       return '';
  //     }

  //     return await file.readAsString();
  //   } catch (e) {
  //     print('GetData Error: $e');
  //     return '';
  //   }
  // }

  Future<String> getData(String fileName) async {
  try {
    // Get the documents directory
    final directory = await getApplicationDocumentsDirectory();

    // Build the file path
    final filePath = '${directory.path}/$fileName.txt';
    final file = File(filePath);

    // Check if file exists
    if (!await file.exists()) {
      return '';
    }

    // Read file line by line
    final lines = await file.readAsLines();
    final buffer = StringBuffer();
    for (var line in lines) {
      buffer.writeln(line);
    }

    return buffer.toString();
  } catch (e) {
    print('Error reading data: $e');
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