import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:autopeepal/AppPreferences/app_areferences.dart';
import 'package:autopeepal/app.dart';
import 'package:autopeepal/common_widgets/commonLoader.dart';
import 'package:autopeepal/common_widgets/popup.dart';
import 'package:autopeepal/logic/controller/cliCard/drawerViewController.dart';
import 'package:autopeepal/models/all_models.dart';
import 'package:autopeepal/models/doipConfigFile_model.dart';
import 'package:autopeepal/models/staticData.dart';
import 'package:autopeepal/models/wifiDevice_model.dart';
import 'package:autopeepal/routes/routes_string.dart';
import 'package:autopeepal/services/connectionUsbService.dart';
import 'package:autopeepal/services/connectionWebUsbService.dart';
import 'package:autopeepal/services/connectionWifiService.dart';
import 'package:autopeepal/services/hotspot_service.dart';
import 'package:autopeepal/services/local_storage_services/localStorage_service.dart';
import 'package:autopeepal/utils/save_local_data.dart';
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
      isLoading.value = true;

      await Future.delayed(const Duration(milliseconds: 50));

      final modelLocalList = SaveLocalData().getData("MODEL_LocalList");

      print("[DEBUG] MODEL_LocalList: $modelLocalList");

      final allModels = AllModelsModel.fromJson(
        jsonDecode(await modelLocalList),
      );

      if (allModels.results == null || allModels.results!.isEmpty) {
        print("[ERROR] results empty");
        return;
      }

      modelList.value = List.from(allModels.results!);

      print("[DEBUG] ModelList Loaded: ${modelList.length}");
    } catch (e, stackTrace) {
      print("[EXCEPTION] $e");
      print("[STACK] $stackTrace");
    } finally {
      isLoading.value = false;
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

  RxInt selectedSubModelId = 0.obs;

  void selectSubModel(SubModel subModel) async {
    // 1. Update Reactive Variables
    selectedSubModel.value = subModel;
    selectedSubModelName.value = subModel.name ?? '';
    selectedSubModelYear.value = subModel.modelYear ?? '';
    selectedRegulation.value = '';

    // 2. Capture and Save the ID
    if (subModel.id != null) {
      selectedSubModelId.value = subModel.id!; // store in memory
      App.subModelId = selectedSubModelId.value; // update app runtime value
      await AppPreferences.setInt(
          'selectedSubModelId', selectedSubModelId.value); // persistently
      print("💾 SubModelId saved: ${selectedSubModelId.value}");
    }

    // 3. Load associated ECU data
    loadEcuData().then((_) {
      print("✅ ECU Data loaded for ID ${subModel.id}: "
          "${StaticData.ecuInfo.map((e) => e.ecuName).toList()}");
    });
  }

  Future<void> loadEcuData() async {
    try {
      final subModel = selectedSubModel.value;

      // 1. Safety Check: If no submodel is selected, clear everything and stop
      if (subModel == null) {
        print("⚠️ No submodel selected. Clearing ECU info.");
        StaticData.ecuInfo = <EcuDataSet>[];
        return;
      }

      print("🔹 Loading ECUs for: ${subModel.name}");

      // 2. Clear previous ECU info IMMEDIATELY
      // This prevents "Production" data from leaking into "Development"
      StaticData.ecuInfo = <EcuDataSet>[];

      if (subModel.ecus == null || subModel.ecus!.isEmpty) {
        print("⚠️ No ECUs found in the JSON for ${subModel.name}.");
        return;
      }

      // 3. Create a temporary local list to process the new data
      List<EcuDataSet> freshEcuList = [];

      for (var ecu in subModel.ecus!) {
        freshEcuList.add(EcuDataSet(
          // Basic Identifiers
          ecuName: ecu.name ?? 'Unknown ECU',
          ecuID: ecu.id ?? 0,
          protocol: ecu.protocol,
          channelId: ecu.channel,

          // Headers
          txHeader: ecu.txHeader,
          rxHeader: ecu.rxHeader,

          // Function Indexes (Crucial for Communication)
          readDtcIndex: ecu.readDtcFnIndex?.value,
          clearDtcIndex: ecu.clearDtcFnIndex?.value,
          seedKeyIndex: ecu.seedkeyalgoFnIndex?.value,
          writePidIndex: ecu.writeDataFnIndex?.value,
          iorTestFnIndex: ecu.iorTestFnIndex?.value,

          // Dataset IDs
          pidDatasetId: ecu.pidDatasets?.firstOrNull?.id,
          dtcDatasetId: ecu.datasets?.firstOrNull?.id,

          // Context Info
          modelName: selectedModel.value,
          submodelName: subModel.name ?? 'Unknown Submodel',
          modelYear: subModel.modelYear,

          // Specific Configs
          ecu2: ecu.ecu?.firstOrNull,
          ffSet: ecu.ffSet,
          firingSequence: ecu.firingSequence,
          noOfInjectors: ecu.noOfInjectors,
        ));
      }

      // 4. Sort the list: Always put "EMS" (Engine Management System) at the top
      if (freshEcuList.length > 1) {
        freshEcuList.sort((a, b) {
          String nameA = (a.ecuName ?? "").toUpperCase();
          String nameB = (b.ecuName ?? "").toUpperCase();
          if (nameA == 'EMS') return -1;
          if (nameB == 'EMS') return 1;
          return 0;
        });
      }

      // 5. Final Assignment to Static Storage
      StaticData.ecuInfo = freshEcuList;

      print(
          '✅ Successfully loaded ${StaticData.ecuInfo.length} ECUs for ${subModel.name}');
      for (var item in StaticData.ecuInfo) {
        print('   -> Detected ECU: ${item.ecuName}');
      }
    } catch (e, stack) {
      print('❌ Error in loadEcuData: $e');
      debugPrintStack(stackTrace: stack);
      StaticData.ecuInfo = <EcuDataSet>[]; // Clear on error for safety
    }
  }

  Future<void> wifiConnect(BuildContext context) async {
    try {
      if (selectedModel.value.isEmpty || selectedSubModel.value == null) {
        await showDialog(
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
        await showDialog(
          context: context,
          builder: (context) => CustomPopup(
            title: "Alert",
            message: "Please Select VCI Type",
            onButtonPressed: () => Get.back(),
          ),
        );
        return; // ⚠ Important: exit function after validation
      }

      // 🟡 Loading
      isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 50));

      // 🔌 Save connection type
      await AppPreferences.setConnectedVia("WIFI");

      // Show loader
      Get.dialog(
        const CommonLoader(message: "Scanning..."),
        barrierDismissible: false,
      );
      final connectionWifi = ConnectionWifi();
      final wifiDeviceList = await connectionWifi.getDeviceList();
      final controller = Get.find<DrawerViewController>();
//Save devices in controller
      if (wifiDeviceList != null && wifiDeviceList.isNotEmpty) {
        controller.wifiDevices.value = wifiDeviceList
            .map((s) => WifiDevicesModel(name: s.name, ip: s.ip))
            .toList();

        if (context.mounted) {
          Get.back(); // dismiss loader
          Get.toNamed(Routes.wifiScreen); // display list immediately
        }
      }
      //  final connectionWifi = ConnectionWifi();
      // final wifiDeviceList = await connectionWifi.getDeviceList();

      // if (wifiDeviceList != null && wifiDeviceList.isNotEmpty) {
      //   if (context.mounted) {
      //     Get.toNamed(Routes.wifiScreen);
      //   }
      // }
      else {
        // ❌ Dongle not found
        if (context.mounted) {
          Get.back(); // dismiss loader before showing popup
          await showDialog(
            context: context,
            builder: (context) => CustomPopup(
              title: "Failed",
              message: "Dongle not found",
              onButtonPressed: () => Get.back(),
            ),
          );
        }
      }
    } catch (e, stack) {
      debugPrint("❌ WifiConnect error: $e");
      debugPrintStack(stackTrace: stack);

      // Dismiss loader on error
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (context) => CustomPopup(
            title: "Error",
            message: "Something went wrong: $e",
            onButtonPressed: () => Get.back(),
          ),
        );
      }
    } finally {
      isLoading.value = false;

      // Make sure loader is dismissed in finally
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    }
  }

  Future<void> usbConnect(BuildContext context) async {
    print("🔹 usbConnect started");
    Get.dialog(
      const CommonLoader(message: "Scanning..."),
      barrierDismissible: false,
    );
    try {
      print("Checking selectedModel and selectedSubModel...");
      if (selectedModel.value.isEmpty || selectedSubModel.value == null) {
        print("❌ Model or SubModel not selected");
        closeLoader(); // ⭐ CLOSE LOADER FIRST
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
      print("Checking selected VCI Type...");
      if (selectedVciType.value.isEmpty ||
          selectedVciType.value == "Select VCI") {
        print("❌ VCI Type not selected");
        closeLoader(); // ⭐ CLOSE LOADER FIRST
        showDialog(
          context: context,
          builder: (context) => CustomPopup(
            title: "Alert",
            message: "Please Select VCI Type",
            onButtonPressed: () => Get.back(),
          ),
        );
        return;
      }
      isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 50));
      print("Loader shown");

      String channelId = '';
      final ecuInfo = StaticData.ecuInfo;
      print("ECU Info: $ecuInfo");
      if (ecuInfo.isEmpty || ecuInfo.first.channelId == null) {
        print("❌ Invalid Channel Id Format");
        closeLoader(); // ⭐ CLOSE LOADER FIRST
        showDialog(
          context: context,
          builder: (context) => CustomPopup(
            title: "Alert",
            message: "Invalid Channel Id Format",
            onButtonPressed: () => Get.back(),
          ),
        );
        return;
      }

      final channelSplit = ecuInfo.first.channelId!.split('-');
      if (channelSplit.length > 1) {
        channelId = '0${channelSplit[1]}';
      } else {
        print("❌ Invalid Channel Id Format (split length <=1)");
        closeLoader(); // ⭐ CLOSE LOADER FIRST
        showDialog(
          context: context,
          builder: (context) => CustomPopup(
            title: "Alert",
            message: "Invalid Channel Id Format",
            onButtonPressed: () => Get.back(),
          ),
        );
        return;
      }
      print("Parsed channelId: $channelId");
      print("Parsing VCI Type...");
      final VCIType vciType = VCIType.values.firstWhere(
        (e) => e.name == selectedVciType.value,
        orElse: () {
          print("❌ Invalid VCI Type: ${selectedVciType.value}");
          return VCIType.RP1210;
        },
      );
      print("Selected VCI Type: $vciType");
      DoipConfigModel? doipConfigModel;

      if (vciType == VCIType.DOIP) {
        print("Loading DOIP Config...");
        final doipConfigLocal =
            await AppPreferences.getStringValue("DoipConfig_LocalList");

        if (doipConfigLocal == null || doipConfigLocal.isEmpty) {
          print("❌ DOIP Configuration data not available");
          closeLoader(); // ⭐ CLOSE LOADER FIRST
          showDialog(
            context: context,
            builder: (context) => CustomPopup(
              title: "Alert",
              message:
                  "DOIP Configuration data not available.\nPlease sync local data.",
              onButtonPressed: () => Get.back(),
            ),
          );
          return;
        }

        final doipRoot =
            DoipConfigRootModel.fromJson(jsonDecode(doipConfigLocal));
        doipConfigModel = doipRoot.results
            ?.firstWhereOrNull((x) => x.ecu == ecuInfo.first.ecuID);

        if (doipConfigModel == null) {
          print("❌ DOIP Config for ECU not found");
          closeLoader(); // ⭐ CLOSE LOADER FIRST
          showDialog(
            context: context,
            builder: (context) => CustomPopup(
              title: "Alert",
              message: "DOIP Configuration data not available",
              onButtonPressed: () => Get.back(),
            ),
          );
          return;
        }
        print("DOIP Config loaded: $doipConfigModel");
      }
      print("Connecting USB...");
      // final connectionUSB = ConnectionUSB();
      dynamic connectionUSB;

      if (Platform.isAndroid) {
        connectionUSB = ConnectionUSB();
      } else if (Platform.isWindows) {
        connectionUSB = ConnectionUSBWindows();
      } else {
        print("Unsupported platform");
        return;
      }
      final bool isConnected = await connectionUSB.connectUsb(vciType);
      print("USB connected: $isConnected");

      if (!isConnected) {
        print("❌ Failed to connect dongle");
        closeLoader(); // ⭐ CLOSE LOADER FIRST
        showDialog(
          context: context,
          builder: (context) => CustomPopup(
            title: "Alert",
            message: "Failed to connect dongle",
            onButtonPressed: () => Get.back(),
          ),
        );
        return;
      }
      if (vciType == VCIType.CAN2X ||
          vciType == VCIType.CAN2XG ||
          vciType == VCIType.CAN2XGK) {
        print("Getting Dongle MAC ID...");
        final macResult =
            await connectionUSB.getDongleMacID(channelId: channelId);
        print("MAC Result: $macResult");

        if (macResult[0] != "true") {
          print("❌ MAC ID error: ${macResult[1]}");
          closeLoader(); // ⭐ CLOSE LOADER FIRST
          showDialog(
            context: context,
            builder: (context) => CustomPopup(
              title: "Alert",
              message: macResult[1],
              onButtonPressed: () => Get.back(),
            ),
          );
          return;
        }

        print("Setting Dongle Properties...");
        await App.dllFunctions!.setDongleProperties1();

        await AppPreferences.setConnectedVia("USB");
        print("USB connection complete for CAN2X family");
      } else if (vciType == VCIType.RP1210 ||
          vciType == VCIType.CAN2xFD ||
          vciType == VCIType.DOIP) {
        print("Getting firmware version...");
        final fwResult =
            await connectionUSB.getRP1210FWVersion(channelId, vciType);
        print("Firmware result: $fwResult");

        if (fwResult[0] != "true") {
          print("❌ Firmware error: ${fwResult[1]}");
          closeLoader(); // ⭐ CLOSE LOADER FIRST
          showDialog(
            context: context,
            builder: (context) => CustomPopup(
              title: "Alert",
              message: fwResult[1],
              onButtonPressed: () => Get.back(),
            ),
          );
          return;
        }

        print("Setting DLL properties...");
        final status = vciType == VCIType.DOIP
            ? await App.dllFunctions!.setDoipRp1210Properties(doipConfigModel!)
            : await App.dllFunctions!.setRP1210Properties();

        if (status != "Success") {
          print("❌ DLL Property error: $status");
          closeLoader(); // ⭐ CLOSE LOADER FIRST
          showDialog(
            context: context,
            builder: (context) => CustomPopup(
              title: "Alert",
              message: status,
              onButtonPressed: () => Get.back(),
            ),
          );
          return;
        }

        await AppPreferences.setConnectedVia("USB");
        print("USB connection complete for RP1210/CAN2xFD/DOIP");
      } else {
        print("❌ Invalid VCI Type Selected");
        closeLoader(); // ⭐ CLOSE LOADER FIRST
        showDialog(
          context: context,
          builder: (context) => CustomPopup(
            title: "Alert",
            message: "Invalid VCI Type Selected",
            onButtonPressed: () => Get.back(),
          ),
        );
        return;
      }
      final firmware = await App.dllFunctions?.setDongleProperties1() ?? '';
      print("Firmware version: $firmware");

      if (firmware.isNotEmpty) {
        closeLoader();
        App.firmwareVersion = firmware;
        App.connectedVia = "USB";
       // await Future.delayed(const Duration(milliseconds: 800));
        print("Navigating to Diagnostic Screen");
        Get.toNamed(Routes.diagnosticScreen, arguments: {
          'firmwareVersion': firmware,
          'sessionId': App.sessionId,
        });
      } else {
        if (!isConnected) {
          print("❌ Failed to connect dongle");

          closeLoader(); // ⭐ CLOSE LOADER FIRST

          showDialog(
            context: context,
            builder: (context) => CustomPopup(
              title: "Alert",
              message: "Failed to connect dongle",
              onButtonPressed: () => Get.back(),
            ),
          );

          return;
        }
      }
    } catch (e, stack) {
      print("❌ USB Connect error: $e");
      debugPrintStack(stackTrace: stack);
    } finally {
      isLoading.value = false;
      if (Get.isDialogOpen ?? false) Get.back();
      print("🔹 usbConnect finished");
    }
  }

  void closeLoader() {
    if (Get.isDialogOpen ?? false) {
      Get.back(); // closes CommonLoader
    }
  }

  Future<void> goToJobcardPage() async {
    try {
      isLoading.value = true;

      // Show loader
      if (!(Get.isDialogOpen ?? false)) {
        Get.dialog(
          const CommonLoader(message: "Connecting..."),
          barrierDismissible: false,
        );
      }

      await Future.delayed(const Duration(milliseconds: 50));
      await Get.toNamed(Routes.jobCard, arguments: modelList);

      if (Get.isDialogOpen ?? false) Get.back();
    } catch (e) {
      // Close loader if exception happens
      if (Get.isDialogOpen ?? false) Get.back();
      print("Exception: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
