import 'dart:async';
import 'dart:typed_data';
import 'package:ap_dongle_comm/utils/enums/connectivity.dart';
import 'package:autopeepal/logic/controller/cliCard/terminalController.dart';
import 'package:autopeepal/services/hotspot_service.dart';
import 'package:get/get.dart';
import 'package:convert/convert.dart';
import 'package:ap_dongle_comm/utils/commController.dart';
import 'package:ap_dongle_comm/utils/dongleComm.dart';

class DrawerViewController extends GetxController {
  RxInt index = 0.obs;
  RxBool isLoading = false.obs;
  late String vciName;

  final MdnsDiscoveryService mdnsDiscoveryService = MdnsDiscoveryService();
  RxList<DiscoveredService> discoveredServices = <DiscoveredService>[].obs;
  final CommController comm = Get.find<CommController>();
  late DongleComm dongleComm;

  Rx<DiscoveredService> selectedDevice = DiscoveredService(
    name: '',
    host: '',
    port: 0,
    ip: '',
  ).obs;

  StreamSubscription<Uint8List>? _globalResponseSub;

  @override
  Future<void> onInit() async {
    super.onInit();
    mdnsDiscoveryService.discoveredServices.listen(_onServiceFound);
    mdnsDiscoveryService.startDiscovery();
    //_showLoader();
  }

  void updatePage(int i) {
    index.value = i;
    Get.back();
    final args = Get.arguments as Map<String, dynamic>?;
    vciName = args?['vciName'] ?? 'VCI';
  }

  void refreshDiscovery() {
    print('🔄 Manual Discovery Reset triggered');
    discoveredServices.clear();
    mdnsDiscoveryService.startDiscovery();
  }

  // void _showLoader() async {
  //   isLoading.value = true;
  //   await Future.delayed(const Duration(seconds: 2));
  //   isLoading.value = false;
  // }

  void _onServiceFound(DiscoveredService service) {
    final idx = discoveredServices.indexWhere((s) => s.name == service.name);
    if (idx == -1) {
      discoveredServices.add(service);
    } else {
      discoveredServices[idx] = service;
    }
    discoveredServices.refresh();
  }

// Future<void> connectToDevice(DiscoveredService service, int index) async {
//   try {
//     isLoading.value = true;
//     await comm.connectWifi(host: service.ip, port: 27015);

//     dongleComm = DongleComm(comm: comm, isChannel: true, channelId: '00');

//     //final secResp = await dongleComm.securityAccess();
//     // if (secResp == null) {
//     //   isLoading.value = false;
//     //   return;
//     // }
//     final terminal = Get.put(TerminalController(), permanent: true);
//     terminal.dongleComm = dongleComm;
//     terminal.clearLogs();

//     isLoading.value = false;
//     Get.toNamed(Routes.terminalScreen);

//   } catch (e) {
//     print('Connection Error: $e');
//     isLoading.value = false;
//   }
// }

// Future<void> connectToDevice(DiscoveredService service, int index) async {
//   try {
//     print("🚀 Starting Connection: ${service.ip}");
//     isLoading.value = true;

//     // 1️⃣ Connect socket over WiFi
//     await comm.connectWifi(host: service.ip, port: 6888);

//     // 2️⃣ Set protocol type
//     comm.connectivity.value = Connectivity.rp1210WiFi;

//     // 3️⃣ Initialize DongleComm for RP1210 WiFi
//     dongleComm = DongleComm(
//       comm: comm,
//       isChannel: true,
//       channelId: '00',
//     );

//     // 4️⃣ ClientConnect to ECU
//     bool isConnected = await dongleComm.rp1210ClientConnect("500");
//     if (!isConnected) {
//       print("💥 ClientConnect failed");
//       isLoading.value = false;
//       return;
//     }
//     print("✅ ClientConnect OK");

//     // 5️⃣ Read firmware version
//     String fwVersion = await dongleComm.rp1210ReadVersion();
//     print("ℹ️ ECU Firmware Version: $fwVersion");

//     // 6️⃣ Temporary TX/RX arrays from DOTNET logs
//     Uint8List txArrayTemp = Uint8List.fromList([0, 0, 7, 224]);
//     Uint8List rxArrayTemp = Uint8List.fromList([0, 0, 7, 232]);

//     // 7️⃣ Set Message Filter
//     bool filterOk = await dongleComm.rp1210SendCommand(
//       txArrayTemp,
//       rxArrayTemp,
//       SubCommandId.setMsgFilter,
//     );
//     if (!filterOk) {
//       print("💥 SetMsgFilter failed");
//       isLoading.value = false;
//       return;
//     }
//     print("✅ SetMsgFilter OK");

//     // 8️⃣ Set Flow Control
//     bool flowOk = await dongleComm.rp1210SendCommand(
//       txArrayTemp,
//       rxArrayTemp,
//       SubCommandId.setFlowControl,
//     );
//     if (!flowOk) {
//       print("💥 SetFlowControl failed");
//       isLoading.value = false;
//       return;
//     }
//     print("✅ SetFlowControl OK");

//     // 9️⃣ Setup TerminalController for logs and interaction
//     final terminal = Get.put(TerminalController(), permanent: true);
//     terminal.dongleComm = dongleComm;
//     terminal.firmwareVersion.value = fwVersion;
//     terminal.clearLogs();

//     // 10️⃣ Navigate to Terminal Screen
//     isLoading.value = false;
//     Get.toNamed(Routes.terminalScreen);

//   } catch (e) {
//     print("💥 Connection Exception: $e");
//     isLoading.value = false;
//   }
// }

Future<bool> connectViaRP1210(DiscoveredService service) async {
  try {
    await comm.connectWifi(host: service.ip, port: 6888);
    comm.connectivity.value = Connectivity.rp1210WiFi;

    dongleComm = DongleComm(comm: comm, isChannel: false);
    
    print("✅ Socket Open. Ready for manual handshake on terminal.");
    return true; // Returns true immediately so you can reach the terminal
  } catch (e) {
    print("💥 Connection Error: $e");
    return false;
  }
}
  Future<bool> connectViaStandardWifi(DiscoveredService service) async {
    print("🌐 [WiFi] Starting Standard Connection to: ${service.ip}");

    try {
      print("📡 [WiFi] Attempting socket connect on port 6888...");
      await comm.connectWifi(host: service.ip, port: 6888);

      comm.connectivity.value = Connectivity.wiFi;
      print("✅ [WiFi] Socket Connected. Mode set to wiFi.");

      dongleComm = DongleComm(comm: comm, isChannel: true);
      print("📦 [WiFi] DongleComm initialized (Channel: 00)");
      //     //final secResp = await dongleComm.securityAccess();
//     // if (secResp == null) {
//     //   isLoading.value = false;
//     //   return;
//     // }
      print("🏁 [WiFi] CONNECTION READY");
      return true;
    } catch (e) {
      print("💥 [WiFi] FATAL ERROR during connection: $e");
      return false;
    }
  }

// Main Controller Entry Point
  Future<void> connectToDevice(DiscoveredService service, int index,
      {bool isRP1210 = false}) async {
    print("--------------------------------------------------");
    print(
        "🚀 [START] connectToDevice | Index: $index | Mode: ${isRP1210 ? 'RP1210' : 'Standard'}");

    try {
      isLoading.value = true;
      bool success = false;

      if (isRP1210) {
        success = await connectViaRP1210(service);
      } else {
        success = await connectViaStandardWifi(service);
      }

      if (success) {
        print(
            "🎯 [FINAL] Connection successful. Initializing Terminal Controller...");
    TerminalController terminal;

if (Get.isRegistered<TerminalController>()) {
 
  terminal = Get.find<TerminalController>();
  
} else {
  terminal = Get.put(TerminalController());
}
print("🟢 Setting mode on controller hash: ${terminal.hashCode}");



       

        print("🚚 [FINAL] Navigating to Terminal Screen.");
       // Get.toNamed(Routes.terminalScreen);
      } else {
        print("🛑 [FINAL] Connection failed. Navigation aborted.");
        // You could show a Snackbar here to the user
      }
    } catch (e) {
      print("🛑 [FINAL] Unexpected Exception in connectToDevice: $e");
    } finally {
      isLoading.value = false;
      print("⌛ [END] Connection process finished.");
      print("--------------------------------------------------");
    }
  }

  Future<void> disconnectDevice() async {
    await comm.disconnect();
    _globalResponseSub?.cancel();
    selectedDevice.value =
        DiscoveredService(name: '', host: '', port: 0, ip: '');
    print('🔌 Disconnected.');
  }

  String bytesToHex(Uint8List bytes) => hex.encode(bytes).toUpperCase();

  @override
  void onClose() {
    mdnsDiscoveryService.stopDiscovery();
    _globalResponseSub?.cancel();
    super.onClose();
  }
}
