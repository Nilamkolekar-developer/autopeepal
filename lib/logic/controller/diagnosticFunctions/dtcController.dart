import 'dart:convert';
import 'package:ap_diagnostic/models/readDtcResponseModel.dart';
import 'package:autopeepal/app.dart';
import 'package:autopeepal/common_widgets/popup.dart';
import 'package:autopeepal/models/dtc_model.dart' hide ReadDtcResponseModel;
import 'package:autopeepal/models/gd_model.dart';
import 'package:autopeepal/models/staticData.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:autopeepal/utils/save_local_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Dtccontroller extends GetxController {
  RxList<DtcEcusModel> ecusList = <DtcEcusModel>[].obs;
  RxList<DtcCode> dtcList = <DtcCode>[].obs;
  RxList<DtcCode> staticDtcList = <DtcCode>[].obs;
  Rx<DtcEcusModel> selectedEcu = DtcEcusModel().obs;
  RxBool isBusy = false.obs;
  RxString emptyViewText = "".obs;
  RxString DTCFoundOrNotMessage = "".obs;
  Rx<ReadDtcResponseModel?> readDtc = Rx<ReadDtcResponseModel?>(null);
  Rx<DtcEcusModel?> dtcEcusModel = Rx<DtcEcusModel?>(null);
  RxBool isReadDtc = false.obs;
  RxList<DtcCode> dtcServerList = <DtcCode>[].obs;

// Simple list for stored DTCs
  List<DtcCode> storedDtcList = [];
  @override
  Future<void> onInit() async {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args['onlyActive'] != null) {
      isReadDtc.value = args['onlyActive'];
      print("✅ isReadDtc set to: ${isReadDtc.value}");
    }
    getDTCList();
  }

  Future<void> switchTab(DtcEcusModel arg) async {
    try {
      isBusy.value = true;

      await Future.delayed(const Duration(milliseconds: 50));

      selectedEcu.value = arg;

      for (var ecu in ecusList) {
        ecu.opacity = 0.5;

        if (selectedEcu.value.ecuId == ecu.ecuId) {
          ecu.opacity = 1;

          if (isReadDtc.value) {
            DtcEcusModel? result = await getDtc(
              selectedEcu.value,
              StaticData.ecuInfo.firstWhere(
                (x) => x.ecuID == ecu.ecuId,
                orElse: () =>
                    EcuDataSet(ecuID: null, ecuName: '', protocol: null),
              ),
            );

            staticDtcList.assignAll(result?.dtcList ?? []);
            dtcList.assignAll(result?.dtcList ?? []);
          } else {
            staticDtcList.assignAll(selectedEcu.value.dtcList ?? []);
            dtcList.assignAll(selectedEcu.value.dtcList ?? []);
          }
        }
      }

      ecusList.refresh();
    } catch (e) {
      print("❌ switchTab error: $e");
      staticDtcList.clear();
      dtcList.clear();
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> refreshDtc() async {
    try {
      isBusy.value = true;

      await Future.delayed(const Duration(milliseconds: 50));

      final ecuInfo = StaticData.ecuInfo.firstWhere(
        (x) => x.ecuName == selectedEcu.value.ecuName,
        orElse: () => EcuDataSet(),
      );

      DtcEcusModel? dtc = await getDtc(selectedEcu.value, ecuInfo);

      staticDtcList.assignAll(dtc?.dtcList ?? []);
      dtcList.assignAll(dtc?.dtcList ?? []);
    } catch (e) {
      print("❌ refreshDtc error: $e");
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> clearDtc(BuildContext context) async {
    try {
      print('🔹 clearDtc called for ECU: ${selectedEcu.value.ecuName}');

      isBusy.value = true;
      await Future.delayed(const Duration(milliseconds: 50));

      final clearDtcIndex = selectedEcu.value.clearDtcIndex;
      print('🔹 clearDtcIndex: $clearDtcIndex');

      emptyViewText.value = "";

      int attempt = 0;
      String clearDtcResp = "";

      do {
        attempt++;
        print("⏳ ClearDTC Attempt #$attempt");

        clearDtcResp = await App.dllFunctions!.clearDtc(clearDtcIndex ?? "");

        print("📡 ClearDTC response: $clearDtcResp");

        if (clearDtcResp.contains("GENERALERROR_INVALIDRESPFROMDONGLE") ||
            clearDtcResp.contains("BUSY")) {
          print("⏳ ECU busy... retrying");
          await Future.delayed(const Duration(milliseconds: 150));
        } else {
          break;
        }
      } while (attempt < 10);

      if (clearDtcResp.contains('NOERROR')) {
        print('✅ ClearDTC successful');

        if (dtcList.isNotEmpty) {
          for (var item in dtcList) {
            if (item.statusActivation == 'Inactive') {
              storedDtcList.add(item);
            }
          }

          await SaveLocalData().saveData(
            'StoredDtcList_${selectedEcu.value.ecuName}',
            jsonEncode(storedDtcList.map((e) => e.toJson()).toList()),
          );
        }

        staticDtcList.clear();
        dtcList.clear();
        Get.dialog(
          CustomPopup(
            title: "Alert",
            message: "DTC Cleared",
            onButtonPressed: () => Get.back(),
          ),
          barrierDismissible: false,
        );
        emptyViewText.value = "DTC Cleared";
      } else {
        print("⚠️ ClearDTC failed: $clearDtcResp");
        Get.dialog(
          CustomPopup(
            title: "Alert",
            message: "Negative Acknowledgement:\n$clearDtcResp",
            onButtonPressed: () => Get.back(),
          ),
          barrierDismissible: false,
        );
      }
    } catch (e, stackTrace) {
      print('❌ Error in clearDtc: $e');
      print(stackTrace);
    } finally {
      isBusy.value = false;
      print('🔹 isBusy set to false');
    }
  }

  Future<void> gdCommand(dynamic arg) async {
    try {
      print("🔹 GD Command triggered");

      DtcCode? selectedDtc = arg as DtcCode?;
      print("🔹 Selected DTC: ${selectedDtc?.code} | ID: ${selectedDtc?.id}");

      if (selectedDtc != null) {
        String key = "GD_LocalList_${App.subModelId}";
        print(",,,,,,,,,,,,,,,,,,,,,,,,,,${key}");
        print("🔹 Fetching GD local data with key: $key");

        String? gdLocalData = await SaveLocalData().getData(key);

        print("🔹 Raw GD Local Data: $gdLocalData");

        if (gdLocalData.isNotEmpty) {
          GdModelGD gdData = GdModelGD.fromJson(jsonDecode(gdLocalData));

          print("🔹 Total GD Results: ${gdData.results?.length}");

          if (gdData.results != null && gdData.results!.isNotEmpty) {
            ResultGD? gd;

            for (var item in gdData.results!) {
              print("🔹 Checking GD item ID: ${item.id}");

              if (item.dtc != null && item.dtc!.isNotEmpty) {
                print("   ➤ DTCs in this GD item: ${item.dtc!.length}");
              } else {
                print("   ➤ No DTC list in this GD item");
              }

              DtcGD? dtcGD = item.dtc?.firstWhere(
                (x) {
                  print(
                      "      🔍 Comparing GD DTC CODE: ${x.code?.code} with Selected CODE: ${selectedDtc.code}");
                  return x.code?.code == selectedDtc.code;
                },
                orElse: () => DtcGD(),
              );
              if (dtcGD != null && dtcGD.code?.code == selectedDtc.code) {
                print("✅ Matching GD found for DTC ID: ${selectedDtc.code}");
                gd = item;
                break;
              }
            }

            if (gd != null) {
              print("🚀 Navigating to GD Info Page");

              Get.toNamed(
                Routes.gdInfo,
                arguments: {
                  "code": selectedDtc.code ?? "",
                  "gd": gd,
                },
              );
            } else {
              print("⚠️ No GD found matching this DTC");

              Get.dialog(
                CustomPopup(
                  title: "Alert",
                  message: "Troubleshoot record not found for this DTC",
                  onButtonPressed: () => Get.back(),
                ),
                barrierDismissible: false,
              );
            }
          } else {
            print("⚠️ GD results list is empty");

            Get.dialog(
              CustomPopup(
                title: "Alert",
                message: "Troubleshoot Record not found",
                onButtonPressed: () => Get.back(),
              ),
              barrierDismissible: false,
            );
          }
        } else {
          print("⚠️ GD Local Data is empty or null");

          Get.dialog(
            CustomPopup(
              title: "Alert",
              message: "Troubleshoot Record not available",
              onButtonPressed: () => Get.back(),
            ),
            barrierDismissible: false,
          );
        }
      }
    } catch (e, stack) {
      print("❌ GDCommand error: $e");
      print("📍 StackTrace: $stack");
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> openFreezeFrame(dynamic arg) async {
    try {
      isBusy.value = true;
      emptyViewText.value = "Loading...";

      await Future.delayed(const Duration(milliseconds: 50));

      DtcCode? selectedDtc = arg as DtcCode?;

      if (selectedDtc != null) {
        if (selectedEcu.value.ffSet != null) {
          Get.toNamed(
            Routes.freezeFrame,
            arguments: {
              "dtc": selectedDtc,
              "ffSet": selectedEcu.value.ffSet!,
            },
          );
        } else {
          Get.dialog(
            CustomPopup(
              title: "Alert",
              message: "Freeze Frame set not found",
              onButtonPressed: () => Get.back(),
            ),
            barrierDismissible: false,
          );
        }
      }
    } catch (e) {
      print("❌ openFreezeFrame error: $e");
    } finally {
      isBusy.value = false;
    }
  }

  // Future<void> getDTCList() async {
  //   DTCFoundOrNotMessage.value = "Looking for DTC Record";
  //   emptyViewText.value = "Loading...";
  //   ecusList.clear();
  //   staticDtcList.clear();
  //   dtcList.clear();
  //   print("🔹 Cleared ecusList, staticDtcList, dtcList.");

  //   try {
  //     isBusy.value = true;
  //     await Future.delayed(const Duration(milliseconds: 50));

  //     int count = 0;
  //     for (var ecu in StaticData.ecuInfo) {
  //       count++;
  //       int dtcDataset = ecu.dtcDatasetId ?? 0;
  //       print(
  //           "🔹 Processing ECU $count: ${ecu.ecuName}, Dataset ID: $dtcDataset");

  //       // Load local DTC dataset
  //       DtcResults? dtcLocal;
  //       String? dtcLocalData =
  //           await SaveLocalData().getData("DtcDataset_$dtcDataset");
  //       dtcLocal = DtcResults.fromJson(jsonDecode(dtcLocalData));
  //       print("DTC local parsed. Count: ${dtcLocal.dtcCode?.length ?? 0}");

  //       // Load stored DTCs for comparison
  //       String? storedList =
  //           await SaveLocalData().getData("StoredDtcList_${ecu.ecuName}");
  //       if (storedList.isNotEmpty) {
  //         storedDtcList = (jsonDecode(storedList) as List)
  //             .map((e) => DtcCode.fromJson(e))
  //             .toList();
  //       } else {
  //         storedDtcList = [];
  //       }

  //       // Inside getDTCList
  //       this.dtcServerList.assignAll(dtcLocal.dtcCode ?? []);

  //       var dtcEcusModel = DtcEcusModel(
  //         ecuName: ecu.ecuName,
  //         ecuId: ecu.ecuID,
  //         opacity: count == 1 ? 1.0 : 0.5,
  //         txHeader: ecu.txHeader,
  //         rxHeader: ecu.rxHeader,
  //         protocol: ecu.protocol,
  //         clearDtcIndex: ecu.clearDtcIndex,
  //         ffSet: ecu.ffSet,
  //         dtcList: [],
  //       );

  //       if (isReadDtc.value) {
  //         bool ecuReadSuccess = false;

  //         // Try to read live DTCs
  //         try {
  //           print("⏳ Reading live DTCs from ECU: ${ecu.ecuName}");
  //           dtcEcusModel = (await getDtc(dtcEcusModel, ecu))!;
  //           ecuReadSuccess = dtcEcusModel.dtcList!.isNotEmpty;
  //           print(
  //               "✅ ECU read completed. DTC count: ${dtcEcusModel.dtcList!.length}");
  //         } catch (e) {
  //           print("⚠️ ECU read failed for ${ecu.ecuName}: $e");
  //         }
  //         if (isReadDtc.value) {
  //           // If live read failed, fallback to server/local
  //           if (!ecuReadSuccess) {
  //             print("⚠️ Using server/local DTCs for ECU: ${ecu.ecuName}");
  //             dtcEcusModel.dtcList = dtcServerList
  //                 .map((item) => DtcCode(
  //                       description: item.description,
  //                       id: item.id,
  //                       isActive: item.isActive,
  //                       code: item.code,
  //                     ))
  //                 .toList();
  //           }
  //         }
  //       } else {
  //         // If isReadDtc is false, directly use server/local DTCs
  //         dtcEcusModel.dtcList = dtcServerList
  //             .map((item) => DtcCode(
  //                   description: item.description,
  //                   id: item.id,
  //                   isActive: item.isActive,
  //                   code: item.code,
  //                 ))
  //             .toList();
  //       }

  //       ecusList.add(dtcEcusModel);
  //       print("ECU added to ecusList. Total ECUs: ${ecusList.length}");
  //     }

  //     // Assign first ECU for UI
  //     if (ecusList.isNotEmpty) {
  //       staticDtcList.assignAll(ecusList.first.dtcList!);
  //       dtcList.assignAll(ecusList.first.dtcList!);
  //       selectedEcu.value = ecusList[0];
  //       print(
  //           "Selected ECU: ${selectedEcu.value.ecuName}, Total DTCs: ${dtcList.length}");
  //     }

  //     print("✅ getDTCList finished successfully.");
  //   } catch (e) {
  //     emptyViewText.value = "Failed to read DTC";
  //     print("❌ Exception in getDTCList: $e");
  //   } finally {
  //     isBusy.value = false;
  //     print("🔹 isBusy set to false");
  //   }
  // }

  Future<void> getDTCList() async {
  DTCFoundOrNotMessage.value = "Looking for DTC Record";
  emptyViewText.value = "Loading...";

  int count = 0;

  ecusList.clear();
  staticDtcList.clear();
  dtcList.clear();
  storedDtcList = [];

  try {
    isBusy.value = true;

    await Future.delayed(const Duration(milliseconds: 50));

    for (var ecu in StaticData.ecuInfo) {
      count++;

      int dtcDataset = ecu.dtcDatasetId ?? 0;

      /// 🔹 Load Local DTC Data
      String? dtcLocalData =
          await SaveLocalData().getData("DtcDataset_$dtcDataset");

      DtcResults? dtcLocal;

      if (dtcLocalData.isNotEmpty) {
        dtcLocal = DtcResults.fromJson(jsonDecode(dtcLocalData));
      }

      /// ❌ If no DTC from server
      if (dtcLocal == null ||
          dtcLocal.dtcCode == null ||
          dtcLocal.dtcCode!.isEmpty) {
        Get.dialog(
          CustomPopup(
            title: "Failed",
            message: "DTC not found from server",
            onButtonPressed: () => Get.back(),
          ),
        );
      }

      /// 🔹 Load Stored DTCs
      String? storedList =
          await SaveLocalData().getData("StoredDtcList_${ecu.ecuName}");

      if (storedList.isNotEmpty) {
        storedDtcList = (jsonDecode(storedList) as List)
            .map((e) => DtcCode.fromJson(e))
            .toList();
      }

      /// 🔹 Server list (LOCAL VARIABLE - IMPORTANT)
      List<DtcCode> dtcServerList = dtcLocal?.dtcCode ?? [];

      /// 🔹 Create ECU Model
      DtcEcusModel dtcEcusModel = DtcEcusModel(
        ecuName: ecu.ecuName,
        ecuId: ecu.ecuID,
        opacity: count == 1 ? 1.0 : 0.5,
        txHeader: ecu.txHeader,
        rxHeader: ecu.rxHeader,
        protocol: ecu.protocol,
        clearDtcIndex: ecu.clearDtcIndex,
        ffSet: ecu.ffSet,
        dtcList: [],
      );

      print(
          "Dtc View Model : ECU NAME = ${ecu.ecuName}, DTC DATASET ID = $dtcDataset");

      /// 🔹 If Read DTC from ECU
      if (isReadDtc.value) {
        if (count < 2) {
          dtcEcusModel = (await getDtc(dtcEcusModel, ecu))!;
        }

        ecusList.add(dtcEcusModel);

        /// 🔹 Empty handling
        if (ecusList.first.dtcList!.isEmpty) {
          if (readDtc.value != null) {
            if (readDtc.value!.status != null &&
                readDtc.value!.status != "NO_ERROR") {
              emptyViewText.value = readDtc.value!.status!;
            } else if (readDtc.value!.status == "NO_ERROR") {
              emptyViewText.value = "Dtc not found.";
            } else {
              emptyViewText.value = "ECU_COMMUNICATION_ERROR";
            }
          } else {
            emptyViewText.value = "ECU_COMMUNICATION_ERROR";
          }
        } else {
          emptyViewText.value = "Looking for DTC Record...";
        }
      } else {
        /// 🔹 If NOT reading from ECU → use server data
        dtcEcusModel.dtcList = dtcServerList
            .map((item) => DtcCode(
                  description: item.description,
                  id: item.id,
                  isActive: item.isActive,
                  code: item.code,
                ))
            .toList();

        ecusList.add(dtcEcusModel);
      }
    }

    /// 🔹 Assign first ECU data
    if (ecusList.isNotEmpty) {
      staticDtcList.assignAll(ecusList.first.dtcList ?? []);
      dtcList.assignAll(ecusList.first.dtcList ?? []);
      selectedEcu.value = ecusList.first;
    }
  } catch (e) {
    emptyViewText.value = "Failed to read DTC";
    print("❌ getDTCList error: $e");
  } finally {
    isBusy.value = false;
  }
}

  Future<DtcEcusModel?> getDtc(
      DtcEcusModel dtcEcusModel, EcuDataSet ecu) async {
    try {
      emptyViewText.value = "Loading...";
      dtcEcusModel.dtcList!.clear();
      print("🔹 Setting Dongle Properties for ECU: ${dtcEcusModel.ecuName}");

      // Set Dongle Properties
      await App.dllFunctions!.setDongleProperties(
        dtcEcusModel.protocol!.autopeepal ?? '',
        dtcEcusModel.txHeader ?? '',
        dtcEcusModel.rxHeader ?? '',
      );

      print("🔹 Reading DTC for ECU: ${dtcEcusModel.ecuName}");
      ReadDtcResponseModel? readDtcResponse =
          await App.dllFunctions!.readDtc(ecu.readDtcIndex ?? '');

      if (readDtcResponse != null) {
        print("🔹 ReadDtc Status: ${readDtcResponse.status}");

        if (readDtcResponse.status == "NO_ERROR") {
          int codeLength = readDtcResponse.dtcs?.length ?? 0;
          List<DtcCode> dummyList = [];
          print("🔹 Total DTC codes received: $codeLength");

          for (int i = 0; i < codeLength; i++) {
            try {
              String code = readDtcResponse.dtcs![i][0].toString();
              String dtcStatus = readDtcResponse.dtcs![i][1].toString();

              DtcCode dtcListModel = DtcCode(code: code);

              // Set status and color
              dtcListModel.statusActivation = dtcStatus;
              switch (dtcStatus) {
                case "Inactive":
                  dtcListModel.statusActivationColor = Colors.green;
                  break;
                case "Pending":
                  dtcListModel.statusActivationColor = Colors.orange;
                  break;
                case "Active":
                  dtcListModel.statusActivationColor = Colors.red;
                  break;
              }

              print("  ✅ DTC Code: $code, Status: $dtcStatus");

              // Map description from server list
              var desc = dtcServerList.firstWhere(
                (x) => x.code == dtcListModel.code,
                orElse: () => DtcCode(description: "Description not found"),
              );
              dtcListModel.description = desc.description;
              dtcListModel.id = desc.id;

              if (dtcListModel.statusActivation == "Active" ||
                  dtcListModel.statusActivation == "Inactive") {
                dummyList.add(dtcListModel);
              }
            } catch (e) {
              print("⚠️ Exception processing DTC index $i: $e");
            }
          }

          // Remove duplicates
          if (dummyList.isNotEmpty) {
            var distinctItems =
                {for (var e in dummyList) e.code: e}.values.toList();
            for (var x in distinctItems) {
              dtcEcusModel.dtcList!.add(DtcCode(
                description: x.description,
                id: x.id,
                isActive: x.isActive,
                code: x.code,
                lampActivation: x.lampActivation,
                lampActivationColor: x.lampActivationColor,
                statusActivation: x.statusActivation,
                statusActivationColor: x.statusActivationColor,
              ));
              print("  ✅ Added distinct DTC: ${x.code} - ${x.description}");
            }
          } else {
            emptyViewText.value = "Dtc not found.";
            print("⚠️ No valid DTCs found to add");
          }
        } else {
          emptyViewText.value = readDtcResponse.status!.isNotEmpty
              ? readDtcResponse.status!
              : "ECU_COMMUNICATION_ERROR";
          print("❌ DTC read error: ${emptyViewText.value}");
        }
      } else {
        emptyViewText.value = "ECU_COMMUNICATION_ERROR.";
        print("❌ readDtcResponse is null");
      }

      print(
          "🔹 Finished getDtc for ECU: ${dtcEcusModel.ecuName}, DTC count: ${dtcEcusModel.dtcList!.length}");
      return dtcEcusModel;
    } catch (e) {
      print("❌ Exception in getDtc: $e");
      emptyViewText.value = "ECU_COMMUNICATION_ERROR";
      return null;
    }
  }

  void searchDTC(String searchKey) {
    try {
      if (staticDtcList.isNotEmpty) {
        if (searchKey.isNotEmpty) {
          dtcList.assignAll(
            staticDtcList.where((s) =>
                (s.code ?? "")
                    .toLowerCase()
                    .contains(searchKey.toLowerCase()) ||
                (s.description ?? "")
                    .toLowerCase()
                    .contains(searchKey.toLowerCase())),
          );
        } else {
          dtcList.assignAll(staticDtcList);
        }
      }
    } catch (e) {
      print("❌ searchDTC error: $e");
    }
  }
}
