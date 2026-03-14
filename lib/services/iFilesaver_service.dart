import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

class IFileSaver {
  String? _folderPath;

  /// Pick folder once
  Future<void> selectFolder() async {
    try {
      _folderPath = await FilePicker.platform.getDirectoryPath();
      if (_folderPath != null) {
        print("Folder selected: $_folderPath");
      } else {
        print("No folder selected.");
      }
    } catch (e) {
      print("Error picking folder: $e");
    }
  }

  /// Save file content to the previously selected folder
  Future<void> saveFile(String fileContent, String fileName) async {
    try {
      if (_folderPath == null) {
        print("Folder not selected. Call selectFolder() first.");
        return;
      }

      final filePath = path.join(_folderPath!, fileName);
      final file = File(filePath);
      await file.writeAsString(fileContent);

      print("File saved successfully at $filePath");
    } catch (e) {
      print("Error saving file: $e");
    }
  }
}