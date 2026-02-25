import 'package:autopeepal/logic/controller/cliCard/jobCardController.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:autopeepal/themes/app_colors.dart';
import 'package:autopeepal/views/screens/clicard/jobCardWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_navigation/get_navigation.dart';

class JobCardPage extends StatelessWidget {
  JobCardPage({super.key});
  final JobCardController controller = Get.put(JobCardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: AppColors.pagebgColor,

      /// APP BAR
      appBar: AppBar(
        backgroundColor: const Color(0xFFF47A1F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Get.back();
          },
        ),
        title: const Text(
          'Job Card',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      /// BODY
      body: Column(
        children: [
          /// SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          /// LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 1,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Get.toNamed(
                      Routes.jobCardDetails,
                      arguments: {
                        'vciName': controller.vciName,
                      },
                    );
                  },
                  child: const JobCardItem(),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("Add button tapped");
        },
        backgroundColor: Colors.red,
        shape: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: const Icon(Icons.add, size: 30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
