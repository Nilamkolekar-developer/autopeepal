import 'package:autopeepal/common_widgets/custom_app_bar.dart';
import 'package:autopeepal/common_widgets/ui_helper_widgets.dart';
import 'package:autopeepal/themes/app_colors.dart';
import 'package:autopeepal/themes/app_textstyles.dart';
import 'package:flutter/material.dart';

class AllDTCDetails extends StatelessWidget {
  const AllDTCDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pagebgColor,
      appBar: const CommonAppBar(
        title: "DTC List",
        subtitle: "EMS",
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: TextField(
              style: TextStyles.textfieldTextStyle1,
              cursorColor: Colors.black,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 22,
                ),
                prefixIconConstraints: const BoxConstraints(
                  minHeight: 30,
                  minWidth: 35,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.primaryColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.primaryColor,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 5, // replace with your DTC list
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    /// 🔹 TITLE
                    const Text(
                      "P0100",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    C5(),

                    /// 🔹 SUBTITLE + RIGHT ACTIONS
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Subtitle (Left side)
                        Expanded(
                          child: const Text(
                            "Mass or Volume Air Flow Circuit Malfunction",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),

                        C10(),

                        /// Right side actions
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            /// 🔹 TROUBLESHOOT
                            InkWell(
                              onTap: () {},
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                                child: Text(
                                  "Troubleshoot",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            C2(),

                            /// 🔹 FREEZE FRAME
                            InkWell(
                              onTap: () {},
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                                child: Text(
                                  "Freeze Frame",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    C5(),

                    /// Divider
                    Divider(
                      thickness: 1,
                      color: AppColors.primaryColor,
                      height: 4,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
