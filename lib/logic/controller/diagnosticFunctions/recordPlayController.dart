import 'package:get/get.dart';

class RecordPlayController extends GetxController {
  var isRecording = false.obs;
  var isPlaying = false.obs;

  void toggleRecord() {
    isRecording.value = !isRecording.value;

    // If recording starts, stop playing
    if (isRecording.value) {
      isPlaying.value = false;
    }
  }

  void togglePlay() {
    isPlaying.value = !isPlaying.value;

    // If playing starts, stop recording
    if (isPlaying.value) {
      isRecording.value = false;
    }
  }
}