import 'package:ap_dongle_comm/utils/commController.dart';
import 'package:autopeepal/logic/controller/cliCard/terminalController.dart';
import 'package:get/get.dart';


class TerminalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TerminalController>(() => TerminalController());
    Get.lazyPut<CommController>(() => CommController());
  }
}