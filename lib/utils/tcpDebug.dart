import 'dart:io';
import 'dart:typed_data';
import 'dart:async';

class TcpDebugService {
  final String host;
  final int port;
  Socket? _socket;

  TcpDebugService({required this.host, required this.port});

  Future<void> start() async {
    try {
      print('[TCP DEBUG] Connecting to $host:$port ...');
      _socket = await Socket.connect(host, port, timeout: Duration(seconds: 5));
      print('[TCP DEBUG] Connected!');

      // Listen to everything the ESP32 sends
      _socket!.listen(
        (data) {
          print('[TCP DEBUG] Received (RAW): $data');
          print('[TCP DEBUG] Received (HEX): ${_bytesToHex(data)}');
        },
        onError: (e) {
          print('[TCP DEBUG] Error: $e');
        },
        onDone: () {
          print('[TCP DEBUG] Socket closed by ESP32');
        },
        cancelOnError: false,
      );
    } catch (e) {
      print('[TCP DEBUG] Connection failed: $e');
    }
  }

  /// Send raw bytes
  Future<void> sendBytes(Uint8List bytes) async {
    if (_socket == null) {
      print('[TCP DEBUG] Socket not connected!');
      return;
    }

    print('[TCP DEBUG] Sending bytes: $bytes');
    print('[TCP DEBUG] Sending HEX: ${_bytesToHex(bytes)}');

    _socket!.add(bytes);
    await _socket!.flush();
  }

  /// Disconnect
  Future<void> stop() async {
    await _socket?.close();
    print('[TCP DEBUG] Socket disconnected');
  }

  String _bytesToHex(Uint8List data) {
    return data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
  }
}
