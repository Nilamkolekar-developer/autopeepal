import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:multicast_dns/multicast_dns.dart';

class NetworkController extends GetxController {
  final NetworkInfo _info = NetworkInfo();

  var deviceIp = ''.obs;
  var gatewayIp = ''.obs;
  var status = 'Loading...'.obs;

  // Map: IP:port -> {'name': deviceName, 'mac': macAddress}
  var foundDevices = <String, Map<String, String>>{}.obs;

  final int donglePort = 6888;

  @override
  void onInit() {
    super.onInit();
    fetchNetworkInfo();
  }

  // ---------------- Fetch network info ----------------
  Future<void> fetchNetworkInfo() async {
    print("Requesting location permission...");
    final perm = await Permission.locationWhenInUse.request();
    print("Permission status: $perm");

    if (!perm.isGranted) {
      status.value = "Location permission denied";
      deviceIp.value = "Permission required";
      gatewayIp.value = "Permission required";
      return;
    }

    String? ip = await _info.getWifiIP();
    String? gateway = await _info.getWifiGatewayIP();

    if (ip == null) {
      ip = await getLocalIpFallback();
      print("Dynamic local IP detected: $ip");
    }

    deviceIp.value = ip ?? "Not connected";
    gatewayIp.value = gateway ?? "Unknown";
    status.value = ip != null ? "Connected" : "Not connected";
  }

  // ---------------- Get local IP fallback ----------------
  Future<String?> getLocalIpFallback() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
        includeLinkLocal: true,
      );

      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (!addr.isLoopback && isPrivateIp(addr.address)) {
            print("Selected local IP: ${addr.address} from ${interface.name}");
            return addr.address;
          }
        }
      }
    } catch (e) {
      print("Error getting local IP: $e");
    }
    return null;
  }

  bool isPrivateIp(String ip) {
    return ip.startsWith("10.") || ip.startsWith("192.168.") || ip.startsWith("172.");
  }

  // ---------------- Scan subnet for dongle ----------------
  Future<void> scanSubnetForDongle() async {
    final ip = deviceIp.value;
    if (ip == "Not connected" || ip == "Permission required") {
      status.value = "Phone IP not available";
      return;
    }

    final subnet = ip.substring(0, ip.lastIndexOf('.'));
    print("Scanning subnet: $subnet.1-254");
    status.value = "Scanning subnet...";
    foundDevices.clear();

    List<Future> futures = [];

    for (int i = 1; i <= 254; i++) {
      final testIp = "$subnet.$i";
      futures.add(_checkDevice(testIp));
    }

    await Future.wait(futures);

    status.value = foundDevices.isEmpty ? "No devices found" : "Scan complete";
  }

  Future<void> _checkDevice(String ip) async {
    if (await isPortOpen(ip, donglePort)) {
      final name = await getDeviceName(ip);
      final mac = "Unknown"; // Cannot read MAC on Android
      final key = "$ip:$donglePort";
      foundDevices[key] = {'name': name, 'mac': mac};
      print("Found device -> IP: $ip, Name: $name, MAC: $mac");
    }
  }

  Future<bool> isPortOpen(String ip, int port,
      {Duration timeout = const Duration(milliseconds: 300)}) async {
    try {
      final socket = await Socket.connect(ip, port, timeout: timeout);
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ---------------- Get device name ----------------
  Future<String> getDeviceName(String ip) async {
    // First try mDNS
    final nameMdns = await getDeviceNameMdns(ip);
    if (nameMdns != "Unknown") return nameMdns;

    // Fallback: reverse DNS
    try {
      final lookup = await InternetAddress.lookup(ip);
      if (lookup.isNotEmpty) return lookup.first.host;
    } catch (_) {}

    return "Unknown";
  }

  Future<String> getDeviceNameMdns(String ip) async {
    String deviceName = "Unknown";

    try {
      final client = MDnsClient();
      await client.start();

      // Query workstation PTR records
      await for (final PtrResourceRecord ptr
          in client.lookup<PtrResourceRecord>(
              ResourceRecordQuery.serverPointer('_workstation._tcp.local'))) {

        final hostname = ptr.domainName;

        // Lookup IP addresses of this hostname
        await for (final IPAddressResourceRecord ipRecord
            in client.lookup<IPAddressResourceRecord>(
                ResourceRecordQuery.addressIPv4(hostname))) {
          if (ipRecord.address.address == ip) {
            deviceName = hostname;
            break;
          }
        }

        if (deviceName != "Unknown") break;
      }

      client.stop(); // DO NOT await, returns void
    } catch (e) {
      print("mDNS lookup failed for $ip: $e");
    }

    return deviceName;
  }
}
