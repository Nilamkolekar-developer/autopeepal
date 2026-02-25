import 'package:autopeepal/logic/controller/auth/loginController.dart';
import 'package:get/get.dart';

class LoginBindings extends Bindings{
  @override
  void dependencies() {
   Get.put(LoginController());
  }
  
}