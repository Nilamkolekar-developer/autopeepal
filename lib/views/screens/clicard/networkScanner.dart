import 'package:flutter/services.dart';

class NetworkScanner {
  static const MethodChannel _channel =
      MethodChannel('com.example.networkscanner/dhcp');

  static Future<String> getDhcpInfo() async {
    try {
      final String result = await _channel.invokeMethod('getDhcpInfo');
      return result;
    } on PlatformException catch (e) {
      return "Failed: ${e.message}";
    }
  }
}
