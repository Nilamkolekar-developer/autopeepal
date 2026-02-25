import 'package:autopeepal/logic/controller/cliCard/drawerViewController.dart';
import 'package:get/get.dart';

class DrawerBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DrawerViewController());
  }
}
