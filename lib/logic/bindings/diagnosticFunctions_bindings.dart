
import 'package:autopeepal/logic/controller/diagnosticFunctions/diagnosticFunctionsController.dart';
import 'package:get/get.dart';

class DiagnosticfunctionsBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(DiagnosticController());
  }
}
