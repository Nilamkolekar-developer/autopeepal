import 'package:autopeepal/common_widgets/ui_helper_widgets.dart';
import 'package:autopeepal/logic/controller/auth/loginController.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:autopeepal/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);
  final LoginController controller = Get.put(LoginController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              /// 🔹 Scrollable Main Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 130),
                        child: Center(
                          child: Image.asset(
                            'assets/new/autopeepal(1).png',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 190),
                        child: _buildFormSection(),
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  const Text(
                    'Powered by',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  Image.asset(
                    'assets/new/autopeepal(1).png',
                    height: 28,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller.usernameController.value,
          cursorColor: Colors.black,
          style: const TextStyle(
            fontSize: 14,
            //fontFamily: "Roboto-Regular",
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          decoration: _inputDecoration('Registered User ID'),
        ),

        C8(),
        Obx(
          () => TextField(
            controller: controller.passwordController.value,
            obscureText: controller.hidePassword.value,
            style: const TextStyle(
              fontSize: 14,
              //fontFamily: "Roboto-Regular",
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            decoration: _inputDecoration(
              'Password',
              suffix: IconButton(
                icon: Icon(
                  controller.hidePassword.value
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Color(0xFF00B8D4),
                  size: 30,
                ),
                onPressed: controller.hidePassword.toggle,
              ),
            ),
          ),
        ),

        /// Register / Forgot
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// 🔲 Remember Me + Checkbox
            Obx(
              () => Row(
                children: [
                  const Text(
                    'Remember Me',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  Checkbox(
                    value: controller.rememberMe.value,
                    onChanged: (value) {
                      controller.rememberMe.value = value ?? false;
                    },
                    activeColor: const Color(0xFFFF7A18),
                  ),
                ],
              ),
            ),

            TextButton(
              onPressed: () {
                Get.toNamed(Routes.registerScreen);
              },
              child: const Text(
                'Register',
                style: TextStyle(
                  color: Color(0xFF00B8D4), // VS Code Blue
                  // fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),

        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7A18),
              padding: const EdgeInsets.symmetric(
                  horizontal: 60 // controls height naturally
                  ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(6)),
            ),
            onPressed: () {
              if (controller.rememberMe.value) {
                controller.saveCredentials();
              } else {
                controller.clearSavedCredentials();
              }

              Get.toNamed(Routes.dashboardScreen);
            },
            child: const Text(
              'SIGN IN',
              style: TextStyle(
                fontSize: 14,
                fontFamily: "Roboto-Regular",
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
          color: Colors.grey.shade900,
          fontSize: 14,
          fontFamily: "Roboto-Regular"),
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.primaryColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.primaryColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: AppColors.primaryColor,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
    );
  }
}
