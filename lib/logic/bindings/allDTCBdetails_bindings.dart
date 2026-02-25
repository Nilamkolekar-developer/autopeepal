
import 'package:autopeepal/logic/controller/diagnosticFunctions/allDtcDetailsController.dart';
import 'package:get/get.dart';

class AlldtcbdetailsBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(AllDTCDetailsController());
  }
}
