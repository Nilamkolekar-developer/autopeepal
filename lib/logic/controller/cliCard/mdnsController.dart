// import 'dart:async';
// import 'package:autopeepal/services/hotspot_service.dart';
// import 'package:autopeepal/services/mdns_socket_service.dart';
// import 'package:get/get.dart';

// class MdnsController extends GetxController {
//   MdnsSocketService? mdnsSocketService;

//   RxBool isSocketInitialized = false.obs;
//   RxBool isSocketConnected = false.obs;

//   RxList<DiscoveredService> discoveredDevices = <DiscoveredService>[].obs;
//   Rxn<DiscoveredService> selectedDevice = Rxn<DiscoveredService>();

//   StreamSubscription? _responseSub;
//   StreamSubscription? _connectionSub;

//   Future<void> connectToDevice(DiscoveredService service, int index) async {
//     try {
//       if (isSocketInitialized.value && mdnsSocketService?.isConnected == true) {
//         await mdnsSocketService!.disconnect();
//       }

//       mdnsSocketService = MdnsSocketService(
//         host: service.ip,
//         port:  6888, 
//       );

//       isSocketInitialized.value = true;

//       await mdnsSocketService!.connect();

//       if (mdnsSocketService!.isConnected) {
//         selectedDevice.value = service;
//         isSocketConnected.value = true;

//         _listenForResponse();
//         _listenForDisconnect();
//       }
//     } catch (error) {
//       print("Connection error: $error");

//       if (index < discoveredDevices.length) {
//         discoveredDevices.removeAt(index);
//       }
//     }
//   }

//   void _listenForResponse() {
//     _responseSub?.cancel();

//     _responseSub = mdnsSocketService?.responses.listen((data) {
//       print('Received: $data');
//     });
//   }

//   void _listenForDisconnect() {
//     _connectionSub?.cancel();

//     _connectionSub = mdnsSocketService?.connectionUpdates.listen((connected) {
//       if (!connected) {
//         isSocketConnected.value = false;
//         isSocketInitialized.value = false;
//         selectedDevice.value = null;
//       }
//     });
//   }

  
// }
