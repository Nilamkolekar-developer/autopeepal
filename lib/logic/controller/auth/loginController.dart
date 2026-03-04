import 'dart:convert';
import 'dart:io';
import 'package:autopeepal/AppPreferences/app_areferences.dart';
import 'package:autopeepal/models/actuatorTest_model.dart';
import 'package:autopeepal/models/all_models.dart';
import 'package:autopeepal/models/doipConfigFile_model.dart';
import 'package:autopeepal/models/flashRecord_model.dart';
import 'package:autopeepal/models/freezeFrame_model.dart';
import 'package:autopeepal/models/gd_model.dart';
import 'package:autopeepal/models/iotTest_model.dart';
import 'package:autopeepal/models/listNumber_model.dart';

import 'package:autopeepal/models/user_model.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:autopeepal/services/api_services.dart';
import 'package:autopeepal/utils/get_device_unique_id.dart';
import 'package:autopeepal/utils/save_local_data.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  @override
  void onInit() {
    super.onInit();

    String? savedUser = box.read('username');
    String? savedPass = box.read('password');

    if (savedUser != null && savedPass != null) {
      usernameController.value.text = savedUser;
      passwordController.value.text = savedPass;
      rememberMe.value = true;
    }
  }

  final isLoading = false.obs;
  Rx<TextEditingController> usernameController = TextEditingController().obs;
  Rx<TextEditingController> passwordController = TextEditingController().obs;
  RxString devicetype = "".obs;
  RxString macId = "".obs;
  Rx<TextEditingController> forgetEmailController = TextEditingController().obs;
  Rx<TextEditingController> verifyOTPController = TextEditingController().obs;
  RxBool hidePassword = true.obs;
  RxString verifyEmail = "".obs;
  RxBool rememberMe = false.obs;
  UserResModel? userResModel;
  UserModel? userRequestModel;
  final box = GetStorage();

  void saveCredentials() {
    box.write('username', usernameController.value.text);
    box.write('password', passwordController.value.text);
  }

  void clearSavedCredentials() {
    box.remove('username');
    box.remove('password');
  }

  Future<void> loginMethod() async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      isLoading.value = true;

      // ================= VALIDATION =================
      if (usernameController.value.text.trim().isEmpty &&
          passwordController.value.text.trim().isEmpty) {
        Get.snackbar("Alert", "Enter user name and password.");
        return;
      } else if (usernameController.value.text.trim().isEmpty) {
        Get.snackbar("Alert", "Enter user name");
        return;
      } else if (passwordController.value.text.trim().isEmpty) {
        Get.snackbar("Alert", "Enter user password");
        return;
      }

      // ================= DEVICE INFO =================
      final deviceId = await GetDeviceUniqueId.getId();
      debugPrint("DEVICE ID: $deviceId");

      String platform = "";
      if (Platform.isAndroid) {
        platform = "android";
      } else if (Platform.isIOS) {
        platform = "ios";
      } else if (Platform.isWindows) {
        platform = "windows";
      }

      final userRequestModel = UserModel(
        username: usernameController.value.text.trim(),
        password: passwordController.value.text.trim(),
        deviceType: platform,
        macId: deviceId,
      );

      // ================= NETWORK CHECK =================
      final connectivityResult = await Connectivity().checkConnectivity();
      final isReachable = connectivityResult != ConnectivityResult.none;

      bool isLoggedIn = false;

     // Inside loginMethod()
if (isReachable) {
  isLoggedIn = await loginOnline(userRequestModel);
  
  // ADD THIS: If online login fails due to API error, try offline fallback
  if (!isLoggedIn) {
    debugPrint("[LOGIN] Online attempt failed. Trying offline fallback...");
    isLoggedIn = await loginOffline(userRequestModel);
  }
} else {
  isLoggedIn = await loginOffline(userRequestModel);
}
      // ================= POST LOGIN =================
      if (isLoggedIn && userResModel != null) {
        final prefs = await SharedPreferences.getInstance();

        if (rememberMe.value) {
          await prefs.setString("user_id", userRequestModel.username);
          await prefs.setString("password", userRequestModel.password);

          await SaveLocalData.saveData(
            "RememberIsChecked",
            jsonEncode({
              "username": userRequestModel.username,
              "password": userRequestModel.password,
              "device_type": platform,
              "mac_id": deviceId,
              "RememberIsChecked": true,
            }),
          );
        } else {
          await prefs.setString("user_id", "");
          await prefs.setString("password", "");

          await SaveLocalData.saveData(
            "RememberIsChecked",
            jsonEncode({
              "RememberIsChecked": false,
            }),
          );
        }

        // ================= SAVE SESSION =================
        prefs.setString("macId", deviceId);
        prefs.setString("UserName", userRequestModel.username);
        prefs.setString("MasterLoginUserBY",
            "${userResModel!.firstName} ${userResModel!.lastName}");
        prefs.setString("rolewhilelogin", userResModel!.role ?? "");
        prefs.setInt("oemId", userResModel!.profile?.oem?.id ?? 0);

        // ================= GLOBAL APP DATA =================
        await AppPreferences.saveLicences(userResModel!.licences!.toJson());
        await AppPreferences.saveVehicleModels(
          userResModel!.profile!.workshopGroupModels!
              .map((e) => e.toJson())
              .toList(),
        );

        // ================= NAVIGATION =================
        Get.toNamed(Routes.dashboardScreen);
      }
    } catch (e) {
      Get.snackbar("Login Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  
  Future<bool> loginOnline(UserModel userRequestModel) async {
    try {
      bool returnValue = false;
      print(
          "[LOGIN] Starting online login for user: ${userRequestModel.username}");

      userResModel = await AuthApiService.login(userRequestModel);

      if (userResModel != null &&
          userResModel!.token != null &&
          userResModel!.userId != null) {
        print("[LOGIN] Login successful, saving data...");

        // Save OEM ID
        final prefs = await SharedPreferences.getInstance();
        final previousOem = prefs.getInt("oemId") ?? 0;
        final currentOem = userResModel!.profile?.oem?.id ?? 0;
        await AppPreferences.setInt("oemId", currentOem);

        // Save tokens
        await AppPreferences.saveTokens(
          accessToken: userResModel!.token?.access ?? '',
          refreshToken: userResModel!.token?.refresh ?? '',
        );

        // Save local data
        await SaveLocalData.saveData(
          "UserDetail_LocalData",
          jsonEncode(userResModel!.toJson()),
        );
        await SaveLocalData.saveData(
          "UserRequest_LocalData",
          jsonEncode(userRequestModel.toJson()),
        );

        // Local model data check (optional)
        String? modelLocalList = await SaveLocalData.getData("MODEL_LocalList");
        String? iorLocalList = await SaveLocalData.getData("IOR_LocalList");
        String? actuatorLocalList =
            await SaveLocalData.getData("Actuator_LocalList");
        String? freezeFrameLocalList =
            await SaveLocalData.getData("FreezeFrame_LocalList");

        // ignore: unnecessary_null_comparison
        if (modelLocalList == null ||
            // ignore: unnecessary_null_comparison
            iorLocalList == null ||
            // ignore: unnecessary_null_comparison
            actuatorLocalList == null ||
            // ignore: unnecessary_null_comparison
            freezeFrameLocalList == null ||
            previousOem != currentOem) {
          print(
              "[LOGIN] Local data missing or OEM changed. Updating local data...");
          // If you have updateModelToLocal(), call it here
           await updateModelToLocal();
        } else {
          print("[LOGIN] Using existing local data");
          // Optional: await loginOffline(userRequestModel);
        }

        // ✅ Mark login success
        returnValue = true;
      } else {
        print(
            "[LOGIN] Login failed: Invalid response or missing token/user_id");
        Get.snackbar("Error", userResModel?.message ?? "Login failed");
        returnValue = false;
      }

      print("[LOGIN] loginOnline ended with returnValue: $returnValue");
      return returnValue;
    } catch (e) {
      print("[LOGIN] Exception during loginOnline: $e");
      Get.snackbar("Error", e.toString());
      return false;
    }
  }

  Future<bool> updateModelToLocal() async {
    bool returnValue = false;

    try {
      // ================= GET LOCAL DATA =================
      String? localData = await SaveLocalData.getData("MODEL_LocalList");

      late AllModelsModel result;

      if (localData.isEmpty) {
        // ================= FETCH FROM API =================
        result = await AuthApiService.getAllModels();

        if (result.message == "success") {
          String modelLocalList = jsonEncode(result.toJson());
          await SaveLocalData.saveData("MODEL_LocalList", modelLocalList);
          print("[LOCAL] Saved MODEL_LocalList");
        } else {
          await Get.defaultDialog(
            title: "Error in Get All Model",
            middleText: result.message ?? "Unknown error",
          );
          return false;
        }
      } else {
        // ================= LOAD FROM LOCAL =================
        result = AllModelsModel.fromJson(jsonDecode(localData));
        print("[LOCAL] Using existing MODEL_LocalList");
      }

      // ================= UPDATE SEQUENTIAL DATA =================
      if (await downloadPidDtcToLocal(result.results!)) {
        returnValue = await updateFlashRecordToLocal(result.results!);
        if (returnValue) returnValue = await updateIorListToLocal();
        if (returnValue) returnValue = await updateActuatorListToLocal();
       // if (returnValue) returnValue = await updateGDToLocal(result.results!);
        if (returnValue) returnValue = await updateFreezeFrameListToLocal();
        if (returnValue) returnValue = await updateDoipConfigToLocal();
      }
    } catch (e, stackTrace) {
      print("[ERROR] updateModelToLocal: $e\n$stackTrace");
      returnValue = false;
    }

    return returnValue;
  }

  Future<bool> downloadPidDtcToLocal(List<ModelResult> models) async {
    try {
      List<Dataset> dtcDatasetList = [];
      List<PidDataset> pidDatasetList = [];

      if (models.isNotEmpty) {
        for (var model in models) {
          if (model.subModels != null && model.subModels!.isNotEmpty) {
            for (var subModel in model.subModels!) {
              if (subModel.ecus != null && subModel.ecus!.isNotEmpty) {
                for (var ecu in subModel.ecus!) {
                  if (ecu.datasets != null && ecu.datasets!.isNotEmpty) {
                    dtcDatasetList.addAll(ecu.datasets!);
                  }
                  if (ecu.pidDatasets != null && ecu.pidDatasets!.isNotEmpty) {
                    pidDatasetList.addAll(ecu.pidDatasets!);
                  }
                }
              }
            }
          }
        }
      }

      // Download PIDs first
      bool result = await downloadPidToLocal(pidDatasetList);

      // If successful, download DTCs
      if (result) {
        result = await downloadDtcToLocal(dtcDatasetList);
      }

      return result;
    } catch (e) {
      // Replace with your own dialog/snackbar method if needed
      print("Exception in Saving PID & DTC Data: $e");
      return false;
    }
  }

  Future<bool> downloadPidToLocal(List<PidDataset> pidDatasets) async {
    try {
      if (pidDatasets.isEmpty) return false;

      // 🔹 Group by dataset id
      final Map<int, List<PidDataset>> grouped = {};
      for (final pid in pidDatasets) {
        if (pid.id == null) continue;
        grouped.putIfAbsent(pid.id!, () => []).add(pid);
      }

      if (grouped.isEmpty) return false;

      // 🔹 API service instance
      final AuthApiService services = AuthApiService();

      for (final entry in grouped.entries) {
        final datasetId = entry.key;

        final pids = await services.getPids(datasetId);

        if (pids.message == "success") {
          if (pids.results != null && pids.results!.isNotEmpty) {
            // Save FIRST result (same as your C# logic)
            final pidJson = jsonEncode(pids.results![0].toJson());

            await SaveLocalData.saveData(
              "PidDataset_${pids.results![0].id}",
              pidJson,
            );
          }
        } else {
          await Get.defaultDialog(
            title: "Error in Saving PID Data",
            middleText: pids.message ?? "Unknown error",
          );
          return false;
        }
      }

      return true; // ✅ all datasets saved
    } catch (e) {
      await Get.defaultDialog(
        title: "Exception in Saving PID Data",
        middleText: e.toString(),
      );
      return false;
    }
  }

  Future<bool> downloadDtcToLocal(List<Dataset> datasets) async {
    try {
      if (datasets.isEmpty) return false;

      // 🔹 Group by dataset id
      final Map<int, List<Dataset>> grouped = {};
      for (final data in datasets) {
        if (data.id == null) continue;
        grouped.putIfAbsent(data.id!, () => []).add(data);
      }

      if (grouped.isEmpty) return false;

      // 🔹 API service instance
      final AuthApiService services = AuthApiService();

      for (final entry in grouped.entries) {
        final datasetId = entry.key;

        final dtcs = await services.getDtcs(datasetId);

        if (dtcs.message == "success") {
          if (dtcs.results != null && dtcs.results!.isNotEmpty) {
            // Save FIRST result (same behavior as C#)
            final dtcJson = jsonEncode(dtcs.results![0].toJson());

            await SaveLocalData.saveData(
              "DtcDataset_${dtcs.results![0].id}",
              dtcJson,
            );
          }
        } else {
          await Get.defaultDialog(
            title: "Error in Saving DTC Data",
            middleText: dtcs.message ?? "Unknown error",
          );
          return false;
        }
      }

      return true; // ✅ all datasets saved
    } catch (e) {
      await Get.defaultDialog(
        title: "Exception in Saving DTC Data",
        middleText: e.toString(),
      );
      return false;
    }
  }

  Future<bool> updateFlashRecordToLocal(List<ModelResult>? models) async {
    try {
      final List<Ecu2> ecu2List = [];

      // 🔹 Collect ECU2 list safely
      if (models != null && models.isNotEmpty) {
        for (final model in models) {
          final subModels = model.subModels;
          if (subModels == null || subModels.isEmpty) continue;

          for (final subModel in subModels) {
            final ecus = subModel.ecus;
            if (ecus == null || ecus.isEmpty) continue;

            for (final ecu in ecus) {
              final ecuList = ecu.ecu;
              if (ecuList != null && ecuList.isNotEmpty) {
                ecu2List.add(ecuList.first); // same as ecu.ecu[0]
              }
            }
          }
        }
      }

      if (ecu2List.isEmpty) return true;

      // 🔹 Group by ECU id
      final Map<int, List<Ecu2>> grouped = {};
      for (final ecu in ecu2List) {
        if (ecu.id == null) continue;
        grouped.putIfAbsent(ecu.id!, () => []).add(ecu);
      }

      final AuthApiService services = AuthApiService();

      // 🔹 Download & save files
      for (final entry in grouped.entries) {
        final Ecu2 ecu = entry.value.first;

        // Save sequence file
        final String sequenceContent =
            await services.downloadFileContent(ecu.sequenceFile ?? '');

        await SaveLocalData.saveData(
          "flashRecord_sequence_file_${ecu.id}",
          sequenceContent,
        );

        // Save ECU data files
        final files = ecu.file;
        if (files != null && files.isNotEmpty) {
          for (final file in files) {
            final String fileContent =
                await services.downloadFileContent(file.dataFile ?? '');

            await SaveLocalData.saveData(
              "file_data_file_${file.id}",
              fileContent,
            );
          }
        }
      }

      return true;
    } catch (e) {
      await Get.defaultDialog(
        title: "Exception in Saving Flash Record Data",
        middleText: e.toString(),
      );
      return false;
    }
  }

  Future<bool> updateIorListToLocal() async {
    try {
      // 🔹 Read local data (empty means not saved yet)
      final String localData =
          await SaveLocalData.getData("IOR_LocalList");

      // 🔹 If not available locally, fetch from API
      if (localData.trim().isEmpty) {
        final AuthApiService services = AuthApiService();
        final IorTestModel res = await services.getIorTest();

        if (res.message == "success") {
          final String iorLocalJson = jsonEncode(res.toJson());
          await SaveLocalData.saveData("IOR_LocalList", iorLocalJson);
          return true;
        } else {
          await Get.defaultDialog(
            title: "Error in Saving IOR Data",
            middleText: res.message ?? "Unknown error",
          );
          return false;
        }
      }

      // 🔹 Already available locally
      return true;
    } catch (e) {
      await Get.defaultDialog(
        title: "Exception in Saving IOR Data",
        middleText: e.toString(),
      );
      return false;
    }
  }

  Future<bool> updateActuatorListToLocal() async {
    try {
      // 🔹 Read local cache
      final String localData =
          await SaveLocalData.getData("Actuator_LocalList");

      // 🔹 If not cached locally, fetch from API
      if (localData.trim().isEmpty) {
        final AuthApiService services = AuthApiService();
        final ActuatorTestModel res = await services.getActuatorTest();

        if (res.message == "success") {
          final String actuatorLocalJson = jsonEncode(res.toJson());
          await SaveLocalData.saveData(
            "Actuator_LocalList",
            actuatorLocalJson,
          );
          return true;
        } else {
          await Get.defaultDialog(
            title: "Error in Saving Actuator Data",
            middleText: res.message ?? "Unknown error",
          );
          return false;
        }
      }

      // 🔹 Already cached
      return true;
    } catch (e) {
      await Get.defaultDialog(
        title: "Exception in Saving Actuator Data",
        middleText: e.toString(),
      );
      return false;
    }
  }

  Future<bool> updateGDToLocal(List<ModelResult> modelList) async {
    try {
      bool returnValue = true;

      if (modelList.isEmpty) return true;

      final AuthApiService services = AuthApiService();

      for (final model in modelList) {
        final subModels = model.subModels;
        if (subModels == null || subModels.isEmpty) continue;

        for (final subModel in subModels) {
          // 🔹 Read local cache
          final String localData =
              await SaveLocalData.getData("GD_LocalList_${subModel.id}");

          // 🔹 If not cached, fetch from API
          if (localData.trim().isEmpty) {
            final GdModelGD res = await services.getGD(subModel.id!);

            if (res.message == "success") {
              final String gdLocalJson = jsonEncode(res.toJson());

              await SaveLocalData.saveData(
                "GD_LocalList_${subModel.id}",
                gdLocalJson,
              );

              returnValue = true;
            } else {
              await Get.defaultDialog(
                title: "Error in Saving GD Data",
                middleText: res.message ?? "Unknown error",
              );
              return false; // ❌ fail fast
            }
          }
        }
      }

      return returnValue;
    } catch (e) {
      await Get.defaultDialog(
        title: "Exception in Saving GD Data",
        middleText: e.toString(),
      );
      return false;
    }
  }

  Future<bool> updateFreezeFrameListToLocal() async {
    try {
      // 🔹 Read local cache
      final String localData =
          await SaveLocalData.getData("FreezeFrame_LocalList");

      // 🔹 If not cached, fetch from API
      if (localData.trim().isEmpty) {
        final AuthApiService services = AuthApiService();
        final FreezeFrameModel res = await services.getFreezeFrameList();

        if (res.message == "success") {
          final String freezeFrameLocalJson = jsonEncode(res.toJson());

          await SaveLocalData.saveData(
            "FreezeFrame_LocalList",
            freezeFrameLocalJson,
          );
          return true;
        } else {
          await Get.defaultDialog(
            title: "Error in Saving Freeze Frame Data",
            middleText: res.message ?? "Unknown error",
          );
          return false;
        }
      }

      // 🔹 Already cached
      return true;
    } catch (e) {
      await Get.defaultDialog(
        title: "Exception in Saving Freeze Frame Data",
        middleText: e.toString(),
      );
      return false;
    }
  }

  Future<bool> updateDoipConfigToLocal() async {
    try {
      // 🔹 Read local cache
      final String localData =
          await SaveLocalData.getData("DoipConfig_LocalList");

      // 🔹 If not cached, fetch from API
      if (localData.trim().isEmpty) {
        final AuthApiService services = AuthApiService();
        final DoipConfigRootModel res = await services.getDoipConfiguration();

        if (res.message == "success") {
          final String doipConfigLocalJson = jsonEncode(res.toJson());

          await SaveLocalData.saveData(
            "DoipConfig_LocalList",
            doipConfigLocalJson,
          );
          return true;
        } else {
          await Get.defaultDialog(
            title: "Error in Doip Config Data",
            middleText: res.message ?? "Unknown error",
          );
          return false;
        }
      }

      // 🔹 Already cached
      return true;
    } catch (e) {
      await Get.defaultDialog(
        title: "Exception in Saving Doip Config Data",
        middleText: e.toString(),
      );
      return false;
    }
  }

 Future<bool> updateListNumbersToLocal() async {
  try {
    // 🔹 Read local cache
    final String localData =
        await SaveLocalData.getData("ListNumber_LocalList");

    // 🔹 If not cached, fetch from API
    if (localData.trim().isEmpty) {
      final AuthApiService services = AuthApiService();
      final ListNumberRootModel res =
          await services.getListNumbers();

      if (res.message == "success") {
        final String listNumberLocalJson =
            jsonEncode(res.toJson());

        await SaveLocalData.saveData(
          "ListNumber_LocalList",
          listNumberLocalJson,
        );
        return true;
      } else {
        await Get.defaultDialog(
          title: "Error in List Number Data",
          middleText: res.message ?? "Unknown error",
        );
        return false;
      }
    }

    // 🔹 Already cached
    return true;
  } catch (e) {
    await Get.defaultDialog(
      title: "Exception in Saving List Number Data",
      middleText: e.toString(),
    );
    return false;
  }
}

  Future<bool> loginOffline(UserModel userRequestModel) async {

  try {
    bool returnValue = true;

    final String modelLocalList =
        await SaveLocalData.getData("MODEL_LocalList");
    final String iorLocalList =
        await SaveLocalData.getData("IOR_LocalList");
    final String actuatorLocalList =
        await SaveLocalData.getData("Actuator_LocalList");
    final String freezeFrameLocalList =
        await SaveLocalData.getData("FreezeFrame_LocalList");

    // 🔹 Check mandatory offline data
    if (modelLocalList.trim().isEmpty ||
        iorLocalList.trim().isEmpty ||
        actuatorLocalList.trim().isEmpty ||
        freezeFrameLocalList.trim().isEmpty) {
      await Get.defaultDialog(
        title: "Failed",
        middleText:
            "Local data not completely updated.\nTry to login with internet.",
      );

      // clear invalid cache
      await SaveLocalData.saveData("MODEL_LocalList", "");
      return false;
    }

    // 🔹 Read user cached data
    final String responseData =
        await SaveLocalData.getData("UserDetailL_LocalData");
    final String requestData =
        await SaveLocalData.getData("UserRequest_LocalData");

    if (responseData.trim().isEmpty || requestData.trim().isEmpty) {
      await Get.defaultDialog(
        title: "Failed",
        middleText: "Try to login with internet.",
      );
      return false;
    }

    // 🔹 Deserialize cached login data
    final UserResModel userResModel =
        UserResModel.fromJson(jsonDecode(responseData));


    if (userResModel.message == "success") {
  // 🔹 Read from SharedPreferences
  final String? accessToken = await AppPreferences.getAccessToken();
  final int? oemId = await AppPreferences.getInt('oemId');

  if (accessToken == null || oemId == null) {
    returnValue = false;
  } 
} else {
  returnValue = false;
}

    return returnValue;
  } catch (e) {
    await Get.defaultDialog(
      title: "Error",
      middleText: e.toString(),
    );
    return false;
  }
}


}
