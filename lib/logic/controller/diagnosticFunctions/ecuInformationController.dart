import 'package:autopeepal/models/liveParameter_model.dart';
import 'package:get/get.dart';


class EcuInformationController extends GetxController {
RxBool isBusy = false.obs;
  /// Selected Parameter List
  RxList<PidCode> selectedParameterList = <PidCode>[].obs;

  /// ECU List
  RxList<EcusModel> ecusList = <EcusModel>[].obs;

  /// Selected ECU
  Rx<EcusModel?> selectedEcu = Rx<EcusModel?>(null);

  /// Error Message
  RxString errorMessage = "".obs;

}