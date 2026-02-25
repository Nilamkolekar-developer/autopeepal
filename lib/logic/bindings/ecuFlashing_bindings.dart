
import 'package:autopeepal/logic/controller/diagnosticFunctions/ecuFlashingController.dart';
import 'package:get/get.dart';

class EcuflashingBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(Ecuflashingcontroller());
  }
}