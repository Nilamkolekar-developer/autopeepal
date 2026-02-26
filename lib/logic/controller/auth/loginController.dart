import 'dart:convert';
import 'dart:io';

import 'package:autopeepal/AppPreferences/app_areferences.dart';
import 'package:autopeepal/api/app_envirments.dart';
import 'package:autopeepal/models/all_models.dart';

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

      if (isReachable) {
        isLoggedIn = await loginOnline(userRequestModel);
      } else {
        // isLoggedIn = await loginOffline(userRequestModel);
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
          // await updateModelToLocal();
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

  Future<bool> updateModelToLocal(int? oemId) async {
    bool returnValue = false;

    try {
      // ================= GET LOCAL DATA =================
      String? localData = await SaveLocalData.getData("MODEL_LocalList");

      late AllModelsModel result;

      if (localData == null || localData.isEmpty) {
        // ================= FETCH FROM API =================
        result = await AuthApiService.getAllModels(oemId);

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
        if (returnValue) returnValue = await updateGDToLocal(result.results!);
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
    bool returnValue = false;

    try {
      if (pidDatasets.isNotEmpty) {
        // Group by ID
        final grouped = <int, List<PidDataset>>{};
        for (var pid in pidDatasets) {
          grouped.putIfAbsent(pid.id, () => []).add(pid);
        }

        for (var entry in grouped.entries) {
          final key = entry.key;

          // Call API for each PID group
          final pids = await AuthApiService.getPids(key);

          if (pids.message == "success" && pids.results.isNotEmpty) {
            // Save first result to local storage
            final pidJson = jsonEncode(pids.results[0].toJson());
            await SaveLocalData.saveData(
                "PidDataset_${pids.results[0].id}", pidJson);
            returnValue = true;
          } else {
            // Show error dialog (replace with GetX or your preferred method)
            await Get.defaultDialog(
              title: "Error in Saving PID Data",
              middleText: pids.message,
            );
            return false;
          }
        }
      }
      return returnValue;
    } catch (e) {
      // Show exception
      await Get.defaultDialog(
        title: "Exception in Saving PID Data",
        middleText: e.toString(),
      );
      return false;
    }
  }

  Future<bool> downloadDtcToLocal(List<Dataset> datasets) async {
    bool returnValue = false;

    try {
      if (datasets.isNotEmpty) {
        // Group datasets by ID
        final grouped = <int, List<Dataset>>{};
        for (var dtc in datasets) {
          grouped.putIfAbsent(dtc.id, () => []).add(dtc);
        }

        for (var entry in grouped.entries) {
          final key = entry.key;

          // Call API for each group
          final dtcs = await AuthApiService.getDtcs(key);

          if (dtcs.message == "success" && dtcs.results.isNotEmpty) {
            // Save first result to local storage
            final dtcJson = jsonEncode(dtcs.results[0].toJson());
            await SaveLocalData.saveData(
                "DtcDataset_${dtcs.results[0].id}", dtcJson);
            returnValue = true;
          } else {
            // Show error dialog
            await Get.defaultDialog(
              title: "Error in Saving DTC Data",
              middleText: dtcs.message,
            );
            return false;
          }
        }
      }
      return returnValue;
    } catch (e) {
      // Show exception
      await Get.defaultDialog(
        title: "Exception in Saving DTC Data",
        middleText: e.toString(),
      );
      return false;
    }
  }

  Future<bool> updateFlashRecordToLocal(List<ModelResult> models) async {
    try {
      List<Ecu2> ecu2List = [];

      // Flatten all Ecu2 from models
      for (var model in models) {
        if (model.subModels != null && model.subModels!.isNotEmpty) {
          for (var subModel in model.subModels!) {
            if (subModel.ecus != null && subModel.ecus!.isNotEmpty) {
              for (var ecu in subModel.ecus!) {
                if (ecu.ecu != null && ecu.ecu!.isNotEmpty) {
                  ecu2List.add(ecu.ecu!.first);
                }
              }
            }
          }
        }
      }

      if (ecu2List.isNotEmpty) {
        // Group by ID
        final grouped = <int, List<Ecu2>>{};
        for (var ecu2 in ecu2List) {
          grouped.putIfAbsent(ecu2.id, () => []).add(ecu2);
        }

        for (var entry in grouped.entries) {
          final ecu = entry.value.first;

          // Download and save sequence file
          final sequenceFileContent =
              await AuthApiService.downloadFileContent(ecu.sequenceFile);
          await SaveLocalData.saveData(
              'flashRecord_sequence_file_${ecu.id}', sequenceFileContent);

          // Download and save each file in ecu.file
          if (ecu.file != null && ecu.file!.isNotEmpty) {
            for (var file in ecu.file!) {
              final fileContent =
                  await AuthApiService.downloadFileContent(file.dataFile);
              await SaveLocalData.saveData(
                  'file_data_file_${file.id}', fileContent);
            }
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
      // Get existing local data (if any)
      String? localData = await SaveLocalData.getData("IOR_LocalList");

      if (localData == null || localData.isEmpty) {
        // Fetch IOR test data from API
        final res = await AuthApiService.getIorTest();

        if (res.message == "success") {
          final iorLocalList = jsonEncode(res.toJson());
          await SaveLocalData.saveData("IOR_LocalList", iorLocalList);
          return true;
        } else {
          await Get.defaultDialog(
            title: "Error in Saving IOR Data",
            middleText: res.message,
          );
          return false;
        }
      } else {
        // Local data already exists
        return true;
      }
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
      // Check if local data exists
      String? localData = await SaveLocalData.getData("Actuator_LocalList");

      if (localData == null || localData.isEmpty) {
        // Fetch actuator test data from API
        final res = await AuthApiService.getActuatorTest();

        if (res.message == "success") {
          final actuatorLocalList = jsonEncode(res.toJson());
          await SaveLocalData.saveData("Actuator_LocalList", actuatorLocalList);
          return true;
        } else {
          await Get.defaultDialog(
            title: "Error in Saving Actuator Data",
            middleText: res.message,
          );
          return false;
        }
      } else {
        // Local data already exists
        return true;
      }
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

      for (var model in modelList) {
        if (model.subModels != null) {
          for (var submodel in model.subModels!) {
            // Check if local GD data exists
            String? localData =
                await SaveLocalData.getData("GD_LocalList_${submodel.id}");

            if (localData == null || localData.isEmpty) {
              // Fetch GD data from API
              final res = await AuthApiService.getGD(submodel.id);

              if (res.message == "success") {
                final gdLocalList = jsonEncode(res.toJson());
                await SaveLocalData.saveData(
                    "GD_LocalList_${submodel.id}", gdLocalList);
                returnValue = true;
              } else {
                await Get.defaultDialog(
                  title: "Error in Saving GD Data",
                  middleText: res.message,
                );
                return false;
              }
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
      // Check if local data exists
      String? localData = await SaveLocalData.getData("FreezeFrame_LocalList");

      if (localData == null || localData.isEmpty) {
        bool returnValue = false;

        // Fetch freeze frame data from API
        final res = await AuthApiService.getFreezeFrameList();

        if (res.message == "success") {
          final freezeFrameLocalList = jsonEncode(res.toJson());
          await SaveLocalData.saveData(
              "FreezeFrame_LocalList", freezeFrameLocalList);
          returnValue = true;
        } else {
          await Get.defaultDialog(
            title: "Error in Saving Freeze Frame Data",
            middleText: res.message,
          );
          returnValue = false;
        }
        return returnValue;
      } else {
        return true;
      }
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
      // Check if local data exists
      String? localData = await SaveLocalData.getData("DoipConfig_LocalList");

      if (localData == null || localData.isEmpty) {
        bool returnValue = false;

        // Fetch DoIP configuration from API
        final res = await AuthApiService.getDoipConfiguration();

        if (res.message == "success") {
          final doipConfigLocalList = jsonEncode(res.toJson());
          await SaveLocalData.saveData(
              "DoipConfig_LocalList", doipConfigLocalList);
          returnValue = true;
        } else {
          await Get.defaultDialog(
            title: "Error in Doip Config Data",
            middleText: res.message,
          );
          returnValue = false;
        }

        return returnValue;
      } else {
        // Local data already exists
        return true;
      }
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
      // Check if local data exists
      String? localData = await SaveLocalData.getData("ListNumber_LocalList");

      if (localData == null || localData.isEmpty) {
        bool returnValue = false;

        // Fetch List Numbers from API
        final res = await AuthApiService.getListNumbers();

        if (res.message == "success") {
          final listNumberLocalList = jsonEncode(res.toJson());
          await SaveLocalData.saveData(
              "ListNumber_LocalList", listNumberLocalList);
          returnValue = true;
        } else {
          await Get.defaultDialog(
            title: "Error in List Number Data",
            middleText: res.message,
          );
          returnValue = false;
        }

        return returnValue;
      } else {
        // Local data already exists
        return true;
      }
    } catch (e) {
      await Get.defaultDialog(
        title: "Exception in Saving List Number Data",
        middleText: e.toString(),
      );
      return false;
    }
  }

  Future<bool> loginOffline() async {
    try {
      bool returnValue = true;

      // Fetch local data
      String? modelLocalList = await SaveLocalData.getData("MODEL_LocalList");
      String? iorLocalList = await SaveLocalData.getData("IOR_LocalList");
      String? actuatorLocalList =
          await SaveLocalData.getData("Actuator_LocalList");
      String? freezeFrameLocalList =
          await SaveLocalData.getData("FreezeFrame_LocalList");

      // Check if any local data is missing
      if (modelLocalList == null ||
          modelLocalList.isEmpty ||
          iorLocalList == null ||
          iorLocalList.isEmpty ||
          actuatorLocalList == null ||
          actuatorLocalList.isEmpty ||
          freezeFrameLocalList == null ||
          freezeFrameLocalList.isEmpty) {
        await Get.defaultDialog(
            title: "Failed",
            middleText:
                "Local data not completely updated.\nTry to login with internet.");
        await SaveLocalData.saveData("MODEL_LocalList", "");
        returnValue = false;
      } else {
        String? responseData =
            await SaveLocalData.getData("UserDetail_LocalData");
        String? requestData =
            await SaveLocalData.getData("UserRequest_LocalData");

        if (responseData == null ||
            responseData.isEmpty ||
            requestData == null ||
            requestData.isEmpty) {
          await Get.defaultDialog(
              title: "Failed", middleText: "Try to login with internet.");
          returnValue = false;
        } else {
          UserResModel userResModel =
              UserResModel.fromJson(jsonDecode(responseData));
          UserModel userRequestModel =
              UserModel.fromJson(jsonDecode(requestData));

          if (userResModel.message == "success") {
            // Set global token and OEM ID
            AppPreferences.setInt("oemId", userResModel.profile?.oem?.id ?? 0);
            AppEnvironment.jwtToken = userResModel.token?.access ?? '';
            returnValue = true;
          }
        }
      }

      return returnValue;
    } catch (e) {
      await Get.defaultDialog(title: "Error", middleText: e.toString());
      return false;
    }
  }
}
