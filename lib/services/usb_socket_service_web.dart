import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:logger/logger.dart';

class UsbSerialService {
  final String address; 
  SerialPort? _port;
  SerialPortReader? _reader;
  final Logger _logger = Logger();
  bool isConnected = false;

  final StreamController<Uint8List> _responseStream = StreamController.broadcast();
  final StreamController<bool> _connectionStream = StreamController.broadcast();

  UsbSerialService({required this.address});

  Stream<Uint8List> get responses => _responseStream.stream;
  Stream<bool> get connectionUpdates => _connectionStream.stream;

  Future<void> connect({int baudRate = 115200}) async {
    try {
      _port = SerialPort(address);

      if (!_port!.openReadWrite()) {
        _logger.e("❌ Could not open port: ${SerialPort.lastError}");
        throw Exception("Permission Denied or Port in Use");
      }

      // 1. Create and Setup Configuration
      final config = SerialPortConfig();
      config.baudRate = baudRate;
      config.bits = 8;
      config.stopBits = 1;
      config.parity = SerialPortParity.none;
      config.setFlowControl(SerialPortFlowControl.none);
      
      // 2. CRITICAL: Toggle DTR/RTS via the Config object
      // On Windows, 1 = High (On), 0 = Low (Off)
      config.dtr = 1; 
      config.rts = 1;

      // Apply the config to the port
      _port!.config = config;

      // 

      // 3. Drain existing buffer noise
      _port!.flush(SerialPortBuffer.both);
      await Future.delayed(const Duration(milliseconds: 200));

      isConnected = true;
      _connectionStream.add(true);
      _logger.i("✅ Port Open ($baudRate Baud)");

      // 4. Start Listening
      _reader = SerialPortReader(_port!);
      _reader!.stream.listen(
        (data) => _handleData(Uint8List.fromList(data)),
        onError: (e) {
          _logger.e("Stream Error: $e");
          disconnect();
        },
        onDone: () => disconnect(),
      );
    } catch (e) {
      _logger.e("❌ Connect Error: $e");
      rethrow;
    }
  }

  void _handleData(Uint8List data) {
    if (isConnected) {
      _responseStream.add(data);
    }
  }

  Future<bool> sendSecurityKey(Uint8List keyBytes) async {
  if (_port == null || !isConnected) return false;

  try {
    // 1. Clear everything again
    _port!.flush(SerialPortBuffer.both); 
    
    // 2. IMPORTANT: Give the VCI a moment to stabilize after the flush
    // Some VCIs need this gap to reset their internal state machine
    await Future.delayed(const Duration(milliseconds: 500));

    // 3. Write the key
    _port!.write(keyBytes);
    _logger.d("🐛 USB Sent Hex Key: ${keyBytes.length} bytes");

    // 4. Collect the full response
    // Sometimes the '46' is just the first byte of a longer message
    final List<int> accumulatedResponse = [];
    
    // We will wait up to 3 seconds for data to arrive
    await for (final data in _responseStream.stream.timeout(const Duration(seconds: 3), onTimeout: (sink) => sink.close())) {
      accumulatedResponse.addAll(data);
      // If we got at least one byte, we stop waiting and check it
      if (accumulatedResponse.isNotEmpty) break;
    }

    String hexResponse = accumulatedResponse.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
    _logger.i("📥 VCI Raw Response: $hexResponse");

    // Logic: If we got '46' (F), it might mean the key was sent too soon.
    // If we get something else (like 0x06 or a full packet), we are golden.
    return accumulatedResponse.isNotEmpty;
  } catch (e) {
    _logger.e("Handshake Error: $e");
    return false;
  }
}

  Future<void> disconnect() async {
    _logger.i("💡 USB Disconnecting...");
    _reader?.close();
    _port?.close();
    _port = null;
    isConnected = false;
    _connectionStream.add(false);
  }

  void dispose() {
    disconnect();
    _responseStream.close();
    _connectionStream.close();
  }
}