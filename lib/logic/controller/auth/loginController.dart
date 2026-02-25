
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';


class LoginController extends GetxController {
 @override
void onInit() {
  super.onInit();

  String? savedUser = box.read('username');
  String? savedPass = box.read('password');

  if (savedUser != null && savedPass != null) {
    usernameController.value.text = savedUser;
    passwordController.value.text = savedPass;
    rememberMe.value = true;
  }
}
 Rx<TextEditingController> usernameController = TextEditingController().obs;
  Rx<TextEditingController> passwordController = TextEditingController().obs;
 
  Rx<TextEditingController> forgetEmailController = TextEditingController().obs;
  Rx<TextEditingController> verifyOTPController = TextEditingController().obs;
  RxBool hidePassword = true.obs;
  RxString verifyEmail = "".obs;
  RxBool rememberMe = false.obs;

  final box = GetStorage();

void saveCredentials() {
  box.write('username', usernameController.value.text);
  box.write('password', passwordController.value.text);
}

void clearSavedCredentials() {
  box.remove('username');
  box.remove('password');
}

  // login() async {
  //   Map<String, dynamic> postData = Map();
  //   postData.add(key: APIKeys.username, value: usernameController.value.text);
  //   postData.add(key: APIKeys.password, value: passwordController.value.text);
  //   Map<String, dynamic> responseData =
  //       await AppAPIs.post(AppURLs.login, data: postData);

  //   try {
  //     if (responseData.getMap("message").getBool("success")) {
  //       String tokenGet = responseData
  //           .getMap("message")
  //           .getMap("data")
  //           .getString("Authorization");

  //       await AppPreferences.setToken(tokenGet);
  //       await AppPreferences.setUserData(
  //           responseData.getMap("message").getMap("data").getMap("user_data"));
  //       await auth.loadUser();
  //       getPermission(auth.currentUser.name!);
  //       // Get.offAndToNamed(Routes.dashboardScreen);
  //     } else {
  //       AppTostMassage.showTostMassage(
  //           massage: responseData.getMap("message").getString("error"));
  //     }
  //   } catch (e) {
  //     AppTostMassage.showTostMassage(massage: e.toString());
  //   }
  // }

  // forgetpassword() async {
  //   Map<String, dynamic> postData = Map();
  //   postData.add(key: APIKeys.email, value: forgetEmailController.value.text);
  //   Map<String, dynamic> responseData =
  //       await AppAPIs.post(AppURLs.forgetpassword, data: postData);

  //   try {
  //     if (responseData.getMap("message").getInt("status_code") == 200) {
  //       appLogs(responseData.toPretty());
  //       await AppPreferences.setToken(responseData
  //           .getMap("message")
  //           .getMap("data")
  //           .getString("Authorization"));
  //       AppTostMassage.showTostMassage(
  //           massage: responseData.getMap("message").getString("msg"));
  //       verifyEmail.value =
  //           responseData.getMap("message").getMap("data").getString("email");

  //       // Get.offAndToNamed(Routes.verifyOTP, arguments: {
  //       //   'email': verifyEmail.value,
  //       // });
  //     } else if (responseData.getMap("message").getInt("status_code") == 404) {
  //       AppTostMassage.showTostMassage(
  //           massage: responseData.getMap("message").getString("msg"));
  //     } else {
  //       AppTostMassage.showTostMassage(
  //           massage: responseData.getMap("message").getString("msg"));
  //     }
  //   } catch (e) {
  //     AppTostMassage.showTostMassage(massage: e.toString());
  //   }
  // }

  // verifyOTP(String email) async {
  //   Map<String, dynamic> postData = Map();
  //   postData.add(key: APIKeys.email, value: email);
  //   postData.add(key: APIKeys.otp, value: verifyOTPController.value.text);
  //   Map<String, dynamic> responseData =
  //       await AppAPIs.post(AppURLs.verifyOTP, data: postData);

  //   try {
  //     if (responseData.getMap("message").getInt("status_code") == 200) {
  //       appLogs(responseData.toPretty());
  //       await AppPreferences.setToken(responseData
  //           .getMap("message")
  //           .getMap("data")
  //           .getString("Authorization"));
  //       AppTostMassage.showTostMassage(
  //           massage: responseData.getMap("message").getString("msg"));
  //     } else if (responseData.getMap("message").getInt("status_code") == 400) {
  //       AppTostMassage.showTostMassage(
  //           massage: responseData.getMap("message").getString("msg"));
  //     } else if (responseData.getMap("message").getInt("status_code") == 401) {
  //       AppTostMassage.showTostMassage(
  //           massage: responseData.getMap("message").getString("msg"));
  //     } else {
  //       AppTostMassage.showTostMassage(
  //           massage: responseData.getMap("message").getString("msg"));
  //     }
  //   } catch (e) {
  //     AppTostMassage.showTostMassage(massage: e.toString());
  //   }
  // }

  // Future<void> getPermission(String emp_id) async {
  //   Map<String, dynamic> responseData =
  //       await AppAPIs.get(AppURLs.permission(emp_id: emp_id));
  //   print(responseData.toPretty());
  //   try {
  //     await AppPreferences.savePermissionData(responseData.getMap("message"));

  //     await permissionService.loadPermissions();

  //     Get.offAndToNamed(Routes.dashboardScreen);
  //   } catch (e) {
  //     print("$e");
  //   }
  // }
}
