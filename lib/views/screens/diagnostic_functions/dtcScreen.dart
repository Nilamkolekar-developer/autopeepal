import 'package:autopeepal/common_widgets/custom_app_bar.dart';
import 'package:autopeepal/common_widgets/ui_helper_widgets.dart';
import 'package:autopeepal/logic/controller/diagnosticFunctions/dtcController.dart';
import 'package:autopeepal/themes/app_colors.dart';
import 'package:autopeepal/themes/app_textstyles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DTCScreen extends StatelessWidget {
  const DTCScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Dtccontroller controller = Get.put(Dtccontroller());

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
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                prefixIcon: const Icon(Icons.search, size: 22),
                prefixIconConstraints:
                    const BoxConstraints(minHeight: 30, minWidth: 35),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: AppColors.primaryColor, width: 1.5),
                ),
              ),

              /// 🔹 SEARCH USING CONTROLLER
              onChanged: controller.searchDTC,
            ),
          ),

          // // DTC List
          Expanded(
            child: Obx(() {
              if (controller.isBusy.value) {
                return const Center(child: CircularProgressIndicator());
              } else if (controller.dtcList.isEmpty) {
                return Center(
                  child: Text(
                    controller.emptyViewText.value,
                    style: const TextStyle(color: Colors.grey),
                  ),
                );
              } else {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.dtcList.length,
                  itemBuilder: (context, index) {
                    final dtc = controller.dtcList[index];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),

                        /// 🔹 TITLE
                        Text(
                          dtc.code ?? '',
                          style: const TextStyle(
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dtc.description ?? '',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            C10(),

                            /// Right side actions
                            Column(
                              //crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Center(
                                  child: Text(
                                    " ${dtc.statusActivation ?? ''}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: dtc.statusActivationColor ??
                                          Colors
                                              .grey, // Uses color mapped from status
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),

                                /// 🔹 TROUBLESHOOT
                                InkWell(
                                  onTap: () {
                                    controller.gdCommand(dtc);
                                  },
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: AppColors.primaryColor),
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
                                  onTap: () {
                                    controller.openFreezeFrame(dtc);
                                  },
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: AppColors.primaryColor),
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
                );
              }
            }),
          ),
        ],
      ),
      bottomNavigationBar: Obx(() {
        if (!controller.isReadDtc.value) {
          return const SizedBox.shrink();
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onPressed: () {
                      controller.clearDtc(context);
                    },
                    child: const Text(
                      "Clear",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onPressed: () {
                      controller.refreshDtc();
                    },
                    child: const Text(
                      "Refresh",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
// import 'package:autopeepal/common_widgets/custom_app_bar.dart';
// import 'package:autopeepal/common_widgets/ui_helper_widgets.dart';
// import 'package:autopeepal/logic/controller/diagnosticFunctions/dtcController.dart';
// import 'package:autopeepal/themes/app_colors.dart';
// import 'package:autopeepal/themes/app_textstyles.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class DTCScreen extends StatelessWidget {
//   const DTCScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final Dtccontroller controller = Get.put(Dtccontroller());

//     return Scaffold(
//       backgroundColor: AppColors.pagebgColor,
//       appBar: const CommonAppBar(
//         title: "DTC List",
//         subtitle: "EMS",
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//             child: TextField(
//               style: TextStyles.textfieldTextStyle1,
//               cursorColor: Colors.black,
//               textAlignVertical: TextAlignVertical.center,
//               decoration: InputDecoration(
//                 hintText: 'Search...',
//                 hintStyle: TextStyle(
//                   fontSize: 13,
//                   color: Colors.grey.shade700,
//                 ),
//                 isDense: true,
//                 contentPadding:
//                     const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//                 prefixIcon: const Icon(Icons.search, size: 22),
//                 prefixIconConstraints:
//                     const BoxConstraints(minHeight: 30, minWidth: 35),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: AppColors.primaryColor),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide:
//                       BorderSide(color: AppColors.primaryColor, width: 1.5),
//                 ),
//               ),

//               /// 🔹 SEARCH USING CONTROLLER
//               onChanged: controller.searchDTC,
//             ),
//           ),

//           // // DTC List
//           Expanded(
//             child: Obx(() {
//               if (controller.isBusy.value) {
//                 return const Center(child: CircularProgressIndicator());
//               } else if (controller.dtcList.isEmpty) {
//                 return Center(
//                   child: Text(
//                     controller.emptyViewText.value,
//                     style: const TextStyle(color: Colors.grey),
//                   ),
//                 );
//               } else {
//                 return ListView.builder(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   itemCount: controller.dtcList.length,
//                   itemBuilder: (context, index) {
//                     final dtc = controller.dtcList[index];

//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const SizedBox(height: 12),

//                         /// 🔹 TITLE
//                         Text(
//                           dtc.code ?? '',
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),

//                         C5(),

//                         /// 🔹 SUBTITLE + RIGHT ACTIONS
//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             /// Subtitle (Left side)
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     dtc.description ?? '',
//                                     style: const TextStyle(
//                                       fontSize: 14,
//                                       color: Colors.black87,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),

//                             C10(),

//                             /// Right side actions
//                             Column(
//                               //crossAxisAlignment: CrossAxisAlignment.end,
//                               children: [
//                                 Center(
//                                   child: Text(
//                                     " ${dtc.statusActivation ?? ''}",
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.bold,
//                                       color: dtc.statusActivationColor ??
//                                           Colors
//                                               .grey, // Uses color mapped from status
//                                     ),
//                                     textAlign: TextAlign.center,
//                                   ),
//                                 ),

//                                 /// 🔹 TROUBLESHOOT
//                                 InkWell(
//                                   onTap: () {
//                                     controller.gdCommand(dtc);
//                                   },
//                                   borderRadius: BorderRadius.circular(6),
//                                   child: Container(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 5, vertical: 2),
//                                     decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius: BorderRadius.circular(6),
//                                       border: Border.all(
//                                           color: AppColors.primaryColor),
//                                     ),
//                                     child: Text(
//                                       "Troubleshoot",
//                                       style: TextStyle(
//                                         fontSize: 10,
//                                         color: AppColors.black,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                   ),
//                                 ),

//                                 C2(),

//                                 /// 🔹 FREEZE FRAME
//                                 InkWell(
//                                   onTap: () {
//                                     controller.openFreezeFrame(dtc);
//                                   },
//                                   borderRadius: BorderRadius.circular(6),
//                                   child: Container(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 5, vertical: 2),
//                                     decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius: BorderRadius.circular(6),
//                                       border: Border.all(
//                                           color: AppColors.primaryColor),
//                                     ),
//                                     child: Text(
//                                       "Freeze Frame",
//                                       style: TextStyle(
//                                         fontSize: 10,
//                                         color: AppColors.black,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),

//                         C5(),

//                         /// Divider
//                         Divider(
//                           thickness: 1,
//                           color: AppColors.primaryColor,
//                           height: 4,
//                         ),
//                       ],
//                     );
//                   },
//                 );
//               }
//             }),
//           ),
//         ],
//       ),
//       bottomNavigationBar: Obx(() {
//         if (!controller.isReadDtc.value) {
//           return const SizedBox.shrink();
//         }

//         return SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primaryColor,
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(5),
//                       ),
//                     ),
//                     onPressed: () {
//                       controller.clearDtc(context);
//                     },
//                     child: const Text(
//                       "Clear",
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primaryColor,
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(5),
//                       ),
//                     ),
//                     onPressed: () {
//                       controller.refreshDtc();
//                     },
//                     child: const Text(
//                       "Refresh",
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       }),
//     );
//   }
// }