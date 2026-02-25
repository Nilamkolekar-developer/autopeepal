import 'package:get/get.dart';
import 'package:ap_dongle_comm/utils/dongleComm.dart';
import 'package:ap_dongle_comm/utils/commController.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Capture the created instance in a variable called 'commCtrl'
    final commCtrl = Get.put<CommController>(
      CommController(),
      permanent: true,
    );

    // 2. Now 'commCtrl' is defined and can be passed to DongleComm
    Get.put<DongleComm>(
      DongleComm(
        comm: commCtrl,      
        isChannel: true,        
      ),
      permanent: true,
    );
  }
}