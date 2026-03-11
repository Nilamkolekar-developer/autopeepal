import 'dart:convert';
import 'dart:io';
import 'package:autopeepal/AppPreferences/app_areferences.dart';
import 'package:autopeepal/app.dart';
import 'package:autopeepal/common_widgets/commonLoader.dart';
import 'package:autopeepal/common_widgets/popup.dart';
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
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  final GetDeviceUniqueId getDeviceUniqueId = GetDeviceUniqueId();
  @override
  void onInit() {
    super.onInit();
    loadSavedUserCredentials();
    saveLocalData = SaveLocalData();
  }

  Future<void> loadSavedUserCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Check if user credentials exist
      String savedUser = prefs.getString("user_id") ?? "";
      String savedPass = prefs.getString("password") ?? "";

      if (savedUser.isNotEmpty && savedPass.isNotEmpty) {
        // 2. Update the text controllers
        usernameController.value.text = savedUser;
        passwordController.value.text = savedPass;

        // 3. Set the checkbox to true since we have saved data
        isRememberMeChecked.value = true;
        print("[LOGIN] Credentials loaded for: $savedUser");
      }
    } catch (e) {
      print("[LOGIN] Error loading saved credentials: $e");
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
  RxBool isRememberMeChecked = false.obs;
  UserResModel? userResModel;
  UserModel? userRequestModel;
  SaveLocalData? saveLocalData;

  Future<void> loginMethod() async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));

      print("[LOGIN] Starting validation...");

      // ================= VALIDATION =================
      final username = usernameController.value.text.trim();
      final password = passwordController.value.text.trim();

      if (username.isEmpty && password.isEmpty) {
        print("[LOGIN] Both username and password empty");

        await Get.dialog(
          CustomPopup(
            title: "Alert",
            message: "Enter user name and password.",
            onButtonPressed: () {
              Get.back();
            },
          ),
          barrierDismissible: false,
        );
        return;
      } else if (username.isEmpty) {
        print("[LOGIN] Username empty");
        await Get.dialog(
          CustomPopup(
            title: "Alert",
            message: "Enter user name",
            onButtonPressed: () {
              Get.back();
            },
          ),
          barrierDismissible: false,
        );

        return;
      } else if (password.isEmpty) {
        print("[LOGIN] Password empty");
        await Get.dialog(
          CustomPopup(
            title: "Alert",
            message: "Enter user password.",
            onButtonPressed: () {
              Get.back();
            },
          ),
          barrierDismissible: false,
        );

        return;
      }

      // ================= LOADER =================
      isLoading.value = true;
      print("[LOGIN] Showing loader...");
      final loader = CommonLoader(message: "Signing In...");
      Get.dialog(loader, barrierDismissible: false);

      // ================= DEVICE INFO =================
      final deviceId = await getDeviceUniqueId.getId();
      String platform = "";
      if (Platform.isAndroid) {
        platform = "android";
      } else if (Platform.isIOS) {
        platform = "ios";
      } else if (Platform.isWindows) {
        platform = "windows";
      }
      print("[LOGIN] Device info - ID: $deviceId, Platform: $platform");

      final userRequestModel = UserModel(
        username: username,
        password: password,
        deviceType: platform,
        macId: deviceId,
      );

      // ================= NETWORK CHECK =================
      final connectivityResult = await Connectivity().checkConnectivity();
      final isReachable = connectivityResult != ConnectivityResult.none;

      bool isLoggedIn = false;

// Update this section in loginMethod()
      if (isReachable) {
        try {
          print("[LOGIN] Attempting online login...");
          // 🔹 Call internal loginOnline which handles API AND data saving
          isLoggedIn = await loginOnline(userRequestModel);
        } catch (e) {
          print("[LOGIN] Online login failed ($e). Switching to offline...");
          // 🔹 Fallback if the internet is "on" but the server is unreachable
          isLoggedIn = await loginOffline(userRequestModel);
        }
      } else {
        print("[LOGIN] No internet. Trying offline login...");
        isLoggedIn = await loginOffline(userRequestModel);
      }

      // ================= POST LOGIN =================
      print("[LOGIN] Is logged in: $isLoggedIn, userResModel: $userResModel");
      if (isLoggedIn && userResModel != null) {
        final prefs = await SharedPreferences.getInstance();

        print("[LOGIN] Saving remember me preferences...");
        if (isRememberMeChecked.value) {
          await prefs.setString("user_id", username);
          await prefs.setString("password", password);

          if (saveLocalData != null) {
            await saveLocalData!.saveData(
              "RememberIsChecked",
              jsonEncode({
                "username": username,
                "password": password,
                "device_type": platform,
                "mac_id": deviceId,
                "RememberIsChecked": true,
              }),
            );
          } else {
            print("[LOGIN] Warning: saveLocalData is null!");
          }
        } else {
          await prefs.setString("user_id", "");
          await prefs.setString("password", "");

          if (saveLocalData != null) {
            await saveLocalData!.saveData(
              "RememberIsChecked",
              jsonEncode({"RememberIsChecked": false}),
            );
          } else {
            print("[LOGIN] Warning: saveLocalData is null!");
          }
        }

        print("[LOGIN] Saving session info...");
        await prefs.setString("macId", deviceId);
        await prefs.setString("UserName", username);
        await prefs.setString(
          "MasterLoginUserBY",
          "${userResModel!.firstName ?? ""} ${userResModel!.lastName ?? ""}",
        );
        await prefs.setString("rolewhilelogin", userResModel!.role ?? "");
        await prefs.setInt("oemId", userResModel!.profile?.oem?.id ?? 0);

        print("[LOGIN] Saving global app data...");
        await AppPreferences.saveLicences(
            userResModel!.licences?.toJson() ?? {});
        await AppPreferences.saveVehicleModels(
          userResModel!.profile?.workshopGroupModels
                  ?.map((e) => e.toJson())
                  .toList() ??
              [],
        );

        print("[LOGIN] Navigating to dashboard...");
        Get.offAllNamed(Routes.dashboardScreen, arguments: (userResModel!));
      }
    } catch (e, s) {
      print("[LOGIN] Error: $e\nStackTrace: $s");
      await Get.dialog(
        CustomPopup(
          title: "Login Error",
          message: e.toString(),
          onButtonPressed: () {
            Get.back();
          },
        ),
        barrierDismissible: false,
      );
    } finally {
      print("[LOGIN] Hiding loader...");
      isLoading.value = false;
      if (Get.isDialogOpen ?? false) Get.back();
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
        await saveLocalData!.saveData(
          "UserDetail_LocalData",
          jsonEncode(userResModel!.toJson()),
        );
        await saveLocalData!.saveData(
          "UserRequest_LocalData",
          jsonEncode(userRequestModel.toJson()),
        );

        // Local model data check (optional)
        String? modelLocalList =
            await saveLocalData!.getData("MODEL_LocalList");
        String? iorLocalList = await saveLocalData!.getData("IOR_LocalList");
        String? actuatorLocalList =
            await saveLocalData!.getData("Actuator_LocalList");
        String? freezeFrameLocalList =
            await saveLocalData!.getData("FreezeFrame_LocalList");

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
        await Get.dialog(
          CustomPopup(
            title: "Error",
            message: userResModel?.message ?? "Login failed",
            onButtonPressed: () {
              Get.back();
            },
          ),
          barrierDismissible: false,
        );

        returnValue = false;
      }

      print("[LOGIN] loginOnline ended with returnValue: $returnValue");
      return returnValue;
    } catch (e) {
      print("[LOGIN] Exception during loginOnline: $e");
      Get.dialog(
        CustomPopup(
          title: "Alert",
          message: " $e",
          onButtonPressed: () => Get.back(),
        ),
        barrierDismissible: false,
      );

      return false;
    } finally {
      isLoading.value = false;
      if (Get.isDialogOpen ?? false) Get.back();
      print("🔹 usbConnect finished");
    }
  }

  Future<bool> loginOnline1(UserModel userRequestModel) async {
    try {
      bool returnValue = false;

      // Initialize response
      userResModel = UserResModel();

      // Call your API service
      userResModel = await AuthApiService.login(userRequestModel);

      if (userResModel?.message == "success") {
        // Save global app data
        App.oemId = userResModel?.profile?.oem?.id ?? 0;
        App.jwtToken = userResModel?.token?.access ?? '';

        // Save user and request to local storage
        await saveLocalData!.saveData(
          "UserDetailL_LocalData",
          jsonEncode(userResModel?.toJson()),
        );
        await saveLocalData!.saveData(
          "UserRequest_LocalData",
          jsonEncode(userRequestModel.toJson()),
        );

        // Read previous OEM
        final prefs = await SharedPreferences.getInstance();
        int previousOem = prefs.getInt("oemId") ?? 0;

        // Get local cached model data
        final modelLocalList = await saveLocalData!.getData("MODEL_LocalList");
        final iorLocalList = await saveLocalData!.getData("IOR_LocalList");
        final actuatorLocalList =
            await saveLocalData!.getData("Actuator_LocalList");
        final freezeFrameLocalList =
            await saveLocalData!.getData("FreezeFrame_LocalList");

        // Check if local data needs updating
        if (modelLocalList.trim().isEmpty ||
            iorLocalList.trim().isEmpty ||
            actuatorLocalList.trim().isEmpty ||
            freezeFrameLocalList.trim().isEmpty ||
            previousOem != (userResModel?.profile?.oem?.id ?? 0)) {
          // Show loader text
          // You can bind this to a controller variable
          debugPrint("Updating Local Data...");
          returnValue = await updateModelToLocal();
        } else {
          // If local data is valid, fallback to offline login
          returnValue = await loginOffline(userRequestModel);
        }
      } else {
        // Show error dialog
        Get.dialog(
          CustomPopup(
            title: "Error",
            message: userResModel?.message ?? "Login failed",
            onButtonPressed: () => Get.back(),
          ),
          barrierDismissible: false,
        );

        returnValue = false;
      }

      return returnValue;
    } catch (e) {
      Get.dialog(
        CustomPopup(
          title: "Error",
          message: e.toString(),
          onButtonPressed: () => Get.back(),
        ),
        barrierDismissible: false,
      );

      return false;
    } finally {
      if (Get.isDialogOpen ?? false) Get.back();
      print("🔹 usbConnect finished");
    }
  }

  Future<bool> updateModelToLocal() async {
    bool returnValue = false;

    try {
      // ================= GET LOCAL DATA =================
      String? localData = await saveLocalData!.getData("MODEL_LocalList");

      late AllModelsModel result;

      if (localData.isEmpty) {
        // ================= FETCH FROM API =================
        result = await AuthApiService.getAllModels();

        if (result.message == "success") {
          String modelLocalList = jsonEncode(result.toJson());
          await saveLocalData!.saveData("MODEL_LocalList", modelLocalList);
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

            await saveLocalData!.saveData(
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

            await saveLocalData!.saveData(
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

        await saveLocalData!.saveData(
          "flashRecord_sequence_file_${ecu.id}",
          sequenceContent,
        );

        // Save ECU data files
        final files = ecu.file;
        if (files != null && files.isNotEmpty) {
          for (final file in files) {
            final String fileContent =
                await services.downloadFileContent(file.dataFile ?? '');

            await saveLocalData!.saveData(
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
      final String localData = await saveLocalData!.getData("IOR_LocalList");

      // 🔹 If not available locally, fetch from API
      if (localData.trim().isEmpty) {
        final AuthApiService services = AuthApiService();
        final IorTestModel res = await services.getIorTest();

        if (res.message == "success") {
          final String iorLocalJson = jsonEncode(res.toJson());
          await saveLocalData!.saveData("IOR_LocalList", iorLocalJson);
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
          await saveLocalData!.getData("Actuator_LocalList");

      // 🔹 If not cached locally, fetch from API
      if (localData.trim().isEmpty) {
        final AuthApiService services = AuthApiService();
        final ActuatorTestModel res = await services.getActuatorTest();

        if (res.message == "success") {
          final String actuatorLocalJson = jsonEncode(res.toJson());
          await saveLocalData!.saveData(
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

  // Future<bool> updateGDToLocal(List<ModelResult> modelList) async {
  //   try {
  //     bool returnValue = true;

  //     if (modelList.isEmpty) return true;

  //     final AuthApiService services = AuthApiService();

  //     for (final model in modelList) {
  //       final subModels = model.subModels;
  //       if (subModels == null || subModels.isEmpty) continue;

  //       for (final subModel in subModels) {
  //         // 🔹 Read local cache
  //         final String localData =
  //             await saveLocalData!.getData("GD_LocalList_${subModel.id}");

  //         // 🔹 If not cached, fetch from API
  //         if (localData.trim().isEmpty) {
  //           final GdModelGD res = await services.getGD(subModel.id!);

  //           if (res.message == "success") {
  //             final String gdLocalJson = jsonEncode(res.toJson());

  //             await saveLocalData!.saveData(
  //               "GD_LocalList_${subModel.id}",
  //               gdLocalJson,
  //             );

  //             returnValue = true;
  //           } else {
  //             await Get.defaultDialog(
  //               title: "Error in Saving GD Data",
  //               middleText: res.message ?? "Unknown error",
  //             );
  //             return false; // ❌ fail fast
  //           }
  //         }
  //       }
  //     }

  //     return returnValue;
  //   } catch (e) {
  //     await Get.defaultDialog(
  //       title: "Exception in Saving GD Data",
  //       middleText: e.toString(),
  //     );
  //     return false;
  //   }
  // }

  Future<bool> updateGDToLocal(List<ModelResult> modelList) async {
  try {
    print("🔹 updateGDToLocal started");
    print("🔹 Total Models: ${modelList.length}");

    bool returnValue = true;

    if (modelList.isEmpty) {
      print("⚠️ modelList is empty");
      return true;
    }

    final AuthApiService services = AuthApiService();

    for (final model in modelList) {
      print("🔹 Processing Model: ${model.id}");

      final subModels = model.subModels;

      if (subModels == null || subModels.isEmpty) {
        print("⚠️ No subModels for model: ${model.id}");
        continue;
      }

      print("🔹 Total SubModels: ${subModels.length}");

      for (final subModel in subModels) {
        print("--------------------------------------------------");
        print("🔹 Processing SubModel ID: ${subModel.id}");

        String key = "GD_LocalList_${subModel.id}";
        print("🔹 Checking local cache key: $key");

        /// 🔹 Read local cache
        final String localData =
            await saveLocalData!.getData(key);

        print("🔹 Local data length: ${localData.length}");

        /// 🔹 If not cached, fetch from API
        if (localData.trim().isEmpty) {
          print("⚠️ No local GD found. Calling API for SubModel: ${subModel.id}");

          final GdModelGD res = await services.getGD(subModel.id!);

          print("🔹 API Response Message: ${res.message}");

          if (res.message == "success") {
            print("✅ GD API Success for SubModel: ${subModel.id}");
            print("🔹 Total GD Results: ${res.results?.length}");

            final String gdLocalJson = jsonEncode(res.toJson());

            print("🔹 Saving GD data locally with key: $key");

            await saveLocalData!.saveData(
              key,
              gdLocalJson,
            );

            print("✅ GD saved successfully for key: $key");

            returnValue = true;
          } else {
            print("❌ API returned error: ${res.message}");

            await Get.defaultDialog(
              title: "Error in Saving GD Data",
              middleText: res.message ?? "Unknown error",
            );

            return false;
          }
        } else {
          print("✅ GD already exists locally for key: $key");
        }
      }
    }

    print("✅ updateGDToLocal completed");
    return returnValue;
  } catch (e, stack) {
    print("❌ Exception in updateGDToLocal: $e");
    print("📍 StackTrace: $stack");

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
          await saveLocalData!.getData("FreezeFrame_LocalList");

      // 🔹 If not cached, fetch from API
      if (localData.trim().isEmpty) {
        final AuthApiService services = AuthApiService();
        final FreezeFrameModel res = await services.getFreezeFrameList();

        if (res.message == "success") {
          final String freezeFrameLocalJson = jsonEncode(res.toJson());

          await saveLocalData!.saveData(
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
          await saveLocalData!.getData("DoipConfig_LocalList");

      // 🔹 If not cached, fetch from API
      if (localData.trim().isEmpty) {
        final AuthApiService services = AuthApiService();
        final DoipConfigRootModel res = await services.getDoipConfiguration();

        if (res.message == "success") {
          final String doipConfigLocalJson = jsonEncode(res.toJson());

          await saveLocalData!.saveData(
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
          await saveLocalData!.getData("ListNumber_LocalList");

      // 🔹 If not cached, fetch from API
      if (localData.trim().isEmpty) {
        final AuthApiService services = AuthApiService();
        final ListNumberRootModel res = await services.getListNumbers();

        if (res.message == "success") {
          final String listNumberLocalJson = jsonEncode(res.toJson());

          await saveLocalData!.saveData(
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
      // 🔹 Get local cached model data safely
      final modelLocalList =
          (await saveLocalData!.getData("MODEL_LocalList")) ?? "";
      final iorLocalList =
          (await saveLocalData!.getData("IOR_LocalList")) ?? "";
      final actuatorLocalList =
          (await saveLocalData!.getData("Actuator_LocalList")) ?? "";
      final freezeFrameLocalList =
          (await saveLocalData!.getData("FreezeFrame_LocalList")) ?? "";

      // 🔹 Check if mandatory local data exists
      if (modelLocalList.isEmpty ||
          iorLocalList.isEmpty ||
          actuatorLocalList.isEmpty ||
          freezeFrameLocalList.isEmpty) {
        Get.dialog(
          CustomPopup(
            title: "Failed",
            message:
                "Local data not completely updated.\nTry to login with internet",
            onButtonPressed: () => Get.back(),
          ),
          barrierDismissible: false,
        );

        // Clear incomplete cache
        await saveLocalData!.saveData("MODEL_LocalList", "");
        return false;
      }

      // 🔹 Get cached user login request (username & password)
      final requestData =
          (await saveLocalData!.getData("UserRequest_LocalData")) ?? "";
      if (requestData.isEmpty) {
        await Get.defaultDialog(
          title: "Failed",
          middleText: "Try to login with internet.",
        );
        return false;
      }

      final cachedRequest = UserModel.fromJson(jsonDecode(requestData));

      // 🔹 Validate username & password
      if (cachedRequest.username == userRequestModel.username &&
          cachedRequest.password == userRequestModel.password) {
        // ✅ Successful offline login, token may be null
        final responseData =
            (await saveLocalData!.getData("UserDetailL_LocalData")) ?? "";
        if (responseData.isNotEmpty) {
          userResModel = UserResModel.fromJson(jsonDecode(responseData));
          // Token is optional offline
          if (userResModel?.token?.access != null) {
            App.jwtToken = userResModel!.token!.access!;
          }
          App.oemId = userResModel!.profile?.oem?.id ?? 0;
        }

        print('[OFFLINE LOGIN] Success for ${userRequestModel.username}');
        return true;
      } else {
        await Get.defaultDialog(
          title: "Failed",
          middleText: "Username or password does not match cached data.",
        );
        return false;
      }
    } catch (e) {
      await Get.defaultDialog(
        title: "Error",
        middleText: e.toString(),
      );
      return false;
    }
  }
}
