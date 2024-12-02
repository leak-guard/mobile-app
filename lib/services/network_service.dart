import 'dart:async';
import 'package:leak_guard/models/wifi_network.dart';
import 'package:leak_guard/services/permissions_service.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:nsd/nsd.dart';
import 'package:wifi_scan/wifi_scan.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;

  NetworkService._internal() {
    _initializeNetworkInfo();
  }

  final _networkInfo = NetworkInfo();
  Discovery? _discovery;

  List<WifiNetwork> availableWifiNetworks = [];
  List<Service> discoveredServices = [];
  String? currentWifiName;
  bool isSearchingWifi = false;
  bool isSearchingServices = false;

  final _wifiStreamController = StreamController<List<WifiNetwork>>.broadcast();
  final _servicesStreamController = StreamController<List<Service>>.broadcast();

  Stream<List<WifiNetwork>> get wifiStream => _wifiStreamController.stream;
  Stream<List<Service>> get servicesStream => _servicesStreamController.stream;

  Future<void> _initializeNetworkInfo() async {
    await scanWifiNetworks();
    startServiceDiscovery();
  }

  Future<void> scanWifiNetworks() async {
    isSearchingWifi = true;
    _wifiStreamController.add(availableWifiNetworks);
    //TODO: Remove this delay
    await Future.delayed(const Duration(seconds: 1));

    try {
      final locationEnabled = await requestLocationService();
      if (!locationEnabled) {
        throw Exception('Location services are required for WiFi scanning');
      }

      final can = await WiFiScan.instance.canStartScan();
      if (can != CanStartScan.yes) {
        throw Exception(_getErrorMessage(can));
      }

      currentWifiName = await _networkInfo.getWifiName();
      currentWifiName = currentWifiName?.replaceAll('"', '');

      final result = await WiFiScan.instance.startScan();
      if (!result) {
        throw Exception('Failed to start WiFi scan');
      }

      final accessPoints = await WiFiScan.instance.getScannedResults();

      availableWifiNetworks = accessPoints
          .map((ap) => WifiNetwork.fromWiFiAccessPoint(ap))
          .where((network) => network.ssid.isNotEmpty)
          .toSet()
          .toList();

      availableWifiNetworks
          .sort((a, b) => b.signalStrength.compareTo(a.signalStrength));

      if (currentWifiName != null && currentWifiName!.isNotEmpty) {
        final currentIndex = availableWifiNetworks
            .indexWhere((network) => network.ssid == currentWifiName);
        if (currentIndex != -1) {
          final current = availableWifiNetworks.removeAt(currentIndex);
          availableWifiNetworks.insert(0, current);
        }
      }

      _wifiStreamController.add(availableWifiNetworks);
    } catch (e) {
      print('Error scanning WiFi networks: $e');
    } finally {
      isSearchingWifi = false;
      _wifiStreamController.add(availableWifiNetworks);
    }
  }

  Future<void> startServiceDiscovery() async {
    if (_discovery != null) {
      await stopServiceDiscovery();
    }

    isSearchingServices = true;
    discoveredServices.clear();
    _servicesStreamController.add(discoveredServices);

    try {
      _discovery = await startDiscovery(
        '_leakguard._tcp',
        autoResolve: true,
        ipLookupType: IpLookupType.v4,
      );

      _discovery?.addServiceListener((service, status) {
        if (status == ServiceStatus.found) {
          _handleFoundService(service);
        } else {
          _handleLostService(service);
        }
      });
    } catch (e) {
      print('Error starting service discovery: $e');
      isSearchingServices = false;
    }
  }

  String _getErrorMessage(CanStartScan status) {
    switch (status) {
      case CanStartScan.notSupported:
        return 'WiFi scanning is not supported on this device';
      case CanStartScan.noLocationPermissionRequired:
        return 'Location permission is required for WiFi scanning';
      case CanStartScan.noLocationPermissionDenied:
        return 'Location permission was denied';
      case CanStartScan.noLocationPermissionUpgradeAccuracy:
        return 'Location permission needs to be upgraded for better accuracy';
      case CanStartScan.noLocationServiceDisabled:
        return 'Please enable location services';
      default:
        return 'Unknown error occurred';
    }
  }

  void _handleFoundService(Service service) {
    // TODO:
    // 1. Sprawdzić czy centrala nie jest już w bazie danych (po MAC adresie)
    // 2. Jeśli jest w bazie, ale ma inne IP, zaktualizować IP
    // 3. Dodać do listy tylko unikalne centrale
    // 4. Wyświetlić popup z informacją o zaaktualizowaniu IP

    if (!discoveredServices.any((s) => _isSameService(s, service))) {
      discoveredServices.add(service);
      _servicesStreamController.add(discoveredServices);
    }
    isSearchingServices = false;
  }

  void _handleLostService(Service service) {
    discoveredServices.removeWhere((s) => _isSameService(s, service));
    _servicesStreamController.add(discoveredServices);
  }

  bool _isSameService(Service a, Service b) =>
      a.name == b.name && a.type == b.type;

  Future<void> stopServiceDiscovery() async {
    if (_discovery != null) {
      await stopDiscovery(_discovery!);
      _discovery = null;
      isSearchingServices = false;
    }
  }

  Future<bool> requestLocationService() async {
    final can = await WiFiScan.instance.canStartScan();
    if (can == CanStartScan.noLocationServiceDisabled) {
      final locationGranted =
          await PermissionsService().ensureLocationPermission();
      if (!locationGranted) return false;
    }
    return true;
  }

  Future<void> dispose() async {
    await stopServiceDiscovery();
    await _wifiStreamController.close();
    await _servicesStreamController.close();
  }
}
