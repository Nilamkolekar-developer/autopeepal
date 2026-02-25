import 'dart:async';
import 'dart:developer';
import 'package:bonsoir/bonsoir.dart';

class MdnsDiscoveryService {
  final String serviceType;
  final StreamController<DiscoveredService> _discoveredStreamController =
      StreamController.broadcast();
  final StreamController<DiscoveredService> _deviceOfflineStreamController =
      StreamController.broadcast();

  final Set<String> _discoveredHosts = {}; // prevent duplicates
  BonsoirDiscovery? _discovery;
  StreamSubscription? _eventSub;

  MdnsDiscoveryService({this.serviceType = '_http._tcp'});

  Stream<DiscoveredService> get discoveredServices =>
      _discoveredStreamController.stream;

  Stream<DiscoveredService> get deviceOffline =>
      _deviceOfflineStreamController.stream;

  Future<void> startDiscovery() async {
    // Ensure previous discovery is stopped & cleaned up
    await stopDiscovery();

    _discovery = BonsoirDiscovery(type: serviceType);
    await _discovery!.initialize();

    _eventSub = _discovery!.eventStream!.listen((event) {
      if (event is BonsoirDiscoveryServiceFoundEvent) {
        // Automatically resolve when found
        event.service.resolve(_discovery!.serviceResolver);
      }

      if (event is BonsoirDiscoveryServiceResolvedEvent ||
          event is BonsoirDiscoveryServiceUpdatedEvent) {
        final service = event.service;
        final id = '${service?.host}:${service?.port}';

        if (!_discoveredHosts.contains(id)) {
          _discoveredHosts.add(id);

          final discovered = DiscoveredService(
            name: service?.name ?? '',
            host: service?.host ?? '',
            port: service?.port ?? 0,
            ip: service?.host ?? service?.host ?? '',
          );

          _discoveredStreamController.add(discovered);
          log('[mDNS] Discovered: $discovered');
        }
      }

      if (event is BonsoirDiscoveryServiceLostEvent) {
        final service = event.service;
        final id = '${service.host}:${service.port}';
        _discoveredHosts.remove(id);
        final removed = DiscoveredService(
          name: service.name,
          host: service.host ?? '',
          port: service.port,
          ip: service.host ?? service.host ?? '',
        );

        _deviceOfflineStreamController.add(removed);
        log('[mDNS] Service lost: ${service.toJson()}');
      }

      log('Event type: $event');
    });

    await _discovery!.start();
  }

  Future<void> stopDiscovery() async {
    await _eventSub?.cancel();
    _eventSub = null;

    if (_discovery != null) {
      await _discovery!.stop();
      _discovery = null;
    }

    _discoveredHosts.clear();
  }

  /// Only call this when you’re really done with the service
  Future<void> dispose() async {
    await stopDiscovery();
    await _discoveredStreamController.close();
    await _deviceOfflineStreamController.close();
  }
}

class DiscoveredService {
  final String name;
  final String host;
  final int port;
  final String ip;
  DateTime lastSeen;

  DiscoveredService({
    required this.name,
    required this.host,
    required this.port,
    required this.ip,
    DateTime? lastSeen,
  }) : lastSeen = lastSeen ?? DateTime.now();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiscoveredService &&
          runtimeType == other.runtimeType &&
          ip == other.ip &&
          port == other.port &&
          name == other.name;

  @override
  int get hashCode => ip.hashCode ^ port.hashCode;

  @override
  String toString() =>
      'DiscoveredService{name: $name, host: $host, port: $port, ip: $ip}';
}