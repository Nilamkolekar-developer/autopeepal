import 'package:ap_diagnostic/usd_diagnostic.dart';
import 'package:autopeepal/logic/controller/dataSyncController.dart';
import 'package:get/get.dart';
import 'package:ap_dongle_comm/utils/dongleComm.dart';
import 'package:ap_dongle_comm/utils/commController.dart';
import 'package:ecu_seedkey/ecu_seedkey.dart';

// class AppBinding extends Bindings {
//   @override
//   void dependencies() {
//     // 1. Capture the created instance in a variable called 'commCtrl'
//     final commCtrl = Get.put<CommController>(
//       CommController(),
//       permanent: true,
//     );

//     // 2. Now 'commCtrl' is defined and can be passed to DongleComm
//     Get.put<DongleComm>(
//       DongleComm(
//         comm: commCtrl,
//         isChannel: true,
//       ),
//       permanent: true,
//     );
//  Get.put<UDSDiagnostic>(
//   UDSDiagnostic(
//     Get.find<DongleComm>(), // 1st argument
//     ECUCalculateSeedkey(),   // 2nd argument
//   ),
//   permanent: true,
// );
//     Get.put(DataSyncController(),permanent: true);
//   }
  
// }
class AppBinding extends Bindings {
  @override
  void dependencies() {

    final commCtrl = Get.put<CommController>(
      CommController(),
    );

    Get.put<DongleComm>(
      DongleComm(
        comm: commCtrl,
        isChannel: true,
      ),
    );

    Get.put<UDSDiagnostic>(
      UDSDiagnostic(
        Get.find<DongleComm>(),
        ECUCalculateSeedkey(),
      ),
    );

    Get.put(DataSyncController(),permanent: true);
  }
}