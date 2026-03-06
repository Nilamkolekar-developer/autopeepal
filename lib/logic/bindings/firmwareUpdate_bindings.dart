import 'package:autopeepal/logic/controller/diagnosticFunctions/firmwareVersionController.dart';
import 'package:get/get.dart';

class FirmwareupdateBindings extends Bindings{
  @override
  void dependencies() {
   Get.put(SettingsController());
  }
}