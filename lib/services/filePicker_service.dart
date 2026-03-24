import 'package:file_picker/file_picker.dart';
import 'dart:convert'; // for utf8 decoding

class FilePickerService {
  /// Mimics C# PickFileAsync returning (FileName, FileContent)
  Future<FileResult?> pickFileAsync() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true, // get file bytes to convert to string
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;

      if (file.name.isNotEmpty && file.bytes != null) {
        return FileResult(
          fileName: file.name,
          fileContent: utf8.decode(file.bytes!), // convert bytes to string
        );
      }
    }

    return null; // user canceled or empty file
  }
}

class FileResult {
  final String fileName;
  final String fileContent; // now string just like C#

  FileResult({
    required this.fileName,
    required this.fileContent,
  });
}