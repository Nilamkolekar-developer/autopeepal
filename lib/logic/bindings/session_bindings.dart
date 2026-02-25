
import 'package:autopeepal/logic/controller/diagnosticFunctions/sessionController.dart';
import 'package:get/get.dart';

class SessionBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(SessionController());
  }
}