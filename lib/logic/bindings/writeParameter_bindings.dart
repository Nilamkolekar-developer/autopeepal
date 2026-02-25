
import 'package:autopeepal/logic/controller/diagnosticFunctions/writeParameterController.dart';
import 'package:get/get.dart';

class WriteparameterBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(Writeparametercontroller());
  }
}
