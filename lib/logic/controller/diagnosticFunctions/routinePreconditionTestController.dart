import 'dart:convert';

import 'package:autopeepal/app.dart';
import 'package:autopeepal/common_widgets/popup.dart';
import 'package:autopeepal/models/iorTest_model.dart';
import 'package:autopeepal/models/liveParameter_model.dart';
import 'package:autopeepal/models/staticData.dart';
import 'package:autopeepal/utils/save_local_data.dart';
import 'package:autopeepal/views/screens/diagnostic_functions/iorTestPlayPage.dart';
import 'package:get/get.dart';

class routinePreconditionController extends GetxController {
  var isBusy = false.obs;
  var loaderText = ''.obs;

  RxList<dynamic> pidList = <dynamic>[].obs;
  RxList<dynamic> preconditionPidList = <dynamic>[].obs;
  late IorResult iorResult; // Add this inside routinePreconditionController
  RxList<dynamic> iorStaticList = <dynamic>[].obs;
  RxList<dynamic> iorManualList = <dynamic>[].obs;
  RxList<dynamic> iorPidList = <dynamic>[].obs;
  void init() async {
    try {
      isBusy.value = true;
      loaderText.value = "Loading...";
      preconditionPidList.clear();
      pidList.clear();

      // Load PID dataset
      int pidDataset = StaticData.ecuInfo[0].pidDatasetId!;
      String pidLocalData =
          await SaveLocalData().getData("PidDataset_$pidDataset");
      var pidLocal = jsonDecode(pidLocalData);
      pidList.addAll(pidLocal['codes']);

      for (var item in iorResult.preConditions) {
        if (item.preConditionType == "static") {
          iorStaticList.add(item);
        } else if (item.preConditionType == "manual_confirm") {
          iorManualList.add(item);
        } else if (item.preConditionType == "pid") {
          iorPidList.add(item);
        }
      }

      await getPidValues();
    } catch (ex) {
      print("Error in init: $ex");
    } finally {
      isBusy.value = false;
      loaderText.value = "";
    }
  }

  Future<void> getPidValues() async {
    try {
      if (iorPidList.isNotEmpty) {
        for (var item2 in iorPidList) {
          dynamic pidCode;

          for (var pid in pidList) {
            for (var variable in pid['pi_code_variable']) {
              if (item2['pid'] == variable['id']) {
                // Check if pidCode already exists in PreconditionPidList
                var existing = preconditionPidList.firstWhere(
                  (x) => x['id'] == pidCode?['id'],
                  orElse: () => null,
                );

                if (existing != null) {
                  if (existing['pi_code_variable'] != null &&
                      (existing['pi_code_variable'] as List).isNotEmpty) {
                    existing['pi_code_variable'].add(variable);
                  } else {
                    existing['pi_code_variable'] = [variable];
                  }
                } else {
                  pid['pi_code_variable'] = [variable];
                  pidCode = pid;
                  preconditionPidList.add(pidCode);
                }
              }
            }
          }
        }

        if (preconditionPidList.isNotEmpty) {
          bool isReadingPid = true;
          while (isReadingPid) {
            // Replace GetPidsValue with your Dart version
            await getPidsValue();
            // You need a mechanism to break the loop
            // For example: isReadingPid = false; when finished
          }
        }
      }
    } catch (ex) {
      print("Error in getPidValues: $ex");
    }
  }

  Future<void> getPidsValue() async {
    try {
      // Assuming App.dllFunctions.readPid is your Dart equivalent
      var readPidResponse =
          await App.dllFunctions!.readPid(preconditionPidList as List<PidCode>);

      setPidValue(readPidResponse);
    } catch (ex) {
      print("Error in getPidsValue: $ex");
    }
  }

  void setPidValue(List<dynamic>? readPidResponse) {
    if (readPidResponse != null) {
      for (var readPid in readPidResponse) {
        for (var variable in readPid['Variables']) {
          // Find the corresponding pid in iorPidList
          var pidItem = iorPidList.firstWhere(
            (x) => x['pid'] == variable['pidNumber'],
            orElse: () => null,
          );

          if (pidItem != null) {
            if (readPid['Status'] == "NOERROR") {
              pidItem['current_value'] = variable['responseValue'];
            } else {
              pidItem['current_value'] = "ERR";
            }
          }
        }
      }
    }
  }

  var isReadingPid = false.obs;
  Future<void> checkConditionsAndNavigate() async {
    try {
      bool allConditionMatched = true;

      // Check manual conditions
      for (var item in iorManualList) {
        if (item['is_check'] != true) {
          allConditionMatched = false;
          break;
        }
      }

      // Check PID value ranges
      for (var pid in iorPidList) {
        double? currVal =
            double.tryParse(pid['current_value']?.toString() ?? '');
        double? minVal = double.tryParse(pid['lower_limit']?.toString() ?? '');
        double? maxVal = double.tryParse(pid['upper_limit']?.toString() ?? '');

        if (currVal != null && minVal != null && maxVal != null) {
          if (currVal < minVal || currVal > maxVal) {
            allConditionMatched = false;
            break;
          }
        }
      }

      if (allConditionMatched) {
        isReadingPid.value = false;
        isBusy.value = true;
        loaderText.value = "Loading...";

        await Future.delayed(const Duration(seconds: 3));

        Get.offAll((dynamic SeedIndex, dynamic WriteFnIndex, dynamic NoOfInj,
                dynamic firingOrder) =>
            IorTestPlayPage(
                IorResult, SeedIndex, WriteFnIndex, NoOfInj, firingOrder));
      } else {
        // Show alert if conditions not met
        await Get.dialog(
            CustomPopup(
              title: "Alert!",
              message: "Please meet all required PreConditions to continue",
            ),
            barrierDismissible: false);
      }
    } catch (ex) {
      print("Error in checkConditionsAndNavigate: $ex");
    } finally {
      isBusy.value = false;
      loaderText.value = "";
    }
  }
}
