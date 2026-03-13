// import 'package:autopeepal/logic/controller/diagnosticFunctions/ecuInformationController.dart';
// import 'package:autopeepal/themes/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';


// class EcuInformationScreen extends StatelessWidget {
//   const EcuInformationScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(EcuInformationController());

//     return Scaffold(
//       backgroundColor: AppColors.pagebgColor,
//       appBar: AppBar(
//         title: const Text("ECU Information"),
//         backgroundColor: AppColors.primaryColor,
//       ),
//       body: Stack(
//         children: [
//           Column(
//             children: [

//               /// ECU TAB BAR
//               Obx(() {
//                 return Container(
//                   height: 50,
//                   color: AppColors.primaryColor,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: controller.ecuList.length,
//                     itemBuilder: (context, index) {
//                       final ecu = controller.ecuList[index];

//                       return Expanded(
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppColors.primaryColor,
//                             elevation: 0,
//                             shape: const RoundedRectangleBorder(),
//                           ),
//                           onPressed: () {
//                             controller.selectedEcu(ecu);
//                           },
//                           child: Opacity(
//                             opacity: ecu.opacity.value,
//                             child: Text(
//                               ecu.ecuName ?? "",
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 );
//               }),

//               /// PARAMETER LIST
//               Expanded(
//                 child: Obx(() {

//                   if (controller.selectedParameterList.isEmpty) {
//                     return Center(
//                       child: Text(
//                         controller.errorMessage.value,
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     );
//                   }

//                   return ListView.builder(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 10, vertical: 5),
//                     itemCount: controller.selectedParameterList.length,
//                     itemBuilder: (context, index) {

//                       final pid = controller.selectedParameterList[index];

//                       return Column(
//                         children: pid.piCodeVariable!.map((variable) {

//                           return Container(
//                             padding: const EdgeInsets.all(10),
//                             child: Column(
//                               children: [

//                                 Row(
//                                   children: [

//                                     /// SHORT NAME
//                                     Expanded(
//                                       child: Text(
//                                         variable.shortName ?? "",
//                                         style: const TextStyle(
//                                           fontSize: 14,
//                                           color: Colors.white,
//                                         ),
//                                       ),
//                                     ),

//                                     /// VALUE
//                                     Text(
//                                     Text(variable.resolution?.toStringAsFixed(2) ?? "") as String,
//                                       style: const TextStyle(
//                                         fontSize: 14,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ],
//                                 ),

//                                 const SizedBox(height: 5),

//                                 Container(
//                                   height: 1,
//                                   color: AppColors.primaryColor,
//                                 )
//                               ],
//                             ),
//                           );

//                         }).toList(),
//                       );
//                     },
//                   );
//                 }),
//               ),
//             ],
//           ),

//           /// LOADER
//           Obx(() {
//             if (!controller.isBusy.value) return const SizedBox();

//             return Container(
//               color: Colors.black45,
//               child: const Center(
//                 child: CircularProgressIndicator(),
//               ),
//             );
//           }),
//         ],
//       ),
//     );
//   }
// }