import 'package:autopeepal/common_widgets/custom_app_bar.dart';
import 'package:autopeepal/themes/app_colors.dart';
import 'package:flutter/material.dart';

class RoutineTestScreen extends StatelessWidget {
  const RoutineTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: AppColors.pagebgColor,
     appBar: const CommonAppBar(
        title: "Routine Test",
        subtitle: "EMS",
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