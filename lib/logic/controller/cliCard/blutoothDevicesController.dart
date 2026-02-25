// import 'dart:async';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
// import 'package:get/get.dart';

// class BlutoothdDevicesController extends GetxController {
//   late String vciName;

//   final devices = <BluetoothDiscoveryResult>[].obs;
//   final isScanning = false.obs;

//   StreamSubscription<BluetoothDiscoveryResult>? discoveryStream;

//   @override
//   void onInit() {
//     super.onInit();

//     final args = Get.arguments as Map<String, dynamic>?;
//     vciName = args?['vciName'] ?? 'VCI';

//     startScan();
//   }

//   void startScan() {
//     isScanning.value = true;
//     devices.clear();

//     discoveryStream =
//         FlutterBluetoothSerial.instance.startDiscovery().listen((result) {
//       // Avoid duplicates
//       if (!devices.any(
//           (d) => d.device.address == result.device.address)) {
//         devices.add(result);
//       }
//     });

//     discoveryStream?.onDone(() {
//       isScanning.value = false;
//     });
//   }

//   void connectToDevice(BluetoothDevice device) async {
//   try {
//     await FlutterBluetoothSerial.instance.requestEnable();

//     final bonded =
//         await FlutterBluetoothSerial.instance.bondDeviceAtAddress(
//       device.address,
//     );

//     if (bonded == true) {
//       // 🔁 restart scan to fetch real device name
//       startScan();
//     }
//   } catch (e) {
//     print("Connection error: $e");
//   }
// }

//   String getDeviceName(BluetoothDiscoveryResult result, int index) {
//   final name = result.device.name;

//   if (name != null && name.isNotEmpty) {
//     return name; // actual name (after pairing)
//   }

//   // fallback BEFORE pairing
//   return "Bluetooth Device ${index + 1}";
// }


//   @override
//   void onClose() {
//     discoveryStream?.cancel();
//     super.onClose();
//   }
// }
