
import 'package:autopeepal/logic/controller/diagnosticFunctions/routineTestController.dart';
import 'package:get/get.dart';

class RoutinetestBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(Routinetestcontroller());
  }
}