import 'dart:convert';

import 'package:autopeepal/common_widgets/commonLoader.dart';
import 'package:autopeepal/common_widgets/popup.dart';
import 'package:autopeepal/models/all_models.dart';
import 'package:autopeepal/models/flashRecord_model.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:autopeepal/services/api_services.dart';
import 'package:autopeepal/utils/extension/extension/string_extensions.dart';
import 'package:autopeepal/utils/save_local_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DataSyncController extends GetxController {
  RxBool isBusy = false.obs;
  RxString loaderText = ''.obs;
  RxString appName = ''.obs;
  RxString version = ''.obs;
  RxString buildNumber = ''.obs;
  final AuthApiService services = AuthApiService();

  Future<void> dataSyncMethod(BuildContext context) async {
  try {
    final loader = CommonLoader(message: "Updating Local Data...");
    Get.dialog(loader, barrierDismissible: false);

    isBusy.value = true;

    await Future.delayed(const Duration(milliseconds: 200));
    bool result = await updateModelToLocal(context);
    if (Get.isDialogOpen ?? false) Get.back();
    if (result) {
      Get.dialog(
        CustomPopup(
          title: "Success",
          message: "Local data updated successfully.",
          onButtonPressed: () {
            Get.back();
            Get.offAllNamed(Routes.loginScreen);
          },
        ),
        barrierDismissible: false,
      );
    } else {
      Get.dialog(
        CustomPopup(
          title: "Error",
          message: "Local data not updated.",
          onButtonPressed: () => Get.back(),
        ),
        barrierDismissible: false,
      );
    }
  } catch (e) {
    if (Get.isDialogOpen ?? false) Get.back();
    Get.dialog(
      CustomPopup(
        title: "Error",
        message: e.toString(),
        onButtonPressed: () => Get.back(),
      ),
      barrierDismissible: false,
    );
    debugPrint("Data Sync Error: $e");
  } finally {
    isBusy.value = false;
  }
}

  Future<void> loadAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    appName.value = info.appName;
    version.value = info.version;
    buildNumber.value = info.buildNumber;
  }

  Future<bool> updateModelToLocal(BuildContext context) async {
    bool returnValue = false;

    try {
      // 🔹 Get app version (if needed)
      await loadAppInfo();

      // 🔹 Fetch all models from API/service
      AllModelsModel result = await AuthApiService.getAllModels();

      if (result.message == "success") {
        // Save full model list locally
        final modelLocalList = jsonEncode(result.toJson());
        await SaveLocalData.saveData("MODEL_LocalList", modelLocalList);
      } else {
        // Show error dialog if API failed
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Error in Get All Model"),
            content: Text(result.message ?? ''),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
        return false;
      }

      // 🔹 Start updating dependent local data
      if (await downloadPidDtcToLocal(result.results!,context)) {
        // returnValue = await downloadSequenceFileToLocal(result.results);
        returnValue = await updateFlashRecordToLocal(result.results!,context);
        if (returnValue) returnValue = await updateIorListToLocal(context);
        if (returnValue) returnValue = await updateActuatorListToLocal(context);
        if (returnValue) returnValue = await updateGDToLocal(context,result.results!);
        // if (returnValue) returnValue = await updateSDDToLocal();
        // if (returnValue && Platform.isAndroid) returnValue = await updateBAPreconditionToLocal();
        if (returnValue) returnValue = await updateFreezeFrameListToLocal(context);
        if (returnValue) returnValue = await updateDoipConfigToLocal(context);
        // if (returnValue) returnValue = await updateVariantListToLocal();
        // if (returnValue) returnValue = await updateParameterListToLocal();
      }
    } catch (e) {
      debugPrint("Error in updateModelToLocal: $e");
      returnValue = false;
    }

    return returnValue;
  }

  Future<bool> downloadPidDtcToLocal(
      List<ModelResult>? models, BuildContext context) async {
    try {
      bool result = false;
      List<Dataset> dtcDatasetList = [];
      List<PidDataset> pidDatasetList = [];

      if (models != null && models.isNotEmpty) {
        for (var model in models) {
          if (model.subModels != null && model.subModels!.isNotEmpty) {
            for (var subModel in model.subModels!) {
              if (subModel.ecus != null && subModel.ecus!.isNotEmpty) {
                for (var ecu in subModel.ecus!) {
                  // Collect DTC datasets
                  if (ecu.datasets != null && ecu.datasets!.isNotEmpty) {
                    dtcDatasetList.addAll(ecu.datasets!);
                  }
                  // Collect PID datasets
                  if (ecu.pidDatasets != null && ecu.pidDatasets!.isNotEmpty) {
                    pidDatasetList.addAll(ecu.pidDatasets!);
                  }
                }
              }
            }
          }
        }
      }

      // Download PID datasets locally
      result = await downloadPidToLocal(pidDatasetList,context);
      if (result) {
        // Download DTC datasets locally
        result = await downloadDtcToLocal(dtcDatasetList,context);
      }

      return result;
    } catch (e) {
      debugPrint("Exception in Saving PID & DTC Data: $e");

      // Show alert dialog on main thread
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Exception in Saving PID & DTC Data"),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }

      return false;
    }
  }

  Future<bool> downloadPidToLocal(
      List<PidDataset> pidDatasets, BuildContext context) async {
    bool returnValue = false;

    try {
      if (pidDatasets.isNotEmpty) {
        // Group datasets by id
        final grouped = <String, List<PidDataset>>{};
        for (var pid in pidDatasets) {
          grouped.putIfAbsent(pid.id.toString(), () => []).add(pid);
        }

        for (var entry in grouped.entries) {
          final key = entry.key;

          // Call service to get PIDs
          final pids = await services.getPids(key.toINT);
          if (pids.message == "success") {
            if (pids.results!.isNotEmpty) {
              final pidJson = jsonEncode(pids.results![0]);
              await SaveLocalData.saveData(
                  "PidDataset_${pids.results![0].id}", pidJson);
              returnValue = true;
            }
          } else {
            // Show error alert
            if (context.mounted) {
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Error in Saving PID Data"),
                  content: Text(pids.message ?? ''),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            }
            return false;
          }
        }
      }

      return returnValue;
    } catch (e) {
      debugPrint("Exception in Saving PID Data: $e");

      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Exception in Saving PID Data"),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }

      return false;
    }
  }

  Future<bool> downloadDtcToLocal(
      List<Dataset> datasets, BuildContext context) async {
    bool returnValue = false;

    try {
      if (datasets.isNotEmpty) {
        // Group datasets by id
        final grouped = <String, List<Dataset>>{};
        for (var dtc in datasets) {
          grouped.putIfAbsent(dtc.id.toString(), () => []).add(dtc);
        }

        for (var entry in grouped.entries) {
          final key = entry.key;

          // Call service to get DTCs
          final dtcs = await services.getDtcs(key.toINT);
          if (dtcs.message == "success") {
            if (dtcs.results!.isNotEmpty) {
              final dtcJson = jsonEncode(dtcs.results![0]);
              await SaveLocalData.saveData(
                  "DtcDataset_${dtcs.results![0].id}", dtcJson);
              returnValue = true;
            }
          } else {
            // Show error alert
            if (context.mounted) {
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Error in Saving DTC Data"),
                  content: Text(dtcs.message ?? ''),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            }
            return false;
          }
        }
      }

      return returnValue;
    } catch (e) {
      debugPrint("Exception in Saving DTC Data: $e");

      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Exception in Saving DTC Data"),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }

      return false;
    }
  }

  Future<bool> updateFlashRecordToLocal(
      List<ModelResult> models, BuildContext context) async {
    try {
      List<Ecu2> ecu2List = [];

      // 🔹 Extract ECU2 objects from models
      for (var model in models) {
        if (model.subModels != null) {
          for (var subModel in model.subModels!) {
            if (subModel.ecus != null) {
              for (var ecuWrapper in subModel.ecus!) {
                if (ecuWrapper.ecu != null && ecuWrapper.ecu!.isNotEmpty) {
                  ecu2List.add(ecuWrapper.ecu!.first);
                }
              }
            }
          }
        }
      }

      if (ecu2List.isNotEmpty) {
        // Group by id
        final grouped = <String, List<Ecu2>>{};
        for (var ecu in ecu2List) {
          grouped.putIfAbsent(ecu.id.toString(), () => []).add(ecu);
        }

        // Download and save files locally
        for (var entry in grouped.entries) {
          final ecu = entry.value.first;

          // Download sequence file
          final sequenceFileContent =
              await services.downloadFileContent(ecu.sequenceFile ?? '');
          await SaveLocalData.saveData(
              "flashRecord_sequence_file_${ecu.id}", sequenceFileContent);

          // Download each associated file
          if (ecu.file != null && ecu.file!.isNotEmpty) {
            for (var file in ecu.file!) {
              final dataFileContent =
                  await services.downloadFileContent(file.dataFile ?? '');
              await SaveLocalData.saveData(
                  "file_data_file_${file.id}", dataFileContent);
            }
          }
        }
      }

      return true;
    } catch (e) {
      debugPrint("Exception in Saving Flash Record Data: $e");

      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Exception in Saving Flash Record Data"),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }

      return false;
    }
  }

  Future<bool> updateIorListToLocal(BuildContext context) async {
  try {
    bool returnValue = false;

    // 🔹 Call service to get IOR data
    final res = await services.getIorTest();

    if (res.message == "success") {
      final iorLocalList = jsonEncode(res);
      await SaveLocalData.saveData("IOR_LocalList", iorLocalList);
      returnValue = true;
    } else {
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Error in Saving IOR Data"),
            content: Text(res.message??''),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
      returnValue = false;
    }

    return returnValue;
  } catch (e) {
    debugPrint("Exception in Saving IOR Data: $e");

    if (context.mounted) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Exception in Saving IOR Data"),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }

    return false;
  }
}

Future<bool> updateActuatorListToLocal(BuildContext context) async {
  try {
    bool returnValue = false;

    // 🔹 Call service to get Actuator data
    final res = await services.getActuatorTest();

    if (res.message == "success") {
      final actuatorLocalList = jsonEncode(res);
      await SaveLocalData.saveData("Actuator_LocalList", actuatorLocalList);
      returnValue = true;
    } else {
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Error in Saving Actuator Data"),
            content: Text(res.message??''),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
      returnValue = false;
    }

    return returnValue;
  } catch (e) {
    debugPrint("Exception in Saving Actuator Data: $e");

    if (context.mounted) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Exception in Saving Actuator Data"),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }

    return false;
  }
}

Future<bool> updateGDToLocal(BuildContext context, List<ModelResult> modelList) async {
  try {
    bool returnValue = true;

    for (var model in modelList) {
      final subModels = model.subModels ?? [];
      for (var subModel in subModels) {
        final res = await services.getGD(subModel.id??0);

        if (res.message == "success") {
          final gdLocalList = jsonEncode(res);
          await SaveLocalData.saveData("GD_LocalList_${subModel.id}", gdLocalList);
          returnValue = true;
        } else {
          if (context.mounted) {
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Error in Saving GD Data"),
                content: Text(res.message??''),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("OK"),
                  ),
                ],
              ),
            );
          }
          return false;
        }
      }
    }

    return returnValue;
  } catch (e) {
    debugPrint("Exception in Saving GD Data: $e");

    if (context.mounted) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Exception in Saving GD Data"),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }

    return false;
  }
}

Future<bool> updateDoipConfigToLocal(BuildContext context) async {
  try {
    bool returnValue = false;

    final res = await services.getDoipConfiguration();

    if (res.message == "success") {
      final doipConfigLocalList = jsonEncode(res);
      await SaveLocalData.saveData("DoipConfig_LocalList", doipConfigLocalList);
      returnValue = true;
    } else {
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Error in Doip Config Data"),
            content: Text(res.message??''),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Ok"),
              ),
            ],
          ),
        );
      }
      returnValue = false;
    }

    return returnValue;
  } catch (e) {
    debugPrint("Exception in Saving Doip Config Data: $e");

    if (context.mounted) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Exception in Saving Doip Config Data"),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Ok"),
            ),
          ],
        ),
      );
    }

    return false;
  }
}

Future<bool> updateListNumbersToLocal(BuildContext context) async {
  try {
    bool returnValue = false;

    final res = await services.getListNumbers();

    if (res.message == "success") {
      final listNumberLocalList = jsonEncode(res);
      await SaveLocalData.saveData("ListNumber_LocalList", listNumberLocalList);
      returnValue = true;
    } else {
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Error in Saving List Number Data"),
            content: Text(res.message??''),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Ok"),
              ),
            ],
          ),
        );
      }
      returnValue = false;
    }

    return returnValue;
  } catch (e) {
    debugPrint("Exception in Saving List Number Data: $e");

    if (context.mounted) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Exception in Saving List Number Data"),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Ok"),
            ),
          ],
        ),
      );
    }

    return false;
  }
}

Future<bool> updateFreezeFrameListToLocal(BuildContext context) async {
  try {
    bool returnValue = false;

    final res = await services.getFreezeFrameList();

    if (res.message == "success") {
      final freezeFrameLocalList = jsonEncode(res);
      await SaveLocalData.saveData("FreezeFrame_LocalList", freezeFrameLocalList);
      returnValue = true;
    } else {
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Error in Saving Freeze Frame Data"),
            content: Text(res.message??''),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Ok"),
              ),
            ],
          ),
        );
      }
      returnValue = false;
    }

    return returnValue;
  } catch (e) {
    debugPrint("Exception in Saving Freeze Frame Data: $e");

    if (context.mounted) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Exception in Saving Freeze Frame Data"),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Ok"),
            ),
          ],
        ),
      );
    }

    return false;
  }
}
}
