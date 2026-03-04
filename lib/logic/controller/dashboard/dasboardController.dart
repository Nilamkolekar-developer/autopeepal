import 'dart:async';
import 'dart:convert';
import 'package:autopeepal/AppPreferences/app_areferences.dart';
import 'package:autopeepal/common_widgets/commonLoader.dart';
import 'package:autopeepal/common_widgets/popup.dart';
import 'package:autopeepal/models/all_models.dart';
import 'package:autopeepal/models/staticData.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:autopeepal/services/api_services.dart';
import 'package:autopeepal/services/connectionWifiService.dart';
import 'package:autopeepal/services/hotspot_service.dart';
import 'package:autopeepal/services/local_storage_services/localStorage_service.dart';
import 'package:autopeepal/utils/ui_helper.dart/enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DashboardController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<VCIType> vciList = <VCIType>[].obs;
  RxString selectedRegulation = "".obs;
  RxString selectedModel = "".obs;
  RxString selectedVciType = "".obs;
  RxList<ModelResult> modelList = <ModelResult>[].obs;
  LocalStorage localStorage = LocalStorage();
  RxString appName = ''.obs;
  RxString version = ''.obs;
  RxString buildNumber = ''.obs;
  RxString selectedSubModelName = ''.obs;
  RxString selectedSubModelYear = ''.obs;
  RxList<SubModel> filteredSubModels = <SubModel>[].obs;
  Rx<DiscoveredService?> lastFoundDevice = Rx<DiscoveredService?>(null);
  final MdnsDiscoveryService mdnsDiscoveryService = MdnsDiscoveryService();
  RxList<DiscoveredService> discoveredServices = <DiscoveredService>[].obs;
  Rx<SubModel?> selectedSubModel = Rx<SubModel?>(null);
  StreamSubscription<DiscoveredService>? _discoverySub;
  bool get isAllSelected =>
      selectedModel.value.isNotEmpty &&
      selectedRegulation.value.isNotEmpty &&
      selectedVciType.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    initModelList();
    loadAppInfo();
    vciList.value = VCIType.values.where((e) => e != VCIType.NONE).toList();
    AppPreferences.getSelectedVCI().then((value) {
      if (value != null && value.isNotEmpty) {
        selectedVciType.value = value;
      }
    });
    _discoverySub =
        mdnsDiscoveryService.discoveredServices.listen(_onServiceFound);
    mdnsDiscoveryService.startDiscovery();
  }

  void selectVCI(VCIType vci) {
    selectedVciType.value = vci.name;
    AppPreferences.setSelectedVCI(vci.name);
  }

  Future<void> loadAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    appName.value = info.appName;
    version.value = info.version;
    buildNumber.value = info.buildNumber;
  }

  void _onServiceFound(DiscoveredService service) {
    print("🔍 Device Found: ${service.name}");
    final index = discoveredServices.indexWhere((s) => s.name == service.name);
    if (index == -1) {
      discoveredServices.add(service);
    } else {
      discoveredServices[index] = service;
    }
    lastFoundDevice.value = service;
    discoveredServices.refresh();
  }

  void refreshDiscovery() {
    print("🔄 Refresh Discovery");
    discoveredServices.clear();
    mdnsDiscoveryService.startDiscovery();
  }

  @override
  void onClose() {
    print("🛑 Stopping mDNS Discovery");
    _discoverySub?.cancel();
    mdnsDiscoveryService.stopDiscovery();
    super.onClose();
  }

  Future<void> initModelList() async {
    try {
      String? localData = await localStorage.getData('MODEL_LocalList');

      if (localData == null || localData.isEmpty) {
        print("No local data found. Fetching from API...");
        AllModelsModel apiData = await AuthApiService.getAllModels();
        if (apiData.message == "success" && apiData.results != null) {
          await localStorage.saveData(
              'MODEL_LocalList', jsonEncode(apiData.toJson()));
          localData = jsonEncode(apiData.toJson());
        } else {
          print("❌ API failed: ${apiData.message}");
          return;
        }
      } else {
        print("🔹 Loaded models from local storage.");
      }

      AllModelsModel allModels = AllModelsModel.fromJson(jsonDecode(localData));
      modelList.value = allModels.results ?? [];
    } catch (e) {
      print("❌ Error loading model list: $e");
    }
  }

  void selectModel(String modelName) {
    selectedModel.value = modelName;

    final model = modelList.firstWhere(
      (m) => m.name?.toLowerCase() == modelName.toLowerCase(),
      orElse: () => ModelResult(name: '', subModels: []),
    );

    filteredSubModels.value = model.subModels ?? [];
    selectedRegulation.value = '';
    selectedSubModelName.value = '';
    selectedSubModelYear.value = '';
  }

  void selectSubModel(SubModel subModel) {
    selectedSubModel.value = subModel; // store object
    selectedSubModelName.value = subModel.name ?? '';
    selectedSubModelYear.value = subModel.modelYear ?? '';
    selectedRegulation.value = ''; // if regulation is reset
    // Save SubModel ID in preferences
    if (subModel.id != null) {
      AppPreferences.setInt('selectedSubModelId', subModel.id!);
    }
    loadEcuData().then((_) {
      print(
          "✅ ECU Data loaded: ${StaticData.ecuInfo.map((e) => e.ecuName).toList()}");
    });
  }

  Future<void> loadEcuData() async {
    try {
      final subModel = selectedSubModel.value;
      if (subModel == null) return;

      // Save SubModel ID in preferences
      if (subModel.id != null) {
        await AppPreferences.setInt('selectedSubModelId', subModel.id!);
      }

      // Clear previous ECU info
      StaticData.ecuInfo = <EcuDataSet>[];

      if (subModel.ecus == null || subModel.ecus!.isEmpty) {
        print("⚠️ No ECUs found for this submodel.");
        return;
      }

      // Add all ECUs
      for (var ecu in subModel.ecus!) {
        StaticData.ecuInfo.add(EcuDataSet(
          readDtcIndex: ecu.readDtcFnIndex?.value,
          pidDatasetId: ecu.pidDatasets?.firstOrNull?.id,
          clearDtcIndex: ecu.clearDtcFnIndex?.value,
          dtcDatasetId: ecu.datasets?.firstOrNull?.id,
          ecuName: ecu.name ?? 'Unknown ECU',
          seedKeyIndex: ecu.seedkeyalgoFnIndex?.value,
          writePidIndex: ecu.writeDataFnIndex?.value,
          txHeader: ecu.txHeader,
          rxHeader: ecu.rxHeader,
          protocol: ecu.protocol,
          ecuID: ecu.id ?? 0,
          iorTestFnIndex: ecu.iorTestFnIndex?.value,
          channelId: ecu.channel,
          modelName: selectedModel.value,
          submodelName: subModel.name ?? 'Unknown Submodel',
          modelYear: subModel.modelYear,
          ecu2: ecu.ecu?.firstOrNull,
          ffSet: ecu.ffSet,
          firingSequence: ecu.firingSequence,
          noOfInjectors: ecu.noOfInjectors,
        ));
      }

      // Sort: move "EMS" to top
      if (StaticData.ecuInfo.length > 1) {
        StaticData.ecuInfo.sort((a, b) {
          if ((a.ecuName.toUpperCase()) == 'EMS') return -1;
          if ((b.ecuName.toUpperCase()) == 'EMS') return 1;
          return 0;
        });
      }

      print('✅ Loaded ${StaticData.ecuInfo.length} ECUs for ${subModel.name}');
      for (var ecu in StaticData.ecuInfo) {
        print(' - ${ecu.ecuName}');
      }
    } catch (e) {
      print('❌ Error loading ECU data: $e');
    }
  }

  Future<void> wifiConnect(BuildContext context) async {
    try {
      // 🔴 Validation: Model & SubModel
      if (selectedModel.value.isEmpty || selectedSubModel.value == null) {
        showDialog(
          context: context,
          builder: (context) => CustomPopup(
            title: "Alert",
            message: "Please Select model and submodel",
            onButtonPressed: () => Get.back(),
          ),
        );

        return;
      }

      // 🔴 Validation: VCI
      if (selectedVciType.value.isEmpty ||
          selectedVciType.value == "Select VCI") {
        showDialog(
          context: context,
          builder: (context) => CustomPopup(
            title: "Alert",
            message: "Please Select VCI Type",
            onButtonPressed: () => Get.back(),
          ),
        );
      }

      // 🟡 Loading
      isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 50));

      // 🔌 Save connection type
      await AppPreferences.setConnectedVia("WIFI");
      Get.dialog(
        const CommonLoader(message: "Scanning..."),
        barrierDismissible: false,
      );

      final connectionWifi = ConnectionWifi();
      final wifiDeviceList = await connectionWifi.getDeviceList();

      if (wifiDeviceList != null && wifiDeviceList.isNotEmpty) {
        if (context.mounted) {
          Get.toNamed(Routes.wifiScreen);
        }
      } else {
        showDialog(
          context: context,
          builder: (context) => CustomPopup(
            title: "Failed",
            message: "Dongle not found",
            onButtonPressed: () => Get.back(),
          ),
        );
      }
    } catch (e, stack) {
      debugPrint("❌ WifiConnect error: $e");
      debugPrintStack(stackTrace: stack);
    } finally {
      isLoading.value = false;
    }
  }

//   Future<void> usbConnect(BuildContext context) async {
//   try {
//     // 🔴 Validation: Model & SubModel
//     if (selectedModel.value.isEmpty || selectedSubModel.value == null) {
//       showDialog(
//           context: context,
//           builder: (context) => CustomPopup(
//             title: "Alert",
//             message: "Please Select model and submodel",
//             onButtonPressed: () => Get.back(),
//           ),
//         );

//       return;
//     }

//     // 🔴 Validation: VCI
//     if (selectedVciType.value.isEmpty ||
//         selectedVciType.value == "Select VCI") {
//      showDialog(
//           context: context,
//           builder: (context) => CustomPopup(
//             title: "Alert",
//             message: "Please Select VCI Type",
//             onButtonPressed: () => Get.back(),
//           ),
//         );
//       return;
//     }

//     // 🔄 Loader
//     isLoading.value = true;
//     await Future.delayed(const Duration(milliseconds: 50));

//     String firmwareVersion = '';
//     String channelId = '';

//     // ===============================
//     // CHANNEL ID PARSING
//     // ===============================
//     final ecuInfo = StaticData.ecuInfo;
//     if (ecuInfo.isEmpty || ecuInfo.first.channelId == null) {
//       showDialog(
//           context: context,
//           builder: (context) => CustomPopup(
//             title: "Alert",
//             message: "Invalid Channel Id Format",
//             onButtonPressed: () => Get.back(),
//           ),
//       );
//       return;
//     }

//     final channelSplit = ecuInfo.first.channelId!.split('-');
//     if (channelSplit.length > 1) {
//       channelId = '0${channelSplit[1]}';
//     } else {
//        showDialog(
//           context: context,
//           builder: (context) => CustomPopup(
//             title: "Alert",
//             message: "Invalid Channel Id Format",
//             onButtonPressed: () => Get.back(),
//           ),
//       );

//       return;
//     }

//     // ===============================
//     // VCI TYPE PARSE
//     // ===============================
//     final VCIType vciType = VCIType.values.firstWhere(
//       (e) => e.name == selectedVciType.value,
//       orElse: () => throw Exception("Invalid VCI Type"),
//     );

//     // ===============================
//     // DOIP CONFIG (ONLY FOR DOIP)
//     // ===============================
//     DoipConfigModel? doipConfigModel;

//     if (vciType == VCIType.DOIP) {
//       final doipConfigLocal =
//           await AppPreferences.getStringValue("DoipConfig_LocalList");

//       if (doipConfigLocal == null || doipConfigLocal.isEmpty) {
//          showDialog(
//           context: context,
//           builder: (context) => CustomPopup(
//             title: "Alert",
//             message:"DOIP Configuration data not available.\nPlease sync local data.",
//             onButtonPressed: () => Get.back(),
//           ),
//       );

//         return;
//       }

//       final doipRoot =
//           DoipConfigRootModel.fromJson(jsonDecode(doipConfigLocal));

//       doipConfigModel = doipRoot.results?.firstWhere(
//         (x) => x.ecu == ecuInfo.first.ecuID,
//         orElse: () => null,
//       );

//       if (doipConfigModel == null) {
//          showDialog(
//           context: context,
//           builder: (context) => CustomPopup(
//             title: "Alert",
//             message:"DOIP Configuration data not available",
//             onButtonPressed: () => Get.back(),
//           ),
//       );

//         return;
//       }
//     }

//     // ===============================
//     // USB CONNECTION
//     // ===============================
//     final connectionUSB = ConnectionUSB();
//     final bool isConnected = await connectionUSB.connectUsb(vciType);

//     if (!isConnected) {
//       showDialog(
//           context: context,
//           builder: (context) => CustomPopup(
//             title: "Alert",
//             message:"Failed to connect dongle",
//             onButtonPressed: () => Get.back(),
//           ),
//       );

//       return;
//     }

//     // ===============================
//     // CAN2X FAMILY
//     // ===============================
//     if (vciType == VCIType.CAN2X ||
//         vciType == VCIType.CAN2XG ||
//         vciType == VCIType.CAN2XGK) {
//       final macResult = await connectionUSB.getDongleMacId(channelId);

//       if (macResult[0] != "true") {
//         showDialog(
//           context: context,
//           builder: (context) => CustomPopup(
//             title: "Alert",
//             message:macResult[1],
//             onButtonPressed: () => Get.back(),
//           ),
//       );

//         return;
//       }

//       final dllFunctions = DLLFunctions(connectionUSB.mDongleComm);

// firmwareVersion =
//     await dllFunctions.setDongleProperties();

// await AppPreferences.setConnectedVia("USB");
//     }

//     // ===============================
//     // RP1210 / CAN2xFD / DOIP
//     // ===============================
//     else if (vciType == VCIType.RP1210 ||
//         vciType == VCIType.CAN2xFD ||
//         vciType == VCIType.DOIP) {
//       final fwResult =
//           await connectionUSB.getRp1210FwVersion(channelId, vciType);

//       if (fwResult[0] != "true") {
//         showDialog(
//           context: context,
//           builder: (context) => CustomPopup(
//             title: "Alert",
//             message:fwResult[1],
//             onButtonPressed: () => Get.back(),
//           ),
//       );

//         return;
//       }

//       firmwareVersion = fwResult[1];

//       final status = vciType == VCIType.DOIP
//           ? await DLLFunctions.setDoipRp1210Properties(doipConfigModel!)
//           : await AppDllFunctions.setRp1210Properties();

//       if (status != "Success") {
//         showDialog(
//           context: context,
//           builder: (context) => CustomPopup(
//             title: "Alert",
//             message:status,
//             onButtonPressed: () => Get.back(),
//           ),
//       );

//         return;
//       }

//       await AppPreferences.setConnectedVia("USB");
//     } else {
//       showDialog(
//           context: context,
//           builder: (context) => CustomPopup(
//             title: "Alert",
//             message:"Invalid VCI Type Selected",
//             onButtonPressed: () => Get.back(),
//           ),
//       );

//       return;
//     }

//     // ===============================
//     // NAVIGATION
//     // ===============================
//     if (firmwareVersion.isNotEmpty) {
//      Get.toNamed(
//   Routes.diagnosticScreen,
//   arguments: {
//     'firmwareVersion': firmwareVersion,
//     'data': null,
//   },
// );
//     } else {
//        showDialog(
//           context: context,
//           builder: (context) => CustomPopup(
//             title: "Alert",
//             message:"Firmware version not found.",
//             onButtonPressed: () => Get.back(),
//           ),
//       );

//     }
//   } catch (e, stack) {
//     debugPrint("❌ USB Connect error: $e");
//     debugPrintStack(stackTrace: stack);
//   } finally {
//     isLoading.value = false;
//   }
// }
}
