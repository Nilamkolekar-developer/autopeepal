import 'package:autopeepal/logic/controller/cliCard/jobCardController.dart';
import 'package:autopeepal/themes/app_colors.dart';
import 'package:autopeepal/views/screens/clicard/jobCardWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class JobCardPage extends StatelessWidget {
  JobCardPage({super.key});
  final JobardController controller = Get.put(JobardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pagebgColor,
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
      body: Column(
        children: [
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

          Expanded(
            child: Obx(() {
              if (controller.isBusy.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.jobCardList.isEmpty) {
                return const Center(child: Text("No Job Cards Found"));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.jobCardList.length,
                itemBuilder: (context, index) {
                  final item = controller.jobCardList[index];

                  return InkWell(
                    onTap: () {
                      controller.jobcardSelect(item);
                    },
                    child: JobCardItem(item: item),
                  );
                },
              );
            }),
          )
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("Add button tapped");
          controller.newJobcard();
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
