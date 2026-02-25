
import 'package:autopeepal/common_widgets/customDropdown.dart';
import 'package:autopeepal/common_widgets/ui_helper_widgets.dart';
import 'package:autopeepal/themes/app_colors.dart';
import 'package:autopeepal/themes/app_textstyles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Selected values for dropdowns
    final selectedOEM = "".obs;
    final selectedWorkshopGroup = "".obs;
    final selectedCity = "".obs;
    final selectedWorkshop = "".obs;

    // Dropdown items
    final oemList = ["OEM A", "OEM B", "OEM C"];
    final workshopGroupList = ["Group 1", "Group 2", "Group 3"];
    final cityList = ["Pune", "Mumbai", "Ahmednagar"];
    final workshopList = ["Workshop 1", "Workshop 2", "Workshop 3"];

   return Scaffold(
  backgroundColor: AppColors.pagebgColor,
  appBar: AppBar(
    backgroundColor: AppColors.primaryColor,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () => Get.back(),
    ),
    title: Text('Register', style: TextStyles.appBarTitle),
  ),
  body: SafeArea(
    child: Column(
      children: [
        // Scrollable form
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldWithLabel("Enter First Name",hint: "Enter first name"),
                C15(),
                _buildFieldWithLabel("Enter Last Name",hint: "Enter last name"),
                C15(),
                _buildFieldWithLabel("Enter Email ID", keyboardType: TextInputType.emailAddress,hint: "Enter email Id"),
                C15(),
                _buildFieldWithLabel("Enter Mobile Number", keyboardType: TextInputType.phone,hint: "Enter mobile number"),
                C15(),
                _buildFieldWithLabel("Enter Password", obscureText: true,hint: "Enter password"),
                C15(),
                _buildFieldWithLabel("Confirm Password", obscureText: true,hint: "Confirm Password"),
                C15(),
                CustomDropdownTextField1(
                  selectedValue: selectedOEM,
                  items: oemList,
                  title: "Select OEM",
                  hint: "Select OEM",
                ),
                C15(),
                CustomDropdownTextField1(
                  selectedValue: selectedWorkshopGroup,
                  items: workshopGroupList,
                  title: "Select Workshop Group",
                  hint: "Select Workshop Group",
                ),
                C15(),
                CustomDropdownTextField1(
                  selectedValue: selectedCity,
                  items: cityList,
                  title: "Select City",
                  hint: "Select City",
                ),
                C15(),
                CustomDropdownTextField1(
                  selectedValue: selectedWorkshop,
                  items: workshopList,
                  title: "Select Workshop",
                  hint: "Select Workshop",
                ),
                C25(),
              ],
            ),
          ),
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
              
            },
            child: const Text(
              'Submit',
              style: TextStyle(
                fontSize: 14,
                fontFamily: "OpenSans-SemiBold",
                color: Colors.black,
                
              ),
            ),
          ),
        ),
      ],
    ),
  ),
);
  }

 Widget _buildFieldWithLabel(
  String label, {
  TextInputType keyboardType = TextInputType.text,
  bool obscureText = false,
  String hint = "", // Add hint parameter
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black,
          fontFamily: "OpenSans-Regular",
        ),
      ),
      C2(),
      TextField(
        style: TextStyles.textfieldTextStyle2,
        cursorColor: Colors.black,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyles.hintStyle1, // Apply your custom hint style
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: AppColors.primaryColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: AppColors.primaryColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(
              color: AppColors.primaryColor,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    ],
  );
}
}