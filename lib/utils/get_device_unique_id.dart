import 'dart:io';

class GetDeviceUniqueId {
  // /// This mimics your C# method exactly
  // static Future<String> getId() async {
  //   try {
  //     // ------------------- pretend to get network interfaces -------------------
  //     // C# tries to get NetworkInterface[] but never uses it
  //     // So we just declare a dummy variable
  //     var nics = ['wlan0', 'ccmni1']; // dummy list
  //     String sMacAddress = '';

  //     for (var adapter in nics) {
  //       if (adapter == 'wlan0') {
  //         // C# code fetches MAC here but does not return it
  //         sMacAddress = '00:11:22:33:44:55'; // dummy MAC
  //       }

  //       if (adapter == 'ccmni1') {
  //         // nothing in C# code
  //       }

  //       if (sMacAddress.isEmpty) {
  //         // fallback
  //         sMacAddress = 'AA:BB:CC:DD:EE:FF'; // dummy MAC
  //       }
  //     }

  //     // ------------------- pretend to use TelephonyManager -------------------
  //     // C# just declares variable and does nothing

  //     // ------------------- return fixed device ID -------------------
  //     return "1234567890";
  //   } catch (e) {
  //     return "Invalid Device Id";
  //   }
  // }
//   Future<String> getId() async {
//   try {

//     /// ANDROID LOGIC
//     if (Platform.isAndroid) {
//       List<NetworkInterface> nics = await NetworkInterface.list();

//       String macAddress = "";

//       for (var adapter in nics) {
//         print("Adapter Name: ${adapter.name}");

//         if (adapter.name == "wlan0") {
//           if (adapter.addresses.isNotEmpty) {
//             macAddress = adapter.addresses.first.address;
//           }
//         }

//         if (macAddress.isEmpty && adapter.addresses.isNotEmpty) {
//           macAddress = adapter.addresses.first.address;
//         }
//       }

//       if (macAddress.isNotEmpty) {
//         return macAddress;
//       }

//       return "1234567890";
//     }

//     /// WINDOWS LOGIC
//     if (Platform.isWindows) {
//       final interfaces = await NetworkInterface.list();

//       final ni = interfaces
//           .where((intf) =>
//               intf.addresses.isNotEmpty &&
//               (intf.name.toLowerCase().contains('wifi') ||
//                   intf.name.toLowerCase().contains('wlan') ||
//                   intf.name.toLowerCase().contains('ethernet') ||
//                   intf.name.toLowerCase().contains('eth')))
//           .toList()
//         ..sort((a, b) => a.name.compareTo(b.name));

//       final selected = ni.isNotEmpty ? ni.first : null;

//       if (selected != null) {
//         return selected.addresses.first.address;
//       }

//       return "1234567890";
//     }

//     return "1234567890";
//   } catch (e) {
//     return "Invalid Device Id";
//   }
// }
  // Future<String> getId() async {
  //   try {
  //     return "1234567890";
  //   } catch (e) {
  //     return "1234567890";
  //   }
  // }
  Future<String> getId() async {
  if (Platform.isWindows) return "1234567890";
  // Android / iOS logic
  return "1234567890"; // fallback
}
}
