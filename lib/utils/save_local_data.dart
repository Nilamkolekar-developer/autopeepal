// import 'dart:io';
// import 'package:path_provider/path_provider.dart';

// class SaveLocalData {
//   // /// Save data to a local text file
//   // static Future<void> saveData(String fileName, String data) async {
//   //   try {
//   //     final directory = await getApplicationDocumentsDirectory();
//   //     final file = File('${directory.path}/$fileName.txt');

//   //     await file.writeAsString(data);
//   //   } catch (e) {
//   //     print('SaveData Error: $e');
//   //   }
//   // }
//   Future<void> saveData(String fileName, String data) async {
//   try {
//     // Get the documents directory
//     final directory = await getApplicationDocumentsDirectory();

//     // Ensure directory exists
//     await Directory(directory.path).create(recursive: true);

//     // Create file path
//     final filePath = '${directory.path}/$fileName.txt';
//     final file = File(filePath);

//     // Write data asynchronously
//     await file.writeAsString(data, flush: true);

//     print('Data saved to $filePath');
//   } catch (e) {
//     print('Error saving data: $e');
//   }
// }

//   // /// Read data from a local text file
//   // static Future<String> getData(String fileName) async {
//   //   try {
//   //     final directory = await getApplicationDocumentsDirectory();
//   //     final file = File('${directory.path}/$fileName.txt');

//   //     if (!await file.exists()) {
//   //       return '';
//   //     }

//   //     return await file.readAsString();
//   //   } catch (e) {
//   //     print('GetData Error: $e');
//   //     return '';
//   //   }
//   // }

//   Future<String> getData(String fileName) async {
//   try {
//     // Get the documents directory
//     final directory = await getApplicationDocumentsDirectory();

//     // Build the file path
//     final filePath = '${directory.path}/$fileName.txt';
//     final file = File(filePath);

//     // Check if file exists
//     if (!await file.exists()) {
//       return '';
//     }

//     // Read file line by line
//     final lines = await file.readAsLines();
//     final buffer = StringBuffer();
//     for (var line in lines) {
//       buffer.writeln(line);
//     }

//     return buffer.toString();
//   } catch (e) {
//     print('Error reading data: $e');
//     return '';
//   }
// }

//   /// Optional: delete file
//   static Future<void> deleteData(String fileName) async {
//     try {
//       final directory = await getApplicationDocumentsDirectory();
//       final file = File('${directory.path}/$fileName.txt');

//       if (await file.exists()) {
//         await file.delete();
//       }
//     } catch (e) {
//       print('DeleteData Error: $e');
//     }
//   }
// }
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class SaveLocalData {
  /// Build a user-specific file name
  String _getUserFileName(String fileName, {String? username}) {
    return username != null ? '${username}_$fileName.txt' : '$fileName.txt';
  }

  /// Save data to a local text file
  Future<void> saveData(String fileName, String data, {String? username}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      // Ensure directory exists
      await Directory(directory.path).create(recursive: true);

      // Create file path
      final filePath = '${directory.path}/${_getUserFileName(fileName, username: username)}';
      final file = File(filePath);

      // DEBUG: Print what we are saving
      print('--- SAVE DATA DEBUG ---');
      print('User: $username');
      print('File Path: $filePath');
      print('Data: $data');
      print('-----------------------');

      // Write data asynchronously
      await file.writeAsString(data, flush: true);

      print('Data saved successfully to $filePath');
    } catch (e) {
      print('Error saving data: $e');
    }
  }

  /// Read data from a local text file
  Future<String> getData(String fileName, {String? username}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      // Build the file path
      final filePath = '${directory.path}/${_getUserFileName(fileName, username: username)}';
      final file = File(filePath);

      // DEBUG: Print which file we are trying to read
      print('--- GET DATA DEBUG ---');
      print('User: $username');
      print('File Path: $filePath');

      if (!await file.exists()) {
        print('File does not exist.');
        return '';
      }

      final lines = await file.readAsLines();
      final buffer = StringBuffer();
      for (var line in lines) {
        buffer.writeln(line);
      }

      // DEBUG: Print the data we read
      print('Data read:\n${buffer.toString()}');
      print('-----------------------');

      return buffer.toString();
    } catch (e) {
      print('Error reading data: $e');
      return '';
    }
  }

  /// Optional: delete file
  static Future<void> deleteData(String fileName, {String? username}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${username != null ? '${username}_$fileName.txt' : '$fileName.txt'}';
      final file = File(filePath);

      if (await file.exists()) {
        await file.delete();
        print('Deleted file: $filePath');
      } else {
        print('File not found to delete: $filePath');
      }
    } catch (e) {
      print('DeleteData Error: $e');
    }
  }
}