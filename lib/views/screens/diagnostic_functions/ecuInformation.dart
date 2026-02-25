import 'package:autopeepal/themes/app_colors.dart';
import 'package:flutter/material.dart';

class EcuInformation extends StatelessWidget {
  const EcuInformation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: AppColors.pagebgColor,
      appBar: AppBar(
        title: const Text("ECU Information",style: TextStyle(color: Colors.white,fontSize: 18)),
         backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Center(
        child: Text(
          "Welcome",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}