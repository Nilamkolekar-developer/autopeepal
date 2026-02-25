import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

class Can2xConnector {
  final String host;
  final int port;
  Socket? _socket;

  Can2xConnector({required this.host, required this.port});

  /// Connect to the dongle
  Future<bool> connect() async {
    try {
      _socket = await Socket.connect(host, port, timeout: Duration(seconds: 5));
      print("[DEBUG] Connected to $host:$port");
      return true;
    } catch (e) {
      print("[ERROR] Connection failed: $e");
      return false;
    }
  }

  /// Send handshake command
  void sendHandshake() {
    if (_socket == null) return;

    // Example handshake bytes (replace with actual if your docs specify differently)
    Uint8List handshake = Uint8List.fromList([0x55, 0xAA, 0x01, 0x00]);
    _socket!.add(handshake);
    print("[DEBUG] Handshake sent: $handshake");

    _socket!.listen((response) {
      print("[DEBUG] Handshake response: $response");
      if (response.isNotEmpty) {
        print("[INFO] Dongle is alive and responding!");
      }
    }, onError: (error) {
      print("[ERROR] Socket error: $error");
    }, onDone: () {
      print("[DEBUG] Socket closed by dongle");
    });
  }

  /// Send a test command to check if dongle is working
  void sendStatusCheck() {
    if (_socket == null) return;

    // Example: status query command
    Uint8List statusCmd = Uint8List.fromList([0x10, 0x00]);
    _socket!.add(statusCmd);
    print("[DEBUG] Status check command sent: $statusCmd");

    _socket!.listen((response) {
      print("[DEBUG] Status response: $response");
    });
  }

  /// Close the socket
  void disconnect() {
    _socket?.destroy();
    print("[DEBUG] Socket disconnected");
  }
}
