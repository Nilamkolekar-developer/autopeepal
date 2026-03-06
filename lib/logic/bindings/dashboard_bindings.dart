import 'package:autopeepal/logic/controller/cliCard/drawerViewController.dart';
import 'package:autopeepal/logic/controller/dashboard/dasboardController.dart';
import 'package:get/get.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DashboardController());
   Get.put(DrawerViewController(), permanent: true);
  }
}
