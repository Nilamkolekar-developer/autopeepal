import 'dart:convert';

import 'package:autopeepal/models/dtc_model.dart';
import 'package:autopeepal/models/freezeFrame_model.dart';
import 'package:autopeepal/utils/save_local_data.dart';
import 'package:autopeepal/utils/ui_helper.dart/dllFunctions.dart';
import 'package:get/get.dart';


class FreezeFrameController extends GetxController {
  final DLLFunctions dllFunctions;

  int ffSetId = 0;

  Rx<DtcCode?> dtc = Rx<DtcCode?>(null);

  RxList<FreezeFrameUIModel> freezeFrameList = <FreezeFrameUIModel>[].obs;

  RxString error = "".obs;

  FreezeFrameController(
    DtcCode dtcCode,
    int ffSetId,
    this.dllFunctions,
  ) {
    this.ffSetId = ffSetId;
    dtc.value = dtcCode;
  }

  @override
  void onInit() {
    super.onInit();

    getFreezeFrame(dtc.value?.code ?? "");
  }

  Future<void> getFreezeFrame(String dtcCode) async {
    try {
      FreezeFrameAnalyze freezeFrameAnalyze =
          FreezeFrameAnalyze(freezeFrame: []);

      FreezeFrameModel? result;

      var jsonListData =
          await SaveLocalData().getData("FreezeFrame_LocalList");

      if (jsonListData.isEmpty) {
        Get.snackbar("Alert", "Freeze frame not found in local DB");
        return;
      }

      result = FreezeFrameModel.fromJson(jsonDecode(jsonListData));

      if (result.message == "success") {
        if (result.results != null && result.results!.isNotEmpty) {
          var freezeFrame =
              FirstWhereExt(result.results!).firstWhereOrNull((x) => x.id == ffSetId);

          if (freezeFrame == null) {
            error.value = "Freeze frame not found.";
            Get.snackbar("Error", "Freeze frame not found.");
            return;
          }

          freezeFrameList.clear();

          List<FreezeFrameUIModel> dummyList = [];

          var frameResponse =
              await dllFunctions.getFreezeFrame(dtcCode, freezeFrame);

          if (frameResponse.status == "NOERROR") {
            for (var frame in frameResponse.dtcs ?? []) {
              var item = freezeFrame.freezeFrameCode
                  ?.firstWhereOrNull((x) => x.code == frame.code);

              if (item != null) {
                dummyList.add(
                  FreezeFrameUIModel(
                    id: item.id,
                    code: item.code,
                    desc: item.desc,
                    unit: item.unit,
                    priority: frame.priority,
                    value: frame.value,
                  ),
                );

                freezeFrameAnalyze.freezeFrame?.add(
                  FreezeFrameAnalyzeResult(
                    code: dtc.value?.code,
                    pidName: "${item.code}-${item.desc}",
                    value: "${frame.value}",
                  ),
                );
              }
            }

            freezeFrameList.assignAll(dummyList);
          } else {
            error.value = frameResponse.status ?? "";
          }
        } else {
          error.value = "Freeze frame not found.";
          Get.snackbar("Error", "Freeze frame not found.");
        }
      } else {
        error.value = result.message ?? "";
        Get.snackbar("Error", result.message ?? "");
      }
    } catch (e) {
      error.value = e.toString();
      Get.snackbar("Error", e.toString());
    }
  }
}