
import 'package:autopeepal/logic/controller/diagnosticFunctions/liveParameterController.dart';
import 'package:get/get.dart';

class LiveparameterBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(Liveparametercontroller());
  }
}
