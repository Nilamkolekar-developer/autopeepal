import 'package:autopeepal/common_widgets/ui_helper_widgets.dart';
import 'package:autopeepal/logic/controller/vciConfiguration/vciConfigurationController.dart';
import 'package:autopeepal/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';



class VCIConfiguration extends StatelessWidget {
   VCIConfiguration({super.key});
final controller =Get.put(Vciconfigurationcontroller());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: AppColors.pagebgColor,
      appBar: AppBar(
        title: const Text('Write SSID and PASSWORD'),
        backgroundColor: AppColors.primaryColor,
        iconTheme:
            const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller:controller.ssidController.value,
                cursorColor: Colors.black,
                style: const TextStyle(
                  fontSize: 14,
                  //fontFamily: "Roboto-Regular",
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                decoration: _inputDecoration('Enter new SSID'),
              ),

              C30(),

              // Second TextField
              TextField(
                controller:controller.passwordController.value,
                cursorColor: Colors.black,
                style: const TextStyle(
                  fontSize: 14,
                  //fontFamily: "Roboto-Regular",
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                decoration: _inputDecoration('Enter new Password'),
              ),

              C25(),

              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7A18),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 60,
                        vertical: 15 // controls height naturally
                        ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(6)),
                  ),
                  onPressed: () {
                    controller.submit();
                  },
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: "Roboto-Regular",
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
