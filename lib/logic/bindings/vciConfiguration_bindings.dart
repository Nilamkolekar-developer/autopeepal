import 'package:autopeepal/logic/controller/vciConfiguration/vciConfigurationController.dart';
import 'package:get/get.dart';

class VciconfigurationBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(Vciconfigurationcontroller());
  }
}
