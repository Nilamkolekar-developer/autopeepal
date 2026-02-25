import 'package:get/get.dart';

class DiagnosticController extends GetxController {
  RxString selectedModel = "Diesel".obs;
  RxString selectedRegulation = "BS6".obs;
  RxString selectedEcu = "EMS".obs;
  RxString status = "Connected".obs;
  RxString firmwareVersion = "v1.2.4".obs;
}
