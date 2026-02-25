
// import 'package:autopeepalApp/utils/app_constants.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:autopeepal/utils/app_constants.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    Future.delayed(Duration(seconds: Constants.splashDelay), () {
      getScreen();
    });
    super.onInit();
  }

  Future<void> getScreen() async { 
       Get.offAndToNamed(Routes.loginScreen);
    }
     
  }