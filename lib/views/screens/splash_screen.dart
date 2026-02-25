import 'package:autopeepal/logic/controller/splashController.dart';
import 'package:autopeepal/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({Key? key}) : super(key: key);

  final SplashController controller = Get.put(SplashController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Center(
        child: Image.asset(
          'assets/new/autopeepal.png', // your image path
          width: 200, // adjust size if needed
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}