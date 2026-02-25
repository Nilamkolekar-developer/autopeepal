
import 'package:autopeepal/logic/controller/diagnosticFunctions/dtcController.dart';
import 'package:get/get.dart';

class DTCBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(Dtccontroller());
  }
}
