import 'dart:async';

import 'package:autopeepal/AppPreferences/app_areferences.dart';
import 'package:autopeepal/services/hotspot_service.dart';
import 'package:autopeepal/utils/ui_helper.dart/enums.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DashboardController extends GetxController {
  RxBool isLoading = false.obs;
RxList<VCIType> vciList = <VCIType>[].obs;
  RxString selectedRegulation = "".obs;
  RxString selectedModel = "".obs;
  RxString selectedVciType = "".obs;

  RxString appName = ''.obs;
  RxString version = ''.obs;
  RxString buildNumber = ''.obs;
  final List<String> model = [
    "Disel",
    "CNG",
  ];

  final List<String> types = [
    "Petrol",
    "Diesel",
    "Electric",
  ];

  Future<void> loadAppInfo() async {
    final info = await PackageInfo.fromPlatform();

    appName.value = info.appName;
    version.value = info.version;
    buildNumber.value = info.buildNumber;
  }

  /// -------------------------
  /// ✅ mDNS DISCOVERY SECTION
  /// -------------------------

  final MdnsDiscoveryService mdnsDiscoveryService = MdnsDiscoveryService();

  RxList<DiscoveredService> discoveredServices = <DiscoveredService>[].obs;

  StreamSubscription<DiscoveredService>? _discoverySub;

  bool get isAllSelected =>
      selectedModel.value.isNotEmpty &&
      selectedRegulation.value.isNotEmpty &&
      selectedVciType.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
     loadAppInfo();
      vciList.value =
        VCIType.values.where((e) => e != VCIType.NONE).toList();

    // Load previously selected VCI from SharedPreferences
    AppPreferences.getSelectedVCI().then((value) {
      if (value != null && value.isNotEmpty) {
        selectedVciType.value = value;
      }
    });

    print("🚀 DashboardController Init - Starting mDNS");

    _discoverySub =
        mdnsDiscoveryService.discoveredServices.listen(_onServiceFound);

    mdnsDiscoveryService.startDiscovery();
  }

   void selectVCI(VCIType vci) {
    selectedVciType.value = vci.name;
    AppPreferences.setSelectedVCI(vci.name);
  }

  Rx<DiscoveredService?> lastFoundDevice = Rx<DiscoveredService?>(null);

  void _onServiceFound(DiscoveredService service) {
    print("🔍 Device Found: ${service.name}");

    final index = discoveredServices.indexWhere((s) => s.name == service.name);

    if (index == -1) {
      discoveredServices.add(service);
    } else {
      discoveredServices[index] = service;
    }

    // 🔥 STORE LAST FOUND DEVICE
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

  /// -------------------------
  /// Date Picker
  /// -------------------------

  Future<void> selectDate(BuildContext context,
      TextEditingController controller, RxString selectedDate) async {
    DateTime initialDate = controller.text.isNotEmpty
        ? DateTime.tryParse(controller.text) ?? DateTime.now()
        : DateTime.now();

    List<DateTime?>? picked = await showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        calendarType: CalendarDatePicker2Type.single,
        okButtonTextStyle: const TextStyle(color: Colors.black),
        cancelButtonTextStyle: const TextStyle(color: Colors.black),
        selectedDayHighlightColor: Colors.grey,
        dayTextStyle: const TextStyle(color: Colors.black),
        firstDate: DateTime(2000),
        lastDate: DateTime.now(),
        currentDate: initialDate,
      ),
      dialogSize: const Size(350, 400),
      borderRadius: BorderRadius.circular(15),
    );

    if (picked != null && picked.isNotEmpty && picked.first != null) {
      String formatted = DateFormat('yyyy-MM-dd').format(picked.first!);

      controller.text = formatted;
      selectedDate.value = formatted;
    }
  }
}
