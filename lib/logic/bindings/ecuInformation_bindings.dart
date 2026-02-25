import 'package:autopeepal/logic/controller/diagnosticFunctions/ecuInformationController.dart';
import 'package:get/get.dart';

class EcuinformationBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(Ecuinformationcontroller());
  }
}
