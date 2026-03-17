import 'package:autopeepal/logic/controller/auth/registerController.dart';
import 'package:get/get.dart';

class RegisterBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(RegistrationController());
  }
}